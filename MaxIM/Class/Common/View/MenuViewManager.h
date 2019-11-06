//
//  MenuViewManager.h
//  MaxIM
//
//  Created by 韩雨桐 on 2019/10/16.
//  Copyright © 2019 hyt. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MenuView;

NS_ASSUME_NONNULL_BEGIN

@interface MenuViewManager : NSObject

@property (nonatomic, strong) MenuView *view;

+ (instancetype)sharedMenuViewManager;

- (void)show;

- (void)hide;

@end

NS_ASSUME_NONNULL_END
