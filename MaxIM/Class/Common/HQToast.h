//
//  HQToast.h
//  MaxIMDemo
//
//  Created by hyt on 2017/7/29.
//  ----------------------------------------------------------------------
//
//                    Copyright (C) 2018-2019   MaxIM.Top
//
// You may obtain a copy of the licence at http://www.maxim.top/LICENCE-MAXIM.md
//
//  ----------------------------------------------------------------------
//

#import <UIKit/UIKit.h>

@interface HQToast : UIView

+ (void)showDialog:(NSString *)content;
+ (void)showDialog:(NSString *)content inView:(UIView *)view;
+ (void)showNetworkError;
+ (void)showDialog:(NSString *)content inView:(UIView *)view WithTime:(CGFloat)seconds;

@end
