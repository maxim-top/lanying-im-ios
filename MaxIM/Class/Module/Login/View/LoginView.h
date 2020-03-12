//
//  LoginView.h
//  MaxIM
//
//  Created by 韩雨桐 on 2019/11/15.
//  Copyright © 2019 hyt. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol LoginViewProtocol <NSObject>

@optional

- (void)privacyButtonClick;
- (void)termsButtonClick;
- (void)confirmButtonClick;
- (void)leftJumpButtonClick;
- (void)rightJumpButtonClick;
- (void)wechatButtonClick;
- (void)scanButtonClick;
- (void)editButtonClick;
- (void)skipButtonClick;


@end



@interface LoginView : UIView

@property (nonatomic, assign) id<LoginViewProtocol> delegate;

+ (instancetype)createLoginVieWithTitle:(NSString *)title;

- (void)addAppIDLabelButtonClickWithAppid:(NSString *)appId;

- (void)addScanConsuleButton;

- (void)setPlaceHoderWithText:(NSString *)firstText
                   SecondText:(NSString *)secondText;

- (void)setConfirmButtonTitle:(NSString *)title;

- (void)addJumpButtonLeftButton:(NSString *)leftButtonName
                    rightButton:(NSString *)rightButtonName;

- (void)addWechatButton;

- (void)addPrivacyLabel;

- (void)showCaptchButton;

- (void)addSkipButton;

- (void)showErrorText:(NSString *)errorText;

- (void)inputUserName:(NSString *)name;



- (NSString *)firstTextfieldText;

- (NSString *)secondTextfieldText;



@end

NS_ASSUME_NONNULL_END
