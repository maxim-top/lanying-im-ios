//
//  PwdChangeVerifyByMobileApi.h
//  MaxIM
//
//  Created by 韩雨桐 on 2020/4/20.
//  Copyright © 2020 hyt. All rights reserved.
//

#import "BaseApi.h"

NS_ASSUME_NONNULL_BEGIN

@interface PwdChangeVerifyByMobileApi : BaseApi

- (instancetype)initWithCaptcha:(NSString *)captcha  mobile:(NSString *)mobile;

@end

NS_ASSUME_NONNULL_END
