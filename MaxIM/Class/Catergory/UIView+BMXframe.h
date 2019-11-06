//
//  UIView+BMXframe.h
//  MaxIMDemo
//
//  Created by hyt on 2018/11/9.
//  Copyright © 2018年 hyt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (BMXframe)

@property (nonatomic) CGFloat bmx_left;

/**
 * Shortcut for frame.origin.y
 *
 * Sets frame.origin.y = top
 */
@property (nonatomic) CGFloat bmx_top;

/**
 * Shortcut for frame.origin.x + frame.size.width
 *
 * Sets frame.origin.x = right - frame.size.width
 */
@property (nonatomic) CGFloat bmx_right;

/**
 * Shortcut for frame.origin.y + frame.size.height
 *
 * Sets frame.origin.y = bottom - frame.size.height
 */
@property (nonatomic) CGFloat bmx_bottom;

/**
 * Shortcut for frame.size.width
 *
 * Sets frame.size.width = width
 */
@property (nonatomic) CGFloat bmx_width;

/**
 * Shortcut for frame.size.height
 *
 * Sets frame.size.height = height
 */
@property (nonatomic) CGFloat bmx_height;

/**
 * Shortcut for center.x
 *
 * Sets center.x = centerX
 */
@property (nonatomic) CGFloat bmx_centerX;

/**
 * Shortcut for center.y
 *
 * Sets center.y = centerY
 */
@property (nonatomic) CGFloat bmx_centerY;
/**
 * Shortcut for frame.origin
 */
@property (nonatomic) CGPoint bmx_origin;

/**
 * Shortcut for frame.size
 */
@property (nonatomic) CGSize bmx_size;

- (UIViewController *)currentViewController;
@end
