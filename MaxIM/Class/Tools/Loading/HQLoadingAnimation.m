//  ************************************************************************
//
//  HQLoadingAnimation.m
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


#import "HQLoadingAnimation.h"

@interface HQLoadingAnimation()

@property (nonatomic, strong) CAKeyframeAnimation *animation;

@end

@implementation HQLoadingAnimation

- (void)setupAnimationInLayer:(CALayer *)layer
                     withSize:(CGSize)size
                    tintColor:(UIColor *)tintColor {
    NSArray *beginTimes = @[@0.1f, @0.2f, @0.3f, @0.4f, @0.5f];
    CGFloat lineSize = size.width / (size.width > 28 ? 9 : 15);
    CGFloat x = (layer.bounds.size.width - size.width) / 2;
    CGFloat y = (layer.bounds.size.height - size.height) / 2;
    for (int i = 0; i < 5; i++) {
        CAShapeLayer *line = [CAShapeLayer layer];
        UIBezierPath *linePath =
        [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, lineSize, size.height)
                                   cornerRadius:lineSize / 2];
        self.animation.beginTime = [beginTimes[i] floatValue];
        line.fillColor = tintColor.CGColor;
        line.path = linePath.CGPath;
        [line addAnimation:self.animation forKey:@"animation"];
        line.frame = CGRectMake(x + lineSize * 2 * i, y, lineSize, size.height);
        [layer addSublayer:line];
    }
}

- (CAKeyframeAnimation *)animation {
    if (_animation == nil) {
        CGFloat duration = 1.0f;
        CAMediaTimingFunction *timingFunction =
        [CAMediaTimingFunction functionWithControlPoints:0.2f :0.68f :0.18f :1.08f];
        CAKeyframeAnimation *animation = [CAKeyframeAnimation
                                          animationWithKeyPath:@"transform.scale.y"];
        animation.keyTimes = @[@0.0f, @0.5f, @1.0f];
        animation.values = @[@1.0f, @0.4f, @1.0f];
        animation.timingFunctions = @[timingFunction, timingFunction];
        animation.repeatCount = HUGE_VALF;
        animation.duration = duration;
        animation.removedOnCompletion = NO;
        _animation = animation;
    }
    return _animation;
}

@end
