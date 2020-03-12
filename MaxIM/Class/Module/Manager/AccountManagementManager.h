//
//  AccountManagementManager.h
//  MaxIM
//
//  Created by 韩雨桐 on 2019/12/17.
//  Copyright © 2019 hyt. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AccountManagementManager : NSObject

+ (instancetype)sharedAccountManagementManager;

- (void)addAccountUserName:(NSString *)userName password:(NSString *)password userid:(NSString *)userid appid:(NSString *)appid;

@end

NS_ASSUME_NONNULL_END
