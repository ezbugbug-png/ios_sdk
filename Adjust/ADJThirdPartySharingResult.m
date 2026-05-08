//
//  ADJThirdPartySharingResult.m
//  Adjust
//
//  Created by Aditi Agrawal on 10.04.26.
//  Copyright © 2026 Adjust GmbH. All rights reserved.
//

#import "ADJThirdPartySharingResult.h"

@implementation ADJThirdPartySharingResult

- (instancetype)initWithThirdPartySharingSettings:(NSString *)thirdPartySharingSettings {
    self = [super init];

    if (self == nil) {
        return nil;
    }

    self.thirdPartySharingSettings = [thirdPartySharingSettings copy];

    return self;
}

- (BOOL)isEqualToThirdPartySharingResult:(ADJThirdPartySharingResult *)thirdPartySharingResult {
    if (thirdPartySharingResult == nil) {
        return NO;
    }

    if (self.thirdPartySharingSettings == thirdPartySharingResult.thirdPartySharingSettings) {
        return YES;
    }

    return [self.thirdPartySharingSettings isEqualToString:thirdPartySharingResult.thirdPartySharingSettings];
}

- (NSDictionary *)dictionary {
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];

    if (self.thirdPartySharingSettings != nil) {
        [dictionary setObject:self.thirdPartySharingSettings forKey:@"thirdPartySharingSettings"];
    }

    return dictionary;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"settings:%@", self.thirdPartySharingSettings];
}

#pragma mark - NSObject protocol methods

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:[ADJThirdPartySharingResult class]]) {
        return NO;
    }

    return [self isEqualToThirdPartySharingResult:(ADJThirdPartySharingResult *)object];
}

- (NSUInteger)hash {
    return [self.thirdPartySharingSettings hash];
}

#pragma mark - NSCopying protocol methods

- (id)copyWithZone:(NSZone *)zone {
    ADJThirdPartySharingResult *copy = [[[self class] allocWithZone:zone] init];

    if (copy) {
        copy.thirdPartySharingSettings = [self.thirdPartySharingSettings copyWithZone:zone];
    }

    return copy;
}

@end
