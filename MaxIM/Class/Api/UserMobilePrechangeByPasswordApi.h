//
//  UserMobilePrechangeByPasswordApi.h
//  MaxIM
//
//  Created by 韩雨桐 on 2019/12/16.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "BaseApi.h"

NS_ASSUME_NONNULL_BEGIN

@interface UserMobilePrechangeByPasswordApi : BaseApi

- (instancetype)initWithPassword:(NSString *)password;

@end

NS_ASSUME_NONNULL_END
