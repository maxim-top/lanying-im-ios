
//
//  LoginQRCodeInfoApi.m
//  MaxIM
//
//  Created by 韩雨桐 on 2019/4/16.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "LoginQRCodeInfoApi.h"

@implementation LoginQRCodeInfoApi

- (nullable NSString *)apiPath  {
    return @"app/qr_code";
}

- (HQRequestMethod)requestMethod {
    return HQRequestMethodGet;
}

@end
