//
//  UIButton+Extention.m
//  OCMicroBlog
//
//  Created by hyt on 15/11/4.
//  Copyright © 2015年 hyt. All rights reserved.
//

#import "UIButton+Extention.h"
#import <objc/runtime.h>


static char topNameKey;
static char rightNameKey;
static char bottomNameKey;
static char leftNameKey;

@implementation UIButton (Extention)

+ (instancetype)buttonWithImageName:(NSString *)imageName
                    BackImageName:(NSString *)backImageName {
    UIButton *button = [[UIButton alloc] init];
    // 设置图片
    if (imageName != nil) {
        [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        if ([UIImage imageNamed:[NSString stringWithFormat:@"%@_highlighted",imageName]]) {
            [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_highlighted",imageName]] forState:UIControlStateHighlighted];
        }
    }
    // 设置背景图片
    if (backImageName != nil) {
        [button setBackgroundImage:[UIImage imageNamed:backImageName] forState:UIControlStateNormal];
        if ([UIImage imageNamed:[NSString stringWithFormat:@"%@_highlighted",backImageName]] ) {
            [button setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_highlighted",backImageName]] forState:UIControlStateHighlighted];
        }        
    }
    return button;
}

+ (instancetype)buttonWithTitle:(NSString *)title
                            color:(UIColor *)color
                         fontSize:(CGFloat)fontSize
                    backImageName:(NSString *)backImageName {
    UIButton *button = [[UIButton alloc] init];
    if (fontSize > 0) {
        [button.titleLabel setFont:[UIFont systemFontOfSize:fontSize]];
    }
    if (color) {
        [button setTitleColor:color forState:UIControlStateNormal];
    }
    if (title != nil && ![@"" isEqualToString:title]) {
        [button setTitle:title forState:UIControlStateNormal];
    }
    if (backImageName != nil && ![@"" isEqualToString:backImageName]) {
        [button setBackgroundImage:[UIImage imageNamed:backImageName] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_highlighted",backImageName]] forState:UIControlStateHighlighted];
    }
    [button sizeToFit];
    return button;
}

+ (instancetype)buttonWithTitle:(NSString *)title color:(UIColor *)color fontSize:(CGFloat)fontSize imageName:(NSString *)imageName {
    UIButton *button = [[UIButton alloc] init];
    if (color) {
        [button setTitleColor:color forState:UIControlStateNormal];
    }
    if (fontSize) {
        [button.titleLabel setFont:[UIFont systemFontOfSize:fontSize]];
    }
    if (title != nil && ![@"" isEqualToString:title]) {
        [button setTitle:title forState:UIControlStateNormal];
    }
    if (imageName != nil && ![@"" isEqualToString:imageName]) {
       [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    }    
    [button sizeToFit];
    return button;
}

- (void)setEnlargeEdge:(CGFloat) size {
    objc_setAssociatedObject(self, &topNameKey, [NSNumber numberWithFloat:size], OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, &rightNameKey, [NSNumber numberWithFloat:size], OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, &bottomNameKey, [NSNumber numberWithFloat:size], OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, &leftNameKey, [NSNumber numberWithFloat:size], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setEnlargeEdgeWithTop:(CGFloat) top right:(CGFloat) right bottom:(CGFloat) bottom left:(CGFloat) left {
    objc_setAssociatedObject(self, &topNameKey, [NSNumber numberWithFloat:top], OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, &rightNameKey, [NSNumber numberWithFloat:right], OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, &bottomNameKey, [NSNumber numberWithFloat:bottom], OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, &leftNameKey, [NSNumber numberWithFloat:left], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (CGRect)enlargedRect {
    NSNumber* topEdge = objc_getAssociatedObject(self, &topNameKey);
    NSNumber* rightEdge = objc_getAssociatedObject(self, &rightNameKey);
    NSNumber* bottomEdge = objc_getAssociatedObject(self, &bottomNameKey);
    NSNumber* leftEdge = objc_getAssociatedObject(self, &leftNameKey);
    if (topEdge && rightEdge && bottomEdge && leftEdge)
    {
        return CGRectMake(self.bounds.origin.x - leftEdge.floatValue,
                          self.bounds.origin.y - topEdge.floatValue,
                          self.bounds.size.width + leftEdge.floatValue + rightEdge.floatValue,
                          self.bounds.size.height + topEdge.floatValue + bottomEdge.floatValue);
    }
    else
    {
        return self.bounds;
    }
}

- (UIView*) hitTest:(CGPoint) point withEvent:(UIEvent*)event {
    CGRect rect = [self enlargedRect];
    if (CGRectEqualToRect(rect, self.bounds))
    {
        return [super hitTest:point withEvent:event];
    }
    return CGRectContainsPoint(rect, point) ? self : nil;
}

@end
