//
//  PwdChangeVerifyByMobile.h
//  MaxIM
//
//  Created by 韩雨桐 on 2020/4/20.
//  Copyright © 2020 hyt. All rights reserved.
//

#import "BaseApi.h"

NS_ASSUME_NONNULL_BEGIN

@interface PwdChangeVerifyByPasswordApi : BaseApi

- (instancetype)initWithPassword:(NSString *)password;

@end

NS_ASSUME_NONNULL_END
