
//
//  QRCodeGroupInviteApi.m
//  MaxIM
//
//  Created by 韩雨桐 on 2019/4/30.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "QRCodeGroupInviteApi.h"

@interface QRCodeGroupInviteApi ()

@property (nonatomic,copy) NSString *info;


@end

@implementation QRCodeGroupInviteApi

- (instancetype)initWithQRCodeInfo:(NSString *)info {
    if (self = [super init]) {
        self.info = info;
    }
    return self;
}

- (nullable NSString *)apiPath  {
    return @"app/qrcode/group_invite";
}

-  (NSDictionary *)requestParams {
    return @{@"qr_info": self.info };
}

- (HQRequestMethod)requestMethod {
    return HQRequestMethodPost;
}



@end
