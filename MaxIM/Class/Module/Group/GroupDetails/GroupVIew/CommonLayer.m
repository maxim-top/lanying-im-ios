//
//  ----------------------------------------------------------------------
//   File    :  CommonLayer.m
//   Author  : shaohui.yang shaohui@bmxlabs.com
//   Purpose :
//   Created : 2018/12/27 by shaohui.yang shaohui@bmxlabs.com
//
//  ----------------------------------------------------------------------
//
//                    Copyright (C) 2018-2019   MaxIM.Top
//
// You may obtain a copy of the licence at http://www.maxim.top/LICENCE-MAXIM.md
//
//  ----------------------------------------------------------------------
    

#import "CommonLayer.h"
#import "UIView+BMXframe.h"

@interface CommonLayer () <UIGestureRecognizerDelegate>
{
    CGFloat sframeHeight;
}

@end

@implementation CommonLayer


- (CommonLayer*)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialView];
    }
    return self;
}

- (CommonLayer*)initWithSframeHeight:(CGFloat) height
{
    self = [super initWithFrame:CGRectMake(0, 0, MAXScreenW, MAXScreenH)];
    if (self) {
        sframeHeight = height;
        [self initialView];
    }
    return self;
}

-(void) initialView {
    self.frame = CGRectMake(0, 0, MAXScreenW, MAXScreenH);
    UIWindow *root = [[[UIApplication sharedApplication] delegate] window];
    _mask = [[UIView alloc] initWithFrame:self.bounds];
    
    _mask.backgroundColor = [UIColor blackColor];
    _mask.layer.opacity = 0.3;
    _mask.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchedBack)];
    [_mask addGestureRecognizer:tap];
    [self addSubview:_mask];
    
    CGFloat sframeH = 200;
    if (sframeHeight != 0) {
        sframeH = sframeHeight;
    }
    _sframe = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MAXScreenW, MAXScreenH)];
    _sframe.backgroundColor = [UIColor whiteColor];
    _sframe.userInteractionEnabled = YES;
    //    _sframe.layer.masksToBounds = YES;
    //    _sframe.layer.cornerRadius = 3.0;
    [self addSubview:_sframe];
    [root addSubview:self];
    [self show];
}

-(void) setSframeHeight:(CGFloat) height
{
    self.sframe.bmx_height = height;
}

-(void) touchedBack
{
    [self hide];
}

-(void) show
{
    self.mask.alpha = 0.0f;
    self.sframe.bmx_top = MAXScreenW;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(aniShowFrame)];
    self.mask.alpha = 0.3;
    [UIView commitAnimations];
}

-(void) aniShowFrame
{
    [UIView animateWithDuration:0.6 delay:0 usingSpringWithDamping:0.4 initialSpringVelocity:7 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        self.sframe.bmx_bottom = MAXScreenH;
    } completion:nil];
}

-(void) hide
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDuration:0.2];
    self.sframe.bmx_top = MAXScreenH;
    [UIView setAnimationDidStopSelector:@selector(animHideMask)];
    [UIView setAnimationDelegate:self];
    [UIView commitAnimations];
}

-(void) animHideMask
{
    self.mask.alpha = 0.3;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(destory)];
    self.mask.alpha = 0;
    [UIView commitAnimations];
    self.hidden = YES;
}

-(void) destory
{
    [self removeFromSuperview];
}


@end
