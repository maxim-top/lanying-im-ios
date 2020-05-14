//
//  ChangeMobileAlert.h
//  MaxIM
//
//  Created by 韩雨桐 on 2019/12/4.
//  Copyright © 2019 hyt. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ChangeMobileAlert;

@protocol ChangeMobileAlertDelegate <NSObject>

- (void)alertDidSelectCaptchaButton:(ChangeMobileAlert *)alert;
- (void)alertDidSelectPasswordButton:(ChangeMobileAlert *)alert;

@end

@interface ChangeMobileAlert : UIView

- (void)show;
//- (instancetype)initWithFrame:(CGRect)frame phone:(NSString *)phone;
+ (instancetype)alertWithTitle:(NSString *)title
                         Phone:(NSString *)phone;
//+ (void)showAlertWithPhone:(NSString *)phone viewController:(UIViewController<ChangeMobileAlertDelegate> *)vc;
- (void)hide;

@property (nonatomic,weak) id<ChangeMobileAlertDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
