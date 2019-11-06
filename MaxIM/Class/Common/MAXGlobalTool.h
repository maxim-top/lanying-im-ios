//
//  MAXGlobalTool.h
//  MaxIM
//
//  Created by hyt on 2018/12/24.
//  Copyright © 2018年 hyt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MAXTabBarController.h"

NS_ASSUME_NONNULL_BEGIN

@interface MAXGlobalTool : NSObject


@property (nonatomic, strong)  MAXTabBarController *rootViewController;


+ (instancetype)share;



@end

NS_ASSUME_NONNULL_END
