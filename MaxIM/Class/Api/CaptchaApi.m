//
//  CaptchaApi.m
//  MaxIM
//
//  Created by 韩雨桐 on 2019/6/14.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "CaptchaApi.h"


@interface CaptchaApi ()

@property (nonatomic,copy) NSString *mobile;

@end

@implementation CaptchaApi

- (instancetype)initWithMobile:(NSString *)mobile {
    if (self = [super init]) {
        self.mobile = mobile;
    }
    return self;
}

- (nullable NSString *)apiPath  {
    return @"app/captcha/sms";
}

-  (NSDictionary *)requestParams {
    return @{@"mobile": self.mobile };
}

- (HQRequestMethod)requestMethod {
    return HQRequestMethodGet;
}

@end
