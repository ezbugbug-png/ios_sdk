//
//  ADJThirdPartySharingResult.m
//  Adjust
//
//  Created by Aditi Agrawal on 10.04.26.
//  Copyright © 2026 Adjust GmbH. All rights reserved.
//

#import "ADJThirdPartySharingResult.h"

@implementation ADJThirdPartySharingResult

- (instancetype)initWithThirdPartySharingSettings:(NSDictionary<NSString *, id> *)thirdPartySharingSettings
                                            error:(NSString *)error {
    self = [super init];

    if (self == nil) {
        return nil;
    }

    self.thirdPartySharingSettings = [thirdPartySharingSettings copy];
    self.error = [error copy];

    return self;
}

#pragma mark - NSCopying protocol methods

- (id)copyWithZone:(NSZone *)zone {
    ADJThirdPartySharingResult *copy = [[[self class] allocWithZone:zone] init];

    if (copy) {
        copy->_thirdPartySharingSettings = [self.thirdPartySharingSettings copyWithZone:zone];
        copy->_error = [self.error copyWithZone:zone];
    }

    return copy;
}

#pragma mark - NSObject protocol methods

- (NSString *)description {
    return [NSString stringWithFormat:@"settings:%@ error:%@",
            self.thirdPartySharingSettings, self.error];
}

#pragma mark - NSObject protocol methods

- (NSDictionary *)dictionary {
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];

    if (self.thirdPartySharingSettings != nil) {
        [dictionary setObject:self.thirdPartySharingSettings forKey:@"thirdPartySharingSettings"];
    }
    if (self.error != nil) {
        [dictionary setObject:self.error forKey:@"error"];
    }

    return dictionary;
}

@end

