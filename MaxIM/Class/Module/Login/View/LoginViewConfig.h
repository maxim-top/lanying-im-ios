//
//  LoginViewConfig.h
//  MaxIM
//
//  Created by 韩雨桐 on 2019/11/16.
//  Copyright © 2019 hyt. All rights reserved.
//

#import <Foundation/Foundation.h>
@class LoginView;

NS_ASSUME_NONNULL_BEGIN


typedef enum : NSUInteger {
    LoginVCTypePasswordLogin,
    LoginVCTypeRegister,
    LoginVCTypeCaptchLogin,
    LoginVCTypeRegisterAndBindPhone,
    LoginVCTypeRegisterAndBindWechat,
    LoginVCTypeBindUserWithPhone,
    LoginVCTypeBindUserWithWechat,
    LoginVCTypeBindPhone
} LoginVCType;


@protocol LoginViewConfigProtocol <NSObject>

@optional

- (void)pushToSmsLogin;

- (void)pushToRegister;

- (void)pushToBindNickNameWithWechatOpenId:(NSString *)wechatOpenId;

- (void)pushToBindUserWithPhone;

- (void)popViewController;

- (void)popRootViewController;

- (void)endLoginView;

- (void)editAppid;

- (void)showUserPrivacy;

- (void)showUserTerms;

- (void)beginScanQRCode;

- (void)loginByWechat;

- (void)signByName:(NSString *)name
          password:(NSString *)password;

- (void)signByPhone:(NSString *)phone
             captch:(NSString *)captch;

- (void)regiesterWithName:(NSString *)name
                 password:(NSString *)password;

- (void)registerAndBindPhoneUserName:(NSString *)userName
                       password:(NSString *)password;

- (void)regiesterAndBindWechatWithName:(NSString *)name
                              password:(NSString *)password;


- (void)bindPhoneWithName:(NSString *)name
            password:(NSString *)password;

- (void)bindWechatWithName:(NSString *)name
                 password:(NSString *)password;


- (void)bindPhone:(NSString *)phone
             captch:(NSString *)captch;


@end

@interface LoginViewConfig : NSObject

@property (nonatomic, assign) LoginVCType viewType;
@property (nonatomic, assign) id<LoginViewConfigProtocol> delegate;
@property (nonatomic, copy) NSString *wechatOpenId;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *sign;


- (instancetype)initWithViewType:(LoginVCType)viewType;

- (LoginView *)creteLoginView;

- (void)setAppid:(NSString *)appid;

- (void)showErrorText:(NSString *)errorText;

- (void)setUserName:(NSString *)name;


@end

NS_ASSUME_NONNULL_END
