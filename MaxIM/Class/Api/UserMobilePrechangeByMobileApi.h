//
//  UserMobilePrechangeByMobileApi.h
//  MaxIM
//
//  Created by 韩雨桐 on 2019/12/5.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "BaseApi.h"

NS_ASSUME_NONNULL_BEGIN

@interface UserMobilePrechangeByMobileApi : BaseApi

- (instancetype)initWithCaptcha:(NSString *)captcha  mobile:(NSString *)mobile;

@end

NS_ASSUME_NONNULL_END
