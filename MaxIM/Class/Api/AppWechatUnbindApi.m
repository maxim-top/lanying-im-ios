//
//  AppWechatUnbindApi.m
//  MaxIM
//
//  Created by 韩雨桐 on 2019/11/22.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "AppWechatUnbindApi.h"

@implementation AppWechatUnbindApi



- (nullable NSString *)apiPath  {
    return @"app/wechat/unbind";
}



- (HQRequestMethod)requestMethod {
    return HQRequestMethodPost;
}




@end
