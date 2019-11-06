//
//  HQLoadingAnimation.h
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

@interface HQLoadingAnimation : NSObject

- (void)setupAnimationInLayer:(CALayer *)layer withSize:(CGSize)size tintColor:(UIColor *)tintColor;

@end
