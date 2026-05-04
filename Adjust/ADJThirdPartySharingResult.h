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

- (nonnull instancetype)initWithThirdPartySharingSettings:(nonnull NSDictionary<NSString *, id> *)thirdPartySharingSettings;

- (nullable NSDictionary *)dictionary;

@end
