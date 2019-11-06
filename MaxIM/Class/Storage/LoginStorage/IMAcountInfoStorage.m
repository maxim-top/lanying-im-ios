//  ************************************************************************
//
//  IMAcountInfoStorage.m
//  MaxIMDemo
//
//  Created by hanyutong on 16/11/21.
//  ----------------------------------------------------------------------
//
//                    Copyright (C) 2018-2019   MaxIM.Top
//
// You may obtain a copy of the licence at http://www.maxim.top/LICENCE-MAXIM.md
//
//  ----------------------------------------------------------------------

#import "IMAcountInfoStorage.h"
#import "IMAcount.h"
@implementation IMAcountInfoStorage

+ (NSString *)modelPath {
    return @"IMAcountInfoStorage";
}

+ (BOOL)isHaveLocalData {
    IMAcount *a = [self loadObject];
    return a.isLogin;
}

@end
