//
//  ADJThirdPartySharingResult.h
//  Adjust
//
//  Created by Aditi Agrawal on 10.04.26.
//  Copyright © 2026 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADJThirdPartySharingResult : NSObject<NSCopying>

@property (nonatomic, copy, nonnull) NSDictionary <NSString *, id> *thirdPartySharingSettings;

@property (nonatomic, copy, nonnull) NSString *error;

- (nonnull instancetype)initWithThirdPartySharingSettings:(nonnull NSDictionary<NSString *, id> *)thirdPartySharingSettings
                                                     error:(nonnull NSString *)error;

- (nullable NSDictionary *)dictionary;

@end
