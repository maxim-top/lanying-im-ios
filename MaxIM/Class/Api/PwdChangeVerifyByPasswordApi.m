//
//  PwdChangeVerifyByMobile.m
//  MaxIM
//
//  Created by 韩雨桐 on 2020/4/20.
//  Copyright © 2020 hyt. All rights reserved.
//

#import "PwdChangeVerifyByPasswordApi.h"

@interface PwdChangeVerifyByPasswordApi ()

@property (nonatomic,copy) NSString *password;


@end

@implementation PwdChangeVerifyByPasswordApi

- (instancetype)initWithPassword:(NSString *)password {
    if (self = [super init]) {
        self.password = password;
    }
    return self;
}

- (nullable NSString *)apiPath  {
    return @"app/pwd_change/verify_by_password";
}

-  (NSDictionary *)requestParams {
    return @{@"password": self.password};
}

- (HQRequestMethod)requestMethod {
    return HQRequestMethodPost;
}

@end
