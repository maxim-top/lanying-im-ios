//
//  AccountManagementManager.m
//  MaxIM
//
//  Created by 韩雨桐 on 2019/12/17.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "AccountManagementManager.h"
#import "AccountListStorage.h"
#import "IMAcount.h"
#import "HostConfigManager.h"

@implementation AccountManagementManager

+ (instancetype)sharedAccountManagementManager {
    static AccountManagementManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc]init];
    });
    return manager;
}

- (void)addAccountUserName:(NSString *)userName password:(NSString *)password userid:(NSString *)userid appid:(NSString *)appid {
        
    NSArray * array = [NSArray arrayWithArray: [AccountListStorage loadObject]];
    NSMutableArray *mArr = [NSMutableArray arrayWithArray:array];
    for (IMAcount *account in array) {
        if ([account.usedId isEqualToString:userid]) {
            [mArr removeObject:account];
        }
    }

    IMAcount *account = [[IMAcount alloc] init];
    account.userName = userName;
    account.password = password;
    account.usedId = userid;
    account.appid = appid;
    account.IMServer = [HostConfigManager sharedManager].IMServer;
    account.IMPort = [HostConfigManager sharedManager].IMPort;
    account.restServer = [HostConfigManager sharedManager].restServer;
    
    [mArr addObject:account];
    
    [AccountListStorage saveObject:[NSArray arrayWithArray:mArr]];
}

@end
