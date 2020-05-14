//
//  LoginViewConfig.m
//  MaxIM
//
//  Created by 韩雨桐 on 2019/11/16.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "LoginViewConfig.h"
#import "LoginView.h"
#import "WXApi.h"
#import "AppIDManager.h"

@interface LoginViewConfig () <LoginViewProtocol>

@property (nonatomic, strong) LoginView *loginView;

@end

@implementation LoginViewConfig

- (instancetype)initWithViewType:(LoginVCType)viewType {
    
    self = [self init];
    if (self) {
        self.viewType = viewType;
    }
    return self;
}


- (LoginView *)creteLoginView {
    
    LoginView *loginView;
    switch (self.viewType) {
        case LoginVCTypePasswordLogin:{
            loginView = [LoginView createLoginVieWithTitle:@"密码登录"];
            [loginView setPlaceHoderWithText:@"用户名/手机号" SecondText:@"密码"];
            [loginView setConfirmButtonTitle:@"登录"];
            [loginView addJumpButtonLeftButton:@"验证码登录" rightButton:@"注册"];
            if ([WXApi isWXAppInstalled] && [AppIDManager isDefaultAppID]) {
                [loginView addWechatButton];
            }
            [loginView addScanConsuleButton];
            
            [loginView addLogButton];

        }
            
            break;
            
        case LoginVCTypeRegister:{
            loginView = [LoginView createLoginVieWithTitle:@"注册"];
            [loginView setPlaceHoderWithText:@"用户名" SecondText:@"密码"];
            [loginView setConfirmButtonTitle:@"继续"];
            [loginView addPrivacyLabel];
            [loginView addJumpButtonLeftButton:@"已有账号，去登录" rightButton:@""];
        }
            
            break;
            
        case LoginVCTypeCaptchLogin:{
            loginView = [LoginView createLoginVieWithTitle:@"验证码登录"];
            [loginView setPlaceHoderWithText:@"手机号" SecondText:@"验证码"];
            [loginView addJumpButtonLeftButton:@"密码登录" rightButton:@"注册"];
            [loginView setConfirmButtonTitle:@"继续"];
            [loginView showCaptchButton];
            if ([WXApi isWXAppInstalled] && [AppIDManager isDefaultAppID]) {
                [loginView addWechatButton];
            }
            [loginView addScanConsuleButton];
        }
            
            break;
            
        case LoginVCTypeRegisterAndBindPhone:
        case LoginVCTypeRegisterAndBindWechat: {
            loginView = [LoginView createLoginVieWithTitle:@"注册并绑定用户"];
             [loginView setPlaceHoderWithText:@"用户名" SecondText:@"密码"];
             [loginView setConfirmButtonTitle:@"继续"];
             [loginView addJumpButtonLeftButton:@"已有账号，直接绑定" rightButton:@""];
        }
            
            break;
            
        case LoginVCTypeBindUserWithPhone:
        case LoginVCTypeBindUserWithWechat:{
            loginView = [LoginView createLoginVieWithTitle:@"绑定已有用户"];
             [loginView setPlaceHoderWithText:@"用户名" SecondText:@"密码"];
             [loginView setConfirmButtonTitle:@"继续"];
            [loginView addJumpButtonLeftButton:@"暂无账号，点击创建" rightButton:@""];
        }
            
            break;
            
        case LoginVCTypeBindPhone:{
            loginView = [LoginView createLoginVieWithTitle:@"绑定手机号"];
             [loginView setPlaceHoderWithText:@"手机号" SecondText:@"验证码"];
             [loginView setConfirmButtonTitle:@"继续"];
             [loginView showCaptchButton];
            [loginView addSkipButton];
        }
            
            break;
            
        default:
            break;
    }
    
    loginView.delegate = self;
    self.loginView = loginView;
    return loginView;
}

- (void)setAppid:(NSString *)appid {
    
    [self.loginView addAppIDLabelButtonClickWithAppid:appid];
}

- (void)showErrorText:(NSString *)errorText {
    
    [self.loginView showErrorText:errorText];
}

- (void)setUserName:(NSString *)name {
    
    [self.loginView inputUserName:name];
}

- (void)showWechatButton:(BOOL)show {
    if (show) {
        [self.loginView addWechatButton];
    } else {
        [self.loginView removeWechatButton];
    }
}


#pragma mark - Deleagte

- (void)privacyButtonClick {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(showUserPrivacy)]) {
        [self.delegate showUserPrivacy];
    }
    
}

- (void)termsButtonClick {
    if (self.delegate && [self.delegate respondsToSelector:@selector(showUserTerms)]) {
        [self.delegate showUserTerms];
    }
}

- (void)scanButtonClick {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(beginScanQRCode)]) {
        [self.delegate beginScanQRCode];
    }
}

- (void)logButtonClick {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(showLogVC)]) {
        [self.delegate showLogVC];
    }
}

- (void)wechatButtonClick {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(loginByWechat)]) {
        [self.delegate loginByWechat];
    }
    
}

- (void)confirmButtonClick {
    
    NSString *firstText = [self.loginView firstTextfieldText];
    NSString *secondText = [self.loginView secondTextfieldText];
    
    switch (self.viewType) {
        case LoginVCTypePasswordLogin: {
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(signByName:password:)]) {
                [self.delegate signByName:firstText password:secondText];
            }
        }
            
            break;
        case LoginVCTypeCaptchLogin: {
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(signByPhone:captch:)]) {
                [self.delegate signByPhone:firstText captch:secondText];
            }
        }
            
            break;
        case LoginVCTypeRegister: {
                if (self.delegate && [self.delegate respondsToSelector:@selector(regiesterWithName:password:)]) {
                    [self.delegate regiesterWithName:firstText password:secondText];
                }
        }
            break;
        case LoginVCTypeRegisterAndBindPhone: {
            if (self.delegate && [self.delegate respondsToSelector:@selector(registerAndBindPhoneUserName:password:)]) {
                [self.delegate registerAndBindPhoneUserName:firstText password:secondText];
            }
        }
            break;
        case LoginVCTypeRegisterAndBindWechat: {
            if (self.delegate && [self.delegate respondsToSelector:@selector(regiesterAndBindWechatWithName:password:)]) {
                [self.delegate regiesterAndBindWechatWithName:firstText password:secondText];
            }
        }
            break;
        case LoginVCTypeBindUserWithPhone: {
            if (self.delegate && [self.delegate respondsToSelector:@selector(bindPhoneWithName:password:)]) {
                [self.delegate bindPhoneWithName:firstText password:secondText];
            }
        }
            
            break;
        case LoginVCTypeBindUserWithWechat: {
            if (self.delegate && [self.delegate respondsToSelector:@selector(bindWechatWithName:password:)]) {
                [self.delegate bindWechatWithName:firstText password:secondText];
            }
        }
            
            break;

        case LoginVCTypeBindPhone: {
            if (self.delegate && [self.delegate respondsToSelector:@selector(bindPhone:captch:)]) {
                [self.delegate bindPhone:firstText captch:secondText];
            }
        }
            
            break;
            
        default:
            break;
    }
}

- (void)leftJumpButtonClick {
    
    if (self.viewType == LoginVCTypePasswordLogin) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(pushToSmsLogin)]) {
            [self.delegate pushToSmsLogin];
        }
    }else if (self.viewType == LoginVCTypeCaptchLogin) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(popViewController)]) {
            [self.delegate popViewController];
        }
    }
    else if (self.viewType == LoginVCTypeRegister) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(popRootViewController)]) {
            [self.delegate popRootViewController];
        }
    }
    else if (self.viewType == LoginVCTypeRegisterAndBindWechat) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(pushToBindNickNameWithWechatOpenId:)]) {
            [self.delegate pushToBindNickNameWithWechatOpenId:self.wechatOpenId];
        }
    }else if (self.viewType == LoginVCTypeRegisterAndBindPhone) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(pushToBindUserWithPhone)]) {
            [self.delegate pushToBindUserWithPhone];
        }
    }else if (self.viewType == LoginVCTypeBindUserWithPhone) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(popViewController)]) {
            [self.delegate popViewController];
        }
    }
    else if (self.viewType == LoginVCTypeBindUserWithWechat) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(popViewController)]) {
            [self.delegate popViewController];
        }
    }
}

- (void)rightJumpButtonClick {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(pushToRegister)]) {
        [self.delegate pushToRegister];
    }
}

- (void)editButtonClick {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(editAppid)]) {
        [self.delegate editAppid];
    }
}

- (void)skipButtonClick {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(endLoginView)]) {
        [self.delegate endLoginView];
    }
    
}


- (void)dealloc {
    
    self.delegate = nil;
}

@end
