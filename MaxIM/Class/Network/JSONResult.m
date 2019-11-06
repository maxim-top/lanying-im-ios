//
//  JSONResult.m
//  MaxIMDemo
//
//  Created by hanyutong on 16/7/7.
//  ----------------------------------------------------------------------
//
//                    Copyright (C) 2018-2019   MaxIM.Top
//
// You may obtain a copy of the licence at http://www.maxim.top/LICENCE-MAXIM.md
//
//  ----------------------------------------------------------------------
//

#import "JSONResult.h"

@implementation JSONResult


- (instancetype)initWithDic:(NSDictionary*)dic {
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dic];
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}

- (void)setValue:(id)value forKey:(NSString *)key{
    if ([key isEqualToString:@"total"] && (value == nil ||
                                           value == NULL ||
                                           [value isKindOfClass:[NSNull class]])) {
        value = @"0";
        return;
    }
    [super setValue:value forKey:key];
}

+ (instancetype)resultWithNetworkErr:(NSError*)err{
    return [[JSONResult alloc] initWithDic:@{@"errcode":@"",@"errmsg":@"",@"data":err}];
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.errcode forKey:@"errcode"];
    [aCoder encodeObject:self.errmsg forKey:@"errmsg"];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder{
    JSONResult* r = [[JSONResult alloc] init];
    r.errcode = [aDecoder decodeObjectForKey:@"errcode"];
    r.errmsg = [aDecoder decodeObjectForKey:@"errmsg"];
    r.data = [aDecoder decodeObjectForKey:@"data"];
    return r;
}


@end
