//
//  AppDelegate.h
//  MaxIM
//
//  Created by hyt on 2018/11/14.
//  Copyright © 2018年 hyt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, assign) CGFloat statusBarHeight;
- (void)userLogin;

- (void)userLogout;

- (void)reloadAppID:(NSString *)appid;
@end

