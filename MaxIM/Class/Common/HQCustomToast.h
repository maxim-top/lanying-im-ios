//
//  HQCustomToast.h
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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern NSString *const NetworkErrorToastStr;

typedef void(^WaitingBlock)();

@interface HQCustomToast : NSObject

+ (void)showWaitingWithWaitingBlock:(WaitingBlock)waitingBlock;

+ (void)showToastWithString:(NSString *)string InView:(UIView *)view;

+ (void)showToastWithInfo:(NSString *)info;

+ (void)showNetworkError;

+ (void)showWating;

+ (void)hideWating;

+ (void)showWatingWithString:(NSString *)string;

+ (void)showDialog:(NSString *)string;

+ (void)showWatingInView:(UIView *)view ;

+ (void)showWatingInView:(UIView *)view duration:(CGFloat) duration;

+ (void)showWatingInView:(UIView *)view str:(NSString *)str;

+ (void)showWatingInView:(UIView *)view duration:(CGFloat)duration str:(NSString *)str;

+ (void)hideWatingInView:(UIView *)view;

+ (void)showDialog:(NSString *)string time:(CGFloat)seconds;

@end
