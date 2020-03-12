//
//  UserMobileBindApi.m
//  MaxIM
//
//  Created by 韩雨桐 on 2019/11/18.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "UserMobileBindApi.h"


@interface UserMobileBindApi ()

@property (nonatomic,copy) NSString *mobile;
@property (nonatomic,copy) NSString *captach;

@end


@implementation UserMobileBindApi

- (instancetype)initWithMobile:(NSString *)mobile  captach:(NSString *)captach {
    if (self = [super init]) {
        self.mobile = mobile;
        self.captach = captach;
    }
    return self;
}

- (nullable NSString *)apiPath  {
    return @"app/user/mobile_bind";
}

-  (NSDictionary *)requestParams {
    return @{@"captcha": self.captach,
             @"mobile": self.mobile };
}

- (HQRequestMethod)requestMethod {
    return HQRequestMethodPost;
}


@end
