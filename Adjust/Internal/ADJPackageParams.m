//
//  ADJPackageParams.m
//  Adjust SDK
//
//  Created by Pedro Filipe (@nonelse) on 17th November 2014.
//  Copyright (c) 2014-2021 adjust GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ADJPackageParams.h"
#import "ADJUtil.h"
#import "ADJAdditions.h"

@implementation ADJPackageParams

+ (ADJPackageParams *) packageParamsWithSdkPrefix:(NSString *)sdkPrefix {
    return [[ADJPackageParams alloc] initWithSdkPrefix:sdkPrefix];
}

+ (ADJPackageParams *)packageParamsWithSdkPrefix:(NSString *)sdkPrefix
                              fbIdReadingEnabled:(BOOL)fbIdReadingEnabled {
    return [[ADJPackageParams alloc] initWithSdkPrefix:sdkPrefix fbIdReadingEnabled:fbIdReadingEnabled];
}

- (id)initWithSdkPrefix:(NSString *)sdkPrefix {
    return [self initWithSdkPrefix:sdkPrefix fbIdReadingEnabled:YES];
}

- (id)initWithSdkPrefix:(NSString *)sdkPrefix fbIdReadingEnabled:(BOOL)fbIdReadingEnabled {
    self = [super init];
    if (self == nil) {
        return nil;
    }

    self.osName = @"ios";
    self.idfv = [ADJAdditions adjFreshCopyOfString:[ADJUtil idfv]];
    if (fbIdReadingEnabled == YES) {
        self.fbAnonymousId = [ADJAdditions adjFreshCopyOfString:[ADJUtil fbAnonymousId]];
    }
    self.bundleIdentifier = [ADJAdditions adjFreshCopyOfString:[ADJUtil bundleIdentifier]];
    self.buildNumber = [ADJAdditions adjFreshCopyOfString:[ADJUtil buildNumber]];
    self.versionNumber = [ADJAdditions adjFreshCopyOfString:[ADJUtil versionNumber]];
    self.deviceType = [ADJAdditions adjFreshCopyOfString:[ADJUtil deviceType]];
    self.deviceName = [ADJAdditions adjFreshCopyOfString:[ADJUtil deviceName]];
    self.osVersion = [ADJAdditions adjFreshCopyOfString:[ADJUtil osVersion]];
    self.installedAt = [ADJUtil installedAt];
    self.startedAt = [ADJUtil startedAt];
    if (sdkPrefix == nil) {
        self.clientSdk = ADJUtil.clientSdk;
    } else {
        self.clientSdk = [NSString stringWithFormat:@"%@@%@", sdkPrefix, ADJUtil.clientSdk];
    }

    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    ADJPackageParams *copy = [[[self class] allocWithZone:zone] init];
    if (copy) {
        copy.fbAnonymousId = [self.fbAnonymousId copyWithZone:zone];
        copy.idfv = [self.idfv copyWithZone:zone];
        copy.clientSdk = [self.clientSdk copyWithZone:zone];
        copy.bundleIdentifier = [self.bundleIdentifier copyWithZone:zone];
        copy.buildNumber = [self.buildNumber copyWithZone:zone];
        copy.versionNumber = [self.versionNumber copyWithZone:zone];
        copy.deviceType = [self.deviceType copyWithZone:zone];
        copy.deviceName = [self.deviceName copyWithZone:zone];
        copy.osName = [self.osName copyWithZone:zone];
        copy.osVersion = [self.osVersion copyWithZone:zone];
        copy.installedAt = [self.installedAt copyWithZone:zone];
        copy.startedAt = self.startedAt;
        copy.idfaCached = [self.idfaCached copyWithZone:zone];
    }
    return copy;
}

@end
