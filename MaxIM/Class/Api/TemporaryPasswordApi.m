//
//  TemporaryPasswordApi.m
//  MaxIM
//
//  Created by 韩雨桐 on 2019/4/8.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "TemporaryPasswordApi.h"

@interface TemporaryPasswordApi ()

@property (nonatomic, strong) NSString *mobile;
@property (nonatomic, strong) NSString *code;

@end

@implementation TemporaryPasswordApi

- (instancetype)initWithMobile:(NSString *)mobile code:(NSString *)code {
    if (self = [super init]) {
        self.mobile = mobile;
        self.code = code;
    }
    return self;
}

- (nullable NSString *)apiPath  {
    return @"app/password";
}

- (nullable NSDictionary *)requestParams {
    return  @{@"code":self.code,
              @"mobile":self.mobile};
}

- (HQRequestMethod)requestMethod {
    return HQRequestMethodGet;
}

@end
