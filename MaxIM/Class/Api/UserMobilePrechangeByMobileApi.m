//
//  UserMobilePrechangeByMobileApi.m
//  MaxIM
//
//  Created by 韩雨桐 on 2019/12/5.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "UserMobilePrechangeByMobileApi.h"

@interface UserMobilePrechangeByMobileApi ()

@property (nonatomic,copy) NSString *captcha;
@property (nonatomic,copy) NSString *mobile;

@end

@implementation UserMobilePrechangeByMobileApi


- (instancetype)initWithCaptcha:(NSString *)captcha  mobile:(NSString *)mobile {
    if (self = [super init]) {
        self.captcha = captcha;
        self.mobile = mobile;
    }
    return self;
    
}

- (nullable NSString *)apiPath  {
    return @"app/user/mobile_prechange_by_mobile";
}

-  (NSDictionary *)requestParams {
    return @{@"captcha": self.captcha,
             @"mobile": self.mobile};
}

- (HQRequestMethod)requestMethod {
    return HQRequestMethodPost;
}


@end
