//
//  MAXGlobalTool.m
//  MaxIM
//
//  Created by hyt on 2018/12/24.
//  Copyright © 2018年 hyt. All rights reserved.
//

#import "MAXGlobalTool.h"
//#import ""

@implementation MAXGlobalTool


+ (id)share
{
    static id _instance ;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}




@end
