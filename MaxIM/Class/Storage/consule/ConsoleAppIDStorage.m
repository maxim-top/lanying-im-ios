//
//  ConsoleAppIDStorage.m
//  MaxIM
//
//  Created by 韩雨桐 on 2019/8/13.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "ConsoleAppIDStorage.h"
#import "ConsoleAppID.h"
@implementation ConsoleAppIDStorage

+ (NSString *)modelPath {
    return [NSString stringWithFormat:@"ConsoleAppIDStorage"];
}

+ (BOOL)hasAppID {
    ConsoleAppID *model = [ConsoleAppIDStorage loadObject];
    if ([model.appId length]) {
        return YES;
    } else {
        return NO;
    }
}

@end
