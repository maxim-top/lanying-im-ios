
//
//  ConsuleAppInfo.m
//  MaxIM
//
//  Created by 韩雨桐 on 2019/6/28.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "ConsuleAppInfo.h"

@implementation ConsuleAppInfo

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dictionary];
    }
    return self;
}
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
}

@end
