//
//  ApiResult.m
//  MaxIMDemo
//
//  Created by hanyutong on 16/8/9.
//  ----------------------------------------------------------------------
//
//                    Copyright (C) 2018-2019   MaxIM.Top
//
// You may obtain a copy of the licence at http://www.maxim.top/LICENCE-MAXIM.md
//
//  ----------------------------------------------------------------------
//

#import "ApiResult.h"

@interface ApiResult ()

@property (nonatomic, strong) NSDictionary *dict;

@end

@implementation ApiResult


- (instancetype)initWithDictionary:(NSDictionary*)dic {
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dic];
        self.responseObject = dic;
        self.resultData = dic[@"data"];
        self.code = [NSString stringWithFormat:@"%@", dic[@"code"]];
        
    }
    return self;
}

- (BOOL)isOK {
    return [self.code isEqualToString:@"200"];
}

- (BOOL)isSuccess {
    return YES;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.code forKey:@"code"];
    [aCoder encodeObject:self.errmsg forKey:@"errmsg"];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    ApiResult* r = [[ApiResult alloc] init];
    r.code = [aDecoder decodeObjectForKey:@"code"];
    r.errmsg = [aDecoder decodeObjectForKey:@"errmsg"];
    return r;
}


@end
