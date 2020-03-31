//
//  AppIDManager.m
//  MaxIM
//
//  Created by 韩雨桐 on 2020/3/27.
//  Copyright © 2020 hyt. All rights reserved.
//

#import "AppIDManager.h"

#import "ConsoleAppIDStorage.h"

static AppIDManager *manager = nil;


@implementation AppIDManager


+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[AppIDManager alloc] init];
        
        if ([ConsoleAppIDStorage hasAppID]) {
            manager.appid = (ConsoleAppID *)[ConsoleAppIDStorage loadObject];
        } else {
            ConsoleAppID *appid = [[ConsoleAppID alloc] init];
            appid.appId = BMXAppID;
            manager.appid = appid;
        }
        
    });
    
    return manager;
}


+ (void)save {
    [ConsoleAppIDStorage saveObject:manager.appid];
}

+ (void)changeAppid:(NSString *)appid isSave:(BOOL)isSave {
    manager.appid.appId = appid;
    
    if (isSave == true) {
        [self save];
    }
}

+ (void)clearAppid {
    
    [ConsoleAppIDStorage clearObject];
    ConsoleAppID *appid = [[ConsoleAppID alloc] init];
    appid.appId = BMXAppID;
    manager.appid = appid;
    
}

+ (BOOL)isDefaultAppID {
    if ([manager.appid.appId isEqualToString:BMXAppID]) {
        return YES;
    }
    return NO;
}


@end
