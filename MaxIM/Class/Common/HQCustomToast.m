//  ************************************************************************
//
//  HQCustomToast.m
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

#import "HQCustomToast.h"
#import "HQToast.h"
#import "MBProgressHUD.h"
#import "HQLoadingAnimationView.h"

NSString *const NetworkErrorToastStr = @"网络正在开小差，请稍后重试";
static bool isShowing = NO;

@implementation HQCustomToast

+ (void)showDialog:(NSString *)string {
    [HQCustomToast showToastWithInfo:string];
}

+ (void)showDialog:(NSString *)string time:(CGFloat)seconds {
    UIWindow *window =  [[UIApplication sharedApplication].delegate window];
    [HQToast showDialog:string inView:window WithTime:seconds];
}

+ (void)showToastWithInfo:(NSString *)info {
    NSString *showinfo = [NSString stringWithString:info];
    NSRange range = [showinfo rangeOfString:@"|||"];
    if (range.length > 0) {
        showinfo = [showinfo  stringByReplacingOccurrencesOfString:@"|||" withString:@"\n"];
    }
    [HQToast showDialog:showinfo];
}

+ (void)showNetworkError {
    [self showToastWithInfo:NetworkErrorToastStr];
}

+ (BOOL)p_isShowing {
    @synchronized (self) {
        return isShowing;
    }
}

+ (void)p_setIsShowing:(BOOL)show {
    @synchronized (self) {
        isShowing = show;
    }
}

+ (void)showWating {
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    [self showWatingInView:window];
}

+ (void)showWaitingWithWaitingBlock:(WaitingBlock)waitingBlock {
    [self showWating];
    waitingBlock();
}

+ (void)showWatingInView:(UIView *)view {
    [self showWatingInView:view duration:0 str:nil];
}

+ (void)showWatingInView:(UIView *)view duration:(CGFloat) duration{
    [self showWatingInView:view duration:duration str:nil];
}

+ (void)showWatingInView:(UIView *)view str:(NSString *)str {
    [self showWatingInView:view duration:0 str:str];
}

+ (void)showWatingInView:(UIView *)view duration:(CGFloat)duration str:(NSString *)str {
    if (view == nil || [view viewWithTag:10021]) {
        return;
    }
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:view];
    hud.mode = MBProgressHUDModeIndeterminate;
//    hud.minSize = CGSizeMake(100, 100);
//    hud.cornerRadius = 4.0;
    hud.backgroundColor = [UIColor clearColor];
    hud.customView = [self loadingAnimationView];
    hud.tag = 10021;
    [view addSubview:hud];
    [hud showAnimated:YES];
    //传入时间大于0,会在此时间后隐藏
    if (duration) {
        [hud hideAnimated:YES afterDelay:duration];
    }
}

+ (HQLoadingAnimationView *)loadingAnimationView {
    HQLoadingAnimationView *activityIndicatorView =
    [[HQLoadingAnimationView alloc] initWithTintColor:[UIColor whiteColor]];
    CGFloat width = 100;
    CGFloat height = 100;
    activityIndicatorView.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - width) * 0.5,
                                             ([UIScreen mainScreen].bounds.size.height - height) * 0.5,
                                             width,
                                             height);
    [activityIndicatorView setBackgroundColor:[UIColor colorWithRed:0.0f green: 0.0f blue:0.0f alpha:0.7f]];
    activityIndicatorView.layer.masksToBounds = YES;
    activityIndicatorView.layer.cornerRadius = 4;
    [activityIndicatorView startAnimating];
    return activityIndicatorView;
}

+ (void)showToastWithString:(NSString *)string InView:(UIView *)view {
    if (view == nil) {
        return;
    }
    if ([self p_isShowing] == YES) {
        return;
    }
    [self p_setIsShowing:YES];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.labelText = string;
}

+ (void)showWatingWithString:(NSString *)string {
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    [self showToastWithString:string InView:window];
}

+ (void)hideWating {
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    [MBProgressHUD  hideHUDForView:window animated:NO];
}

+ (void)hideWatingInView:(UIView *)view {
    if (view == nil) {
        return;
    }
    [MBProgressHUD  hideHUDForView:view animated:NO];
}
@end
