//
//  UserMobilePrechangeByPasswordApi.m
//  MaxIM
//
//  Created by 韩雨桐 on 2019/12/16.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "UserMobilePrechangeByPasswordApi.h"

@interface UserMobilePrechangeByPasswordApi ()

@property (nonatomic,copy) NSString *password;

@end

@implementation UserMobilePrechangeByPasswordApi

- (instancetype)initWithPassword:(NSString *)password {
    if (self = [super init]) {
        self.password = password;
    }
    return self;
}

- (nullable NSString *)apiPath  {
    return @"app/user/mobile_prechange_by_password";
}

-  (NSDictionary *)requestParams {
    return @{@"password": self.password};
}

- (HQRequestMethod)requestMethod {
    return HQRequestMethodPost;
}

@end
