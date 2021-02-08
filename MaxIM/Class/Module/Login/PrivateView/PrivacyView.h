//
//  PrivacyView.h
//  MaxIM
//
//  Created by 韩雨桐 on 2019/11/15.
//  Copyright © 2019 hyt. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PrivacyView;

@protocol PrivacyProtocol <NSObject>

@optional

#pragma mark - WebView

/**
 超链接点击的回调

 @param privacyView view本身
 */
- (void)linkClick:(PrivacyView *)privacyView;

#pragma mark - 颜色

/**
 设置取消按钮标题的颜色

 @param privacyView view本身
 @return 取消按钮标题的颜色
 */
- (UIColor *)privacyViewGetCancelBtnTextColor:(PrivacyView *)privacyView;

/**
 设置确认按钮标题的颜色

 @param privacyView view本身
 @return 确认按钮标题的颜色
 */
- (UIColor *)privacyViewGetOtherBtnTextColor:(PrivacyView *)privacyView;

/**
  设置确认按钮的背景颜色

 @param privacyView view本身
 @return 取确认按钮的背景颜色
 */
- (UIColor *)privacyViewGetOtherBtnBgColor:(PrivacyView *)privacyView;

/**
 设置超链接标题的颜色

 @param privacyView view本身
 @return 确认按钮标题的颜色
 */
- (UIColor *)privacyViewLinkTextColor:(PrivacyView *)privacyView;

#pragma mark - 字体
/**
 设置取消按钮标题的字体

 @param privacyView view本身
 @return 取消按钮标题的字体
 */
- (UIFont *)privacyViewGetCancelBtnTextFont:(PrivacyView *)privacyView;

/**
 设置确认按钮标题的字体

 @param privacyView view本身
 @return 确认按钮标题的字体
 */
- (UIFont *)pvivacyViewGetOtherBtnTextFont:(PrivacyView *)privacyView;

/**
 隐私协议消失后回调此方法

 @param privacyView
 */
- (void)pvivacyViewConfirmClick:(PrivacyView *)privacyView;
@end

@interface PrivacyView : UIView

/** 代理，自定义UI */
@property (nonatomic, assign) id<PrivacyProtocol> delegate;

///** 超链接点击 */
//@property (nonatomic, copy) SelctLinkBlock _Nullable selctLinkBlock;
#pragma mark - 自动化初始化方法
/**
 显示隐私政策弹窗

 @param maxTimeInterVal 显示隐私政策的最晚时间戳，-1表示不启用最大时间，0表示不再弹窗
 @param staticKey NSUserDefault本次存储使用的key
 @param privacyUrl 隐私协议的地址，如果传递了地址则自动展示webview否则将使用deletegate回调
 @param delegate 自定义UI代理
 */
+ (void)showPrivacyWithMaxTimeInterval:(NSTimeInterval)maxTimeInterVal
      view:(UIView *)view
 staticKey:(NSString *)staticKey
privacyUrl:(nullable NSString *)privacyUrl
  delegate:(nullable id<PrivacyProtocol>)delegate;

//#pragma mark - 手动初始化方法
///**
// 判断是否需要展示隐私政策
//
// @param maxTimeInterVal 显示隐私政策的最晚时间戳，-1表示不启用最大时间，0表示不再弹窗
// @param staticKey NSUserDefault本次存储使用的key
// @return 是否应该展示隐私政策弹窗
// */
//+ (BOOL)needShowPrivacyWithMaxTimeInterval:(NSTimeInterval)maxTimeInterVal
//                                   staticKey:(NSString *)staticKey;
//
//
///**
// 创建隐私弹框
//
// @param cancelButtonTitle 取消按钮文字
// @param otherButtonTitle 其他按钮文字
// @param selctBtnBlock 按钮点击回调
// @param delegate 自定义UI代理
// @return 隐私弹框对象
// */
//- (instancetype _Nullable)initWithCancelButtonTitle:(nullable NSString *)cancelButtonTitle
//                                   otherButtonTitle:(nullable NSString *)otherButtonTitle
//                                           delegate:(nullable id<XHPrivacyProtocol> )delegate;
//
///**
// 显示隐私弹框
// */
//- (void)show;

@end

NS_ASSUME_NONNULL_END
