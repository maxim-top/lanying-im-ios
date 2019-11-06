
//
//  ConsoleAppID.m
//  MaxIM
//
//  Created by 韩雨桐 on 2019/8/13.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "ConsoleAppID.h"

@implementation ConsoleAppID
- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dictionary];
    }
    return self;
}
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
}

@end
