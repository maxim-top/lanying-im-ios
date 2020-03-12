//
//  TokenIdApi.h
//  MaxIM
//
//  Created by 韩雨桐 on 2019/11/29.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "BaseApi.h"

NS_ASSUME_NONNULL_BEGIN

@interface TokenIdApi : BaseApi

- (instancetype)initWithUserID:(NSString *)userID  password:(NSString *)password;

@end

NS_ASSUME_NONNULL_END
