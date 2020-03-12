//
//  AppUserInfoPwdApi.m
//  MaxIM
//
//  Created by 韩雨桐 on 2019/11/18.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "AppUserInfoPwdApi.h"

@interface AppUserInfoPwdApi ()

@property (nonatomic,copy) NSString *mobile;
@property (nonatomic,copy) NSString *captcha;

@end

@implementation AppUserInfoPwdApi


- (instancetype)initWithMobile:(NSString *)mobile  captcha:(NSString *)captcha {
    if (self = [super init]) {
        self.mobile = mobile;
        self.captcha = captcha;
    }
    return self;
}

- (nullable NSString *)apiPath  {
    return @"app/user/info_pwd";
}

-  (NSDictionary *)requestParams {
    return @{@"captcha": self.captcha,
             @"mobile": self.mobile};
}

- (HQRequestMethod)requestMethod {
    return HQRequestMethodGet;
}

@end
