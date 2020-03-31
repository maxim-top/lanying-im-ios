//
//  AppIDManager.h
//  MaxIM
//
//  Created by 韩雨桐 on 2020/3/27.
//  Copyright © 2020 hyt. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ConsoleAppID.h"

NS_ASSUME_NONNULL_BEGIN

static NSString *BMXAppID = @"welovemaxim";


@interface AppIDManager : NSObject

+ (instancetype)sharedManager;

@property (nonatomic, strong) ConsoleAppID *appid;

+ (void)changeAppid:(NSString *)appid isSave:(BOOL)isSave;
+ (void)save;
+ (void)clearAppid;
+ (BOOL)isDefaultAppID;


@end

NS_ASSUME_NONNULL_END
