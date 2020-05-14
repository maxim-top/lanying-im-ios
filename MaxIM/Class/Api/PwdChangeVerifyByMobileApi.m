//
//  PwdChangeVerifyByMobileApi.m
//  MaxIM
//
//  Created by 韩雨桐 on 2020/4/20.
//  Copyright © 2020 hyt. All rights reserved.
//

#import "PwdChangeVerifyByMobileApi.h"


@interface PwdChangeVerifyByMobileApi ()

@property (nonatomic,copy) NSString *captcha;
@property (nonatomic,copy) NSString *mobile;

@end

@implementation PwdChangeVerifyByMobileApi

- (instancetype)initWithCaptcha:(NSString *)captcha  mobile:(NSString *)mobile {
    if (self = [super init]) {
        self.captcha = captcha;
        self.mobile = mobile;
    }
    return self;
    
}

- (nullable NSString *)apiPath  {
    return @"app/pwd_change/verify_by_mobile";
}

-  (NSDictionary *)requestParams {
    return @{@"captcha": self.captcha,
             @"mobile": self.mobile};
}

- (HQRequestMethod)requestMethod {
    return HQRequestMethodPost;
}

@end
