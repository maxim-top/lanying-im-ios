//
//  QRCodeLoginApi.m
//  MaxIM
//
//  Created by 韩雨桐 on 2019/4/25.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "QRCodeLoginApi.h"

@interface QRCodeLoginApi ()

@property (nonatomic,copy) NSString *qr_code;

@end

@implementation QRCodeLoginApi

- (instancetype)initWithQRCode:(NSString *)QRCode {
    if (self = [super init]) {
        self.qr_code = QRCode;
    }
    return self;
}

- (nullable NSString *)apiPath  {
    return @"app/qr_login";
}

- (NSDictionary *)requestParams {
    return @{@"qr_code":self.qr_code};
}

- (HQRequestMethod)requestMethod {
    return HQRequestMethodGet;
}

@end
