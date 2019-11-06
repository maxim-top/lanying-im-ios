//
//  HQLoadingAnimationView.h
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

@interface HQLoadingAnimationView : UIView

- (id)initWithTintColor:(UIColor *)tintColor;
- (id)initWithTintColor:(UIColor *)tintColor size:(CGFloat)size;

- (void)startAnimating;
- (void)stopAnimating;

@end
