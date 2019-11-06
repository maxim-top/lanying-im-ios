//  ************************************************************************
//
//  IMAcount.m
//  MaxIMDemo
//
//  Created by hanyutong on 16/11/23.
//  ----------------------------------------------------------------------
//
//                    Copyright (C) 2018-2019   MaxIM.Top
//
// You may obtain a copy of the licence at http://www.maxim.top/LICENCE-MAXIM.md
//
//  ----------------------------------------------------------------------
//
//  Main function:
//
//  Other specifications:
//
//  ************************************************************************

#import "IMAcount.h"

@implementation IMAcount

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dictionary];
    }
    return self;
}
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
}

@end
