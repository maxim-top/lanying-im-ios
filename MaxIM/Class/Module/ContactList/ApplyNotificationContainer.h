//
//  ApplyNotificationContainer.h
//  MaxIM
//
//  Created by 韩雨桐 on 2018/12/15.
//  Copyright © 2018 hyt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <floo-ios/floo_proxy.h>

@class BMXRoster;

NS_ASSUME_NONNULL_BEGIN

@interface ApplyNotificationContainer : NSObject

+ (instancetype) shareInstance;
+ (void)addObjectTo:(BMXRosterItem *)roster;

@end

NS_ASSUME_NONNULL_END
