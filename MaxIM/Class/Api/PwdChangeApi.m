//
//  PwdChangeApi.m
//  MaxIM
//
//  Created by 韩雨桐 on 2020/4/20.
//  Copyright © 2020 hyt. All rights reserved.
//

#import "PwdChangeApi.h"

@interface PwdChangeApi ()

@property (nonatomic,copy) NSString *password;
@property (nonatomic,copy) NSString *sign;
@property (nonatomic,copy) NSString *passwordCheck;

@end

@implementation PwdChangeApi

- (instancetype)initWithPassword:(NSString *)password
                newPasswordCheck:(NSString *)newPasswordCheck
                            sign:(NSString *)sign {
    if (self = [super init]) {
        self.password = password;
        self.sign = sign;
        self.passwordCheck = newPasswordCheck;
    }
    return self;
}

- (nullable NSString *)apiPath  {
    return @"app/pwd_change";
}

-  (NSDictionary *)requestParams {
    return @{@"new_password": self.password,
             @"sign": self.sign,
             @"new_password_check" :self.passwordCheck};
}

- (HQRequestMethod)requestMethod {
    return HQRequestMethodPost;
}



@end
