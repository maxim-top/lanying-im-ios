//
//  MAXLoginView.h
//  MaxIM
//
//  Created by hyt on 2018/12/1.
//  Copyright © 2018 hyt. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^LoginViewButtonClick)(void);
typedef void(^LoginViewConfirmButtonClick)(NSString *username,NSString *password);
typedef void(^RegiesterCommitButtonClick)(NSString *username,NSString *password,NSString *phone, NSString *vertifyCode);

@interface MAXLoginView : UIView


+ (instancetype)createLoginVieWithTitle:(NSString *)title
                            buttonClick:(LoginViewConfirmButtonClick)clickBlock;

- (void)addTransformButtonWithTitle:(NSString *)title
                        buttonClick:(LoginViewButtonClick)clickBlock;

- (void)addscanLoginButtonWithTitle:(NSString *)title
                        buttonClick:(LoginViewButtonClick)clickBlock;

- (void)addOtherLoginButtonWithTitle:(NSString *)title
                        buttonClick:(LoginViewButtonClick)clickBlock;

- (void)addCloseButtonWithbuttonClick:(LoginViewButtonClick)clickBlock;


- (void)addPhoneTextfieldWithSmsbuttonClick:(LoginViewButtonClick)smcClickBlock
                               commitClicke:(RegiesterCommitButtonClick)commitClikckblock;

- (void)addScanConsuleButtonClickWithTitle:(NSString *)title
                               buttonClick:(LoginViewButtonClick)clickBlock;

- (void)addSmsButtonWithbuttonClick:(LoginViewButtonClick)clickBlock;

- (void)addPrivateLabelWithTitle:(NSString *)title
                     buttonClick:(LoginViewButtonClick)clickBlock;

- (void)addappIDLabelButtonClickWithTitle:(NSString *)title
                              buttonClick:(LoginViewButtonClick)clickBlock;

- (void)addWechatTransformButtonWithTitle:(NSString *)title
                              buttonClick:(nonnull LoginViewButtonClick)clickBloc;

- (void)smsButtonhighlight:(BOOL)highlight;

- (void)inputUserName:(NSString *)userName;

- (void)checkcaptchaCodeTime;

- (void)changeCommitBtnName:(NSString *)commitBtnName
          confirmButtonName:(NSString *)confirmButtonName
               closeBtnName:(NSString *)closeBtnName;


@end

