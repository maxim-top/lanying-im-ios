//
//  ChangeMobileAlert.h
//  MaxIM
//
//  Created by 韩雨桐 on 2019/12/4.
//  Copyright © 2019 hyt. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ChangeMobileAlertDelegate <NSObject>

- (void)changeMobileAlertDidSelectCaptchaButton;
- (void)changeMobileAlertDidSelectPasswordButton;

@end

@interface ChangeMobileAlert : UIView

- (void)show;
//- (instancetype)initWithFrame:(CGRect)frame phone:(NSString *)phone;
+ (instancetype)alertWithPhone:(NSString *)phone;
//+ (void)showAlertWithPhone:(NSString *)phone viewController:(UIViewController<ChangeMobileAlertDelegate> *)vc;
- (void)hide;

@property (nonatomic,weak) id<ChangeMobileAlertDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
