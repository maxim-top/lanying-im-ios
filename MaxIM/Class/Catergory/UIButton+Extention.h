//
//  UIButton+Extention.h
//  OCMicroBlog
//
//  Created by hyt on 15/11/4.
//  Copyright © 2015年 hyt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (Extention)

/**
 *  使用 ‘图片名’ 和 ‘背景图片名’ 创建按钮
 *
 *  @param imageName     图片名
 *  @param backImageName 背景图片名
 *
 *  @return UIButton
 */
+ (instancetype)buttonWithImageName:(NSString *)imageName
                    BackImageName:(NSString *)backImageName;

/**
 *  便利构造函数
 *
 *  @param title         标题
 *  @param color         字体颜色
 *  @param fontSize      字体大小
 *  @param backImageName 背景图片名称
 *
 *  @return UIButton
 */
+ (instancetype)buttonWithTitle:(NSString *)title
                            color:(UIColor *)color
                         fontSize:(CGFloat)fontSize
                    backImageName:(NSString *)backImageName;

/**
 *  便利构造函数
 *
 *  @param title     title
 *  @param color     color
 *  @param fontSize  fontSize
 *  @param imageName imageName
 *
 *  @return UIButton
 */
+ (instancetype)buttonWithTitle:(NSString *)title
                        color:(UIColor *)color
                     fontSize:(CGFloat)fontSize
                imageName:(NSString *)imageName;



- (void)setEnlargeEdge:(CGFloat) size;
- (void)setEnlargeEdgeWithTop:(CGFloat) top right:(CGFloat) right bottom:(CGFloat) bottom left:(CGFloat) left;
@end
