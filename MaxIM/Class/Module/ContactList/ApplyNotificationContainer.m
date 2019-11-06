

//
//  ApplyNotificationContainer.m
//  MaxIM
//
//  Created by 韩雨桐 on 2018/12/15.
//  Copyright © 2018 hyt. All rights reserved.
//

#import "ApplyNotificationContainer.h"

@implementation ApplyNotificationContainer

static ApplyNotificationContainer* _instance = nil;
+ (instancetype) shareInstance {
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init] ;
    }) ;
    return _instance ;
}

+ (id) allocWithZone:(struct _NSZone *)zone {
    return [ApplyNotificationContainer shareInstance] ;
}

- (id) copyWithZone:(struct _NSZone *)zone {
    return [ApplyNotificationContainer shareInstance] ;
}


@end
