
//
//  WechatIsBindApi.m
//  MaxIM
//
//  Created by 韩雨桐 on 2019/12/16.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "WechatIsBindApi.h"

@implementation WechatIsBindApi

- (nullable NSString *)apiPath  {
    return @"app/wechat/is_bind";
}

- (HQRequestMethod)requestMethod {
    return HQRequestMethodGet;
}

@end
