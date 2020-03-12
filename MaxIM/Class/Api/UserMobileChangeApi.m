//
//  UserMobileChangeApi.m
//  MaxIM
//
//  Created by 韩雨桐 on 2019/11/23.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "UserMobileChangeApi.h"

@interface UserMobileChangeApi ()

@property (nonatomic,copy) NSString *mobile;
@property (nonatomic,copy) NSString *sign;
@property (nonatomic,copy) NSString *captcha;

@end

@implementation UserMobileChangeApi


- (instancetype)initWithMobile:(NSString *)mobile  sign:(NSString *)sign captcha:(NSString *)captcha{
    if (self = [super init]) {
        self.mobile = mobile;
        self.sign = sign;
        self.captcha = captcha;
    }
    return self;
}

- (nullable NSString *)apiPath  {
    return @"app/user/mobile_change";
}

-  (NSDictionary *)requestParams {
    return @{@"mobile": self.mobile,
             @"sign": self.sign,
             @"captcha" :self.captcha };
}

- (HQRequestMethod)requestMethod {
    return HQRequestMethodPost;
}


@end
