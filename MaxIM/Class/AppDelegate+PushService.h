//
//  AppDelegate+PushService.h
//  MaxIM
//
//  Created by 韩雨桐 on 2020/8/25.
//  Copyright © 2020 hyt. All rights reserved.
//

#import "AppDelegate.h"
#import <floo-ios/floo_proxy.h>
NS_ASSUME_NONNULL_BEGIN

@interface AppDelegate (PushService)<BMXPushServiceProtocol>

- (void)registerAPNs;

@end

NS_ASSUME_NONNULL_END
