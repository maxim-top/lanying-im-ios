
//
//  MenuViewManager.m
//  MaxIM
//
//  Created by 韩雨桐 on 2019/10/16.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "MenuViewManager.h"
#import "MenuView.h"

@interface MenuViewManager ()

@end

@implementation MenuViewManager

+ (instancetype)sharedMenuViewManager {
    static MenuViewManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc]init];
    });
    return manager;
}

- (void)show {
    self.view = [[MenuView alloc] initWithFrame:CGRectMake(0, NavHeight, MAXScreenW, MAXScreenH - NavHeight - TabBarHeight) buttonArray:@[@"添加好友" ,@"创建群组", @"扫一扫"]];
    [MaxKeyWindow addSubview:self.view];
}

- (void)hide {
    [self.view hide];
}

@end
