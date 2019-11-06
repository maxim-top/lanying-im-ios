//
//  SupportStaffApi.m
//  MaxIM
//
//  Created by 韩雨桐 on 2019/10/11.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "SupportStaffApi.h"

@implementation SupportStaffApi

- (nullable NSString *)apiPath  {
    return @"app/support_staff";
}

- (HQRequestMethod)requestMethod {
    return HQRequestMethodGet;
}


@end
