//
//  ZoomMeetingsApi.m
//  MaxIM
//
//  Created by 韩雨桐 on 2020/5/8.
//  Copyright © 2020 hyt. All rights reserved.
//

#import "ZoomMeetingsApi.h"

@implementation ZoomMeetingsApi

- (nullable NSString *)apiPath  {
    return @"app/zoom_meetings";
}


- (HQRequestMethod)requestMethod {
    return HQRequestMethodGet;
}

@end

