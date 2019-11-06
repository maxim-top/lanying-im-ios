//
//  WechatApi.m
//  MaxIM
//
//  Created by 韩雨桐 on 2019/4/29.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "WechatApi.h"

@interface WechatApi ()

@property (nonatomic, strong) NSString  *tempCode;

@end


@implementation WechatApi

- (instancetype)initWithTempCode:(NSString *)tempCode {
    if (self = [super init]) {
        self.tempCode = tempCode;
    }
    return self;
}

- (nullable NSString *)apiPath  {
    NSString *WX_App_ID = @"wx96edf8b1e48af083";
    NSString *WX_App_Secret = @"b5715b46342353c7231eeda9821d0e1e";
    return [NSString  stringWithFormat:@"oauth2/access_token"];
}

- (NSDictionary *)requestParams {
    NSString *WX_App_ID = @"wx96edf8b1e48af083";
    NSString *WX_App_Secret = @"b5715b46342353c7231eeda9821d0e1e";
    return @{@"appid":WX_App_ID,
      @"secret":WX_App_Secret,
      @"code":self.tempCode,
      @"grant_type":@"authorization_code"
      };
}


- (NSString *)baseURL {
    return @"https://api.weixin.qq.com/sns/";
}

- (HQRequestMethod)requestMethod {
    return HQRequestMethodGet;
}

@end
