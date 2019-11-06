

//
//  WechatLoginApi.m
//  MaxIM
//
//  Created by 韩雨桐 on 2019/4/29.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "WechatLoginApi.h"

@interface WechatLoginApi ()

@property (nonatomic,copy) NSString *code;


@end

@implementation WechatLoginApi

- (instancetype)initWithCode:(NSString *)code {
    if (self = [super init]) {
        self.code = code;
    }
    return self;
}

- (nullable NSString *)apiPath  {
    return @"app/wechat_login_app";
}

-  (NSDictionary *)requestParams {
    return @{@"code": self.code };
}

- (HQRequestMethod)requestMethod {
    return HQRequestMethodGet;
}

@end
