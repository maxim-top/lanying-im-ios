
//
//  UIView+BMXframe.m
//  MaxIMDemo
//
//  Created by hyt on 2018/11/9.
//  Copyright © 2018年 hyt. All rights reserved.
//

#import "UIView+BMXframe.h"

@implementation UIView (BMXframe)

- (void)setBmx_left:(CGFloat)bmx_left {
    CGRect frame = self.frame;
    frame.origin.x = bmx_left;
    self.frame = frame;
}
 
- (void)setBmx_top:(CGFloat)bmx_top {
    CGRect frame = self.frame;
    frame.origin.y = bmx_top;
    self.frame = frame;
}
 
- (void)setBmx_bottom:(CGFloat)bmx_bottom {
    CGRect frame = self.frame;
    frame.origin.y = bmx_bottom - frame.size.height;
    self.frame = frame;
}

- (void)setBmx_centerY:(CGFloat)bmx_centerY {
    CGPoint center = self.center;
    center.y = bmx_centerY;
    self.center = center;
}

- (void)setBmx_width:(CGFloat)bmx_width {
    CGRect frame = self.frame;
    frame.size.width = bmx_width;
    self.frame = frame;
}

- (void)setBmx_centerX:(CGFloat)bmx_centerX {
    CGPoint center = self.center;
    center.x = bmx_centerX;
    self.center = center;
    
    
//    self.center = CGPointMake(bmx_centerX, self.center.y);
}

- (void)setBmx_height:(CGFloat)bmx_height {
    CGRect frame = self.frame;
    frame.size.height = bmx_height;
    self.frame = frame;
}

- (void)setBmx_origin:(CGPoint)bmx_origin {
    CGRect frame = self.frame;
    frame.origin = bmx_origin;
    self.frame = frame;
}

- (void)setBmx_size:(CGSize)bmx_size {
    CGRect frame = self.frame;
    frame.size = bmx_size;
    self.frame = frame;
}

- (void)setBmx_right:(CGFloat)bmx_right {
    CGRect frame = self.frame;
    frame.origin.x = bmx_right - frame.size.width;
    self.frame = frame;
}

- (CGFloat)bmx_width {
    return self.frame.size.width;
}

- (CGFloat)bmx_height {
    return self.frame.size.height;
}

- (CGFloat)bmx_centerX {
    return self.center.x;
}

- (CGFloat)bmx_centerY {
    return self.center.y;
}

- (CGPoint)bmx_origin {
    return self.frame.origin;
}

- (CGSize)bmx_size {
    return self.frame.size;
}

- (CGFloat)bmx_right {
    return self.frame.origin.x + self.frame.size.width;
}

- (CGFloat)bmx_bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (CGFloat)bmx_top {
    return self.frame.origin.y;
}

- (CGFloat)bmx_left {
    return self.frame.origin.x;
}



- (UIViewController *)currentViewController {
    UIResponder *next = [self nextResponder];
    do {
        if ([next isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)next;
        }
        next = [next nextResponder];
    } while (next != nil);
    return nil;
}


@end
