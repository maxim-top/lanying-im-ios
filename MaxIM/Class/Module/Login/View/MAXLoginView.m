//
//  MAXLoginView.m
//  MaxIM
//
//  Created by hyt on 2018/12/1.
//  Copyright © 2018 hyt. All rights reserved.
//

#import "MAXLoginView.h"
#import "UIView+BMXframe.h"
#import "CodeTimerManager.h"

#import "CaptchaApi.h"

@interface MAXLoginView ()<TimeProtocol>

#define kUsernameTextFieldTag 1000
#define kPasswordTextFieldTag 1001
#define kPhoneTextFieldTag 1002
#define kSmsTextFieldTag 1003



@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *appIDLabel;
@property (nonatomic, strong) UIButton *editButton;

@property (nonatomic, copy)   NSString *title;
@property (nonatomic, strong) UITextField *usernameTextField;
@property (nonatomic, strong) UIView *usernameTextFieldLine;

@property (nonatomic, strong) UITextField *passwordTextField;
@property (nonatomic, strong) UIView *passwordTextFieldLine;

@property (nonatomic, strong) UIButton *confirmButton;

@property (nonatomic, strong) UITextField *phoneTextField;
@property (nonatomic, strong) UIView *phoneTextFieldLine;

@property (nonatomic, strong) UITextField *smsTextField;
@property (nonatomic, strong) UIView *smsTextFieldLine;


@property (nonatomic, strong) UIButton *getSmsButton;
@property (nonatomic, strong) UIButton *commitPhoneButton;

@property (nonatomic, strong) UIButton *scanLoginButton;

@property (nonatomic, strong) UIView *wechatLine;
@property (nonatomic, strong) UIView *wechatLine1;
@property (nonatomic, strong) UILabel *wechatLabel;
@property (nonatomic, strong) UIButton *otherLoginButton;
@property (nonatomic, strong) UIButton *closeButton;

@property (nonatomic, strong) UIButton *transformDNSBtn;
@property (nonatomic, strong) UIButton *scanConsuleButton;

@property (nonatomic, strong) UIButton *tipButton;
@property (nonatomic, strong) UIButton *privateButton;

@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *captch;


@property (nonatomic, copy) LoginViewConfirmButtonClick confrimButtonClick;
@property (nonatomic, copy) LoginViewButtonClick transformButtonClick;
@property (nonatomic, copy) LoginViewButtonClick scanLoginButtonClick;
@property (nonatomic, copy) LoginViewButtonClick ohterLoginButtonClick;
@property (nonatomic, copy) LoginViewButtonClick scanConsuleButtonClick;
@property (nonatomic, copy) LoginViewButtonClick editAppIDButtonClick;

@property (nonatomic, copy) LoginViewButtonClick smsButtonClick;
@property (nonatomic, copy) LoginViewButtonClick tipButtonClick;



@property (nonatomic, copy) LoginViewButtonClick closeButtonClick;
@property (nonatomic, copy) RegiesterCommitButtonClick commitButonClick;

@property (nonatomic, strong) CodeTimerManager *codeTimerManager;


@end

@implementation MAXLoginView

+ (instancetype)createLoginVieWithTitle:(NSString *)title
                            buttonClick:(nonnull LoginViewConfirmButtonClick)clickBlock {
    
    MAXLoginView *loginView = [[MAXLoginView alloc] initWithFrame:CGRectMake(0, 0, MAXScreenW, MAXScreenH) title:title];
    loginView.confrimButtonClick = clickBlock;
    return loginView;
}

- (instancetype)initWithFrame:(CGRect)frame
                        title:(NSString *)title {
    
    if (self = [super initWithFrame:frame]) {
        
        self.title = title;
        self.titleLabel.text = title;
        [self setupCommonSubviews];
        [self p_configCodeInitialStatus];
    }
    return self;
}

- (void)checkcaptchaCodeTime {
    
}

- (void)inputUserName:(NSString *)userName {
    self.usernameTextField.text = userName;
    self.username = userName;
}

- (void)addappIDLabelButtonClickWithTitle:(NSString *)title
                              buttonClick:(LoginViewButtonClick)clickBlock {
     
    self.appIDLabel.text = [NSString stringWithFormat:@"APPID: %@", title];
    self.appIDLabel.bmx_size = CGSizeMake(200, 30);
    [self.appIDLabel sizeToFit];
    
    self.appIDLabel.bmx_top = NavHeight - 12 ;
    self.appIDLabel.bmx_left = 48;

    self.editButton.bmx_size = CGSizeMake(50, 30);
    self.editButton.bmx_centerY =  self.appIDLabel.bmx_centerY;
    self.editButton.bmx_left = self.appIDLabel.bmx_right + 5;
    
    self.editAppIDButtonClick = clickBlock;
}

- (void)setupCommonSubviews {
    
    self.backgroundColor = [UIColor whiteColor];
    
    self.titleLabel.bmx_top = NavHeight - 12 + 50;
    self.titleLabel.bmx_size = CGSizeMake(100, 40);
    self.titleLabel.bmx_left = 48;
    
    self.usernameTextField.bmx_top = self.titleLabel.bmx_bottom + 20;
    self.usernameTextField.bmx_height = 48;
    self.usernameTextField.bmx_left = 48;
    self.usernameTextField.bmx_width = MAXScreenW - 48 * 2;
    
    self.usernameTextFieldLine.bmx_top = self.usernameTextField.bmx_bottom ;
    self.usernameTextFieldLine.bmx_width = MAXScreenW - 48 * 2;
    self.usernameTextFieldLine.bmx_height = 0.5;
    self.usernameTextFieldLine.bmx_left = 48;


    self.passwordTextField.bmx_top = self.usernameTextField.bmx_bottom + 20;
    self.passwordTextField.bmx_left = self.usernameTextField.bmx_left;
    self.passwordTextField.bmx_width = self.usernameTextField.bmx_width;
    self.passwordTextField.bmx_height = self.usernameTextField.bmx_height;
    
    self.passwordTextFieldLine.bmx_top = self.passwordTextField.bmx_bottom;
    self.passwordTextFieldLine.bmx_width = MAXScreenW - 48 * 2;
    self.passwordTextFieldLine.bmx_height = 0.5;
    self.passwordTextFieldLine.bmx_left = 48;

    
    
    self.confirmButton.bmx_top = self.passwordTextField.bmx_bottom + 40;
    self.confirmButton.bmx_left = self.usernameTextField.bmx_left;
    self.confirmButton.bmx_width = self.usernameTextField.bmx_width;
    self.confirmButton.bmx_height = 55;
    
    [self.smsTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.phoneTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.usernameTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.passwordTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}


- (void)addScanConsuleButtonClickWithTitle:(NSString *)title
                         buttonClick:(LoginViewButtonClick)clickBlock {
    self.scanConsuleButton.bmx_width = 50;
    self.scanConsuleButton.bmx_height = 50;
    self.scanConsuleButton.bmx_centerY = self.appIDLabel.bmx_centerY;
    self.scanConsuleButton.bmx_left = MAXScreenW - 100;
    self.scanConsuleButtonClick = clickBlock;
}

- (void)addOtherLoginButtonWithTitle:(NSString *)title
                         buttonClick:(LoginViewButtonClick)clickBlock {
    
  
    
    UIImage *image = [UIImage imageNamed:@"wechat"];
    self.otherLoginButton.bmx_top = MAXScreenH - 41 - image.size.height;
    self.otherLoginButton.bmx_width = image.size.width;
    self.otherLoginButton.bmx_centerX = self.centerX;
    self.otherLoginButton.bmx_height = image.size.height;
    
    self.wechatLine.bmx_left = 11;
    self.wechatLine.bmx_width = MAXScreenW / 2.0 - 11 * 2 - 25;
    self.wechatLine.bmx_top =  self.otherLoginButton.bmx_origin.y - 30;
    self.wechatLine.bmx_height = 0.5;
    
    self.wechatLine1.bmx_width = MAXScreenW / 2.0 - 11 * 2 - 25;
    self.wechatLine1.bmx_height = 0.5;
    self.wechatLine1.bmx_right = MAXScreenW - 11 ;
    self.wechatLine1.bmx_top = self.otherLoginButton.bmx_origin.y - 30;
    
    self.wechatLabel.bmx_height = 22;
    self.wechatLabel.bmx_width = 60;
    self.wechatLabel.bmx_centerX = self.centerX;
    self.wechatLabel.bmx_centerY = self.wechatLine.bmx_centerY;
   

//    [self.wechatLabel sizeToFit];
    
    self.ohterLoginButtonClick = clickBlock;
}

- (void)addTransformButtonWithTitle:(NSString *)title
                        buttonClick:(nonnull LoginViewButtonClick)clickBlock {
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:BMXCOLOR_HEX(0x333333) forState:UIControlStateNormal];
    if (clickBlock) {
        self.transformButtonClick = clickBlock;
        [button addTarget:self action:@selector(transformButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    [self addSubview:button];
    
    button.bmx_size = CGSizeMake(60, 30);
    button.bmx_top = self.confirmButton.bmx_bottom + 20;
    button.bmx_centerX = self.centerX;
}


- (void)addWechatTransformButtonWithTitle:(NSString *)title
                        buttonClick:(nonnull LoginViewButtonClick)clickBlock {
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:BMXCOLOR_HEX(0x333333) forState:UIControlStateNormal];
    if (clickBlock) {
        self.transformButtonClick = clickBlock;
        [button addTarget:self action:@selector(transformButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    [self addSubview:button];
    
    button.bmx_size = CGSizeMake(100, 30);
    button.bmx_bottom = MAXScreenH - 20;
    button.bmx_centerX = self.centerX;
}


- (void)addscanLoginButtonWithTitle:(NSString *)title
                        buttonClick:(LoginViewButtonClick)clickBlock {
 
    self.scanLoginButton.bmx_top = self.confirmButton.bmx_bottom + 10;
    self.scanLoginButton.bmx_left = self.otherLoginButton.bmx_right + 5;
    self.scanLoginButton.bmx_width = self.usernameTextField.bmx_width / 2 - 5;
    self.scanLoginButton.bmx_height = 40;

    self.scanLoginButtonClick = clickBlock;
}

- (void)addPrivateLabelWithTitle:(NSString *)title
                        buttonClick:(LoginViewButtonClick)clickBlock {
    
    self.tipButtonClick = clickBlock;

    self.tipButton.bmx_size = CGSizeMake(100, 30);
    [self.tipButton sizeToFit];
    self.tipButton.bmx_top = self.commitPhoneButton.bmx_bottom + 10;
    self.tipButton.bmx_centerX = self.centerX;
    
}

- (void)addPhoneTextfieldWithSmsbuttonClick:(LoginViewButtonClick)smcClickBlock commitClicke:(RegiesterCommitButtonClick)commitClikckblock {
    
    [self.confirmButton removeFromSuperview];
    self.commitButonClick = commitClikckblock;
    
    self.phoneTextField.bmx_top = self.passwordTextField.bmx_bottom + 20;
    self.phoneTextField.bmx_height = 48;
    self.phoneTextField.bmx_left = 48;
    self.phoneTextField.bmx_width = MAXScreenW - 48 * 2 - 120;
    
    self.phoneTextFieldLine.bmx_top = self.phoneTextField.bmx_bottom ;
    self.phoneTextFieldLine.bmx_width = MAXScreenW - 48 * 2;
    self.phoneTextFieldLine.bmx_height = 0.5;
    self.phoneTextFieldLine.bmx_left = 48;

    self.smsTextField.bmx_top = self.phoneTextField.bmx_bottom + 20;
    self.smsTextField.bmx_left = self.phoneTextField.bmx_left;
    self.smsTextField.bmx_width = self.phoneTextField.bmx_width;
    self.smsTextField.bmx_height = self.phoneTextField.bmx_height;
    
    self.smsTextFieldLine.bmx_top = self.smsTextField.bmx_bottom ;
    self.smsTextFieldLine.bmx_width = MAXScreenW - 48 * 2;
    self.smsTextFieldLine.bmx_height = 0.5;
    self.smsTextFieldLine.bmx_left = 48;

    
    self.commitPhoneButton.bmx_top = self.smsTextField.bmx_bottom + 30;
    self.commitPhoneButton.bmx_left = self.usernameTextField.bmx_left;
    self.commitPhoneButton.bmx_width = self.usernameTextField.bmx_width;
    self.commitPhoneButton.bmx_height = 55;
}

- (void)changeCommitBtnName:(NSString *)commitBtnName
          confirmButtonName:(NSString *)confirmButtonName
                closeBtnName:(NSString *)closeBtnName {
    

    if (commitBtnName.length > 0) {
        
        [self.commitPhoneButton setTitle:commitBtnName forState:UIControlStateNormal];
        [self.commitPhoneButton setTitle:commitBtnName forState:UIControlStateDisabled];
    }
    if (confirmButtonName.length > 0) {
        [self.confirmButton setTitle:confirmButtonName forState:UIControlStateNormal];
        [self.confirmButton setTitle:confirmButtonName forState:UIControlStateDisabled];
    }
    
    [self.closeButton setTitle:closeBtnName forState:UIControlStateNormal];

}

- (void)smsButtonhighlight:(BOOL)highlight {
    if (highlight == YES) {
        [self p_configCodeInitialStatus];
        [self p_configGetSmsButtonWith:YES];
    }
}

- (void)p_configCodeInitialStatus {
    if (![self.codeTimerManager lastTimeIsFinish]) {
        self.getSmsButton.enabled = NO;
        [self.codeTimerManager beginTimeWithTotalTime:[self.codeTimerManager resultTime]];
    }
}

- (void)addSmsButtonWithbuttonClick:(LoginViewButtonClick)clickBlock {
    
    self.getSmsButton.bmx_top = self.smsTextField.bmx_top;
    self.getSmsButton.bmx_left = self.smsTextField.bmx_right + 20;
    self.getSmsButton.bmx_width = 100;
    self.getSmsButton.bmx_height = 48;
    
    self.smsButtonClick = clickBlock;
}

- (void)addCloseButtonWithbuttonClick:(LoginViewButtonClick)clickBlock {
    
    if (clickBlock) {
        self.closeButtonClick = clickBlock;
        [self.closeButton addTarget:self action:@selector(closeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    [self addSubview:self.closeButton];
    
    self.closeButton.bmx_size = CGSizeMake(80, 20);
    self.closeButton.bmx_centerY = self.titleLabel.bmx_centerY;
    self.closeButton.bmx_right = MAXScreenW -  48;
    
}

- (void)p_configGetSmsButtonWith:(BOOL)isStart{
    if (![self.codeTimerManager lastTimeIsFinish]) {
        return;
    }
    
    if (isStart) {
        [self.codeTimerManager beginTimeWithTotalTime:60];
        [self.getSmsButton setTitle:NSLocalizedString(@"sixtysec_later_to_resend", @"60秒后重发") forState:UIControlStateNormal];
        [self.getSmsButton setTitleColor:kColorC3_7 forState:UIControlStateNormal];
        self.getSmsButton.enabled = NO;
    } else {
        [self.getSmsButton setTitle:NSLocalizedString(@"Get_captcha", @"获取验证码") forState:UIControlStateNormal];
        if ([self.phoneTextField.text length]) {
            [self.getSmsButton setTitleColor:BMXCOLOR_HEX(0xffffff) forState:UIControlStateNormal];
        } else {
            [self.getSmsButton setTitleColor:BMXCOLOR_HEX(0x333333) forState:UIControlStateNormal];
        }
        self.getSmsButton.enabled = YES;
    }
//    [self.getSmsButton sizeToFit];
}

- (void)timeLast:(NSTimeInterval)lastTime {
    [self.getSmsButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"nsec_later_to_resend", @"%.0f秒后重发"), lastTime] forState:UIControlStateNormal];
}

- (void)timeFinish {
    [self p_configGetSmsButtonWith:NO];
}

- (void)transformButtonClick:(UIButton *)button  {
    if (self.transformButtonClick) {
        self.transformButtonClick();
    }
}

- (void)closeButtonClick:(UIButton *)button {
    if (self.closeButtonClick) {
        self.closeButtonClick();
    }
}

- (void)p_clickTipButton:(UIButton *)button {
    
    if (self.tipButtonClick) {
        self.tipButtonClick();
    }
}

- (void)confirmButtonClicked:(UIButton *)button {
    
    if (self.confrimButtonClick) {
        self.confrimButtonClick(self.username,self.password);
    }
}

- (void)commitButtonClicked:(UIButton *)button {
    NSString *username = self.usernameTextField.text;
    NSString *password = self.passwordTextField.text;
    NSString *phone = self.phoneTextField.text;
    NSString *vertifyCode = self.smsTextField.text;
    
    if (self.commitButonClick) {
        self.commitButonClick(username, password, phone, vertifyCode);
    }
}

- (void)otherLoginButtonClick:(UIButton *)button {
    
    if (self.ohterLoginButtonClick) {
        self.ohterLoginButtonClick();
    }
    
}

- (void)scanLoginButtonClicked:(UIButton *)button {
    if (self.scanLoginButtonClick) {
        self.scanLoginButtonClick();
    }
}

- (void)scanConsuleButtonClicked:(UIButton *)button {
    if (self.scanConsuleButtonClick) {
        self.scanConsuleButtonClick();
    }
}

- (void)editButtonClick:(UIButton *)button {
    MAXLog(@"编辑appid");
    if (self.editAppIDButtonClick) {
        self.editAppIDButtonClick();
    }
}

- (void)smsButtonClicked:(UIButton *)button {
    CaptchaApi *api = [[CaptchaApi alloc] initWithMobile:self.phoneTextField.text];
    [api startWithSuccessBlock:^(ApiResult * _Nullable result) {
        if (result.isOK) {
            [self smsButtonhighlight:YES];
        } else {
            [HQCustomToast showDialog:result.errmsg];
        }

    } failureBlock:^(NSError * _Nullable error) {
        [HQCustomToast showNetworkError];
    }];


}

- (void)textFieldDidChange:(UITextField *)textField {
    if (textField.tag == kUsernameTextFieldTag) {
        self.username = textField.text;
    }else if (textField.tag == kPasswordTextFieldTag){
        self.password = textField.text;
    } else if (textField.tag == kPhoneTextFieldTag) {
        self.phone = textField.text;
    } else if (textField.tag == kSmsTextFieldTag) {
        self.captch = textField.text;
    }
    
    if (self.phone.length > 0) {
        self.getSmsButton.enabled = YES;
//        self.getSmsButton.backgroundColor = BMXCOLOR_HEX(0x0079F4);
    } else {
        self.getSmsButton.enabled = NO;
//        self.getSmsButton.backgroundColor = [BMXCOLOR_HEX(0x0079F4) colorWithAlphaComponent:0.1];
    }
    
    if (self.username.length > 0 && self.password.length > 0) {
        self.confirmButton.enabled = YES;
        self.confirmButton.backgroundColor = BMXCOLOR_HEX(0x0079F4);
    }else {
        self.confirmButton.enabled = NO;
        self.confirmButton.backgroundColor = [BMXCOLOR_HEX(0x0079F4) colorWithAlphaComponent:0.1];
    }
    
    if (self.username.length > 0 && self.password.length > 0 && self.phone.length > 0 && self.captch.length > 0 ) {
        self.commitPhoneButton.backgroundColor = BMXCOLOR_HEX(0x0079F4);
        self.commitPhoneButton.enabled = YES;
    } else {
        self.commitPhoneButton.enabled = NO;
        self.commitPhoneButton.backgroundColor = [BMXCOLOR_HEX(0x0079F4) colorWithAlphaComponent:0.1];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self endEditing:YES];
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.font = [UIFont systemFontOfSize:24];
        _titleLabel.textColor = BMXCOLOR_HEX(0x333333);
        [self addSubview:_titleLabel];
        
    }
    return _titleLabel;
}

- (UILabel *)appIDLabel {
    if (!_appIDLabel) {
        _appIDLabel = [[UILabel alloc] init];
        _appIDLabel.textAlignment = NSTextAlignmentLeft;
        _appIDLabel.font = [UIFont systemFontOfSize:12];
        _appIDLabel.textColor = BMXCOLOR_HEX(0x333333);
        [self addSubview:_appIDLabel];
        
    }
    return _appIDLabel;
}

- (UIButton *)editButton {
    if (!_editButton) {
        _editButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_editButton setImage:[UIImage imageNamed:@"appidedit"] forState:UIControlStateNormal];
//        [_editButton setTitle:@"编辑" forState:UIControlStateNormal];
//        _editButton.backgroundColor = BMXCOLOR_HEX(0x0079F4);
        [_editButton addTarget:self action:@selector(editButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        _editButton.layer.masksToBounds = YES;
        _editButton.layer.cornerRadius = 7;
        _editButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_editButton setTitleColor:BMXCOLOR_HEX(0x0079F4) forState:UIControlStateNormal];

        [self addSubview:_editButton];
    }
    return _editButton;
}

- (UITextField *)usernameTextField {
    if (!_usernameTextField) {
        _usernameTextField = [[UITextField alloc] init];
        _usernameTextField.tag = kUsernameTextFieldTag;
//        _usernameTextField.backgroundColor = [BMXCOLOR_HEX(0x999999) colorWithAlphaComponent:0.1];
        _usernameTextField.placeholder = NSLocalizedString(@"enter_username", @"请输入用户名");
        _usernameTextField.font = [UIFont systemFontOfSize:14];
        _usernameTextField.leftViewMode = UITextFieldViewModeAlways;
        _usernameTextField.layer.masksToBounds = YES;
        _usernameTextField.layer.cornerRadius = 12;
        [self addSubview:_usernameTextField];
    }
    return _usernameTextField;
}

- (UITextField *)passwordTextField {
    
    if (!_passwordTextField) {
        _passwordTextField = [[UITextField alloc] init];
        _passwordTextField.tag = kPasswordTextFieldTag;
//        _passwordTextField.backgroundColor = [BMXCOLOR_HEX(0x999999) colorWithAlphaComponent:0.1];
        _passwordTextField.placeholder = NSLocalizedString(@"enter_password", @"请输输入密码");
        _passwordTextField.font = [UIFont systemFontOfSize:14];
        _passwordTextField.leftViewMode = UITextFieldViewModeAlways;
        _passwordTextField.layer.masksToBounds = YES;
        _passwordTextField.layer.cornerRadius = 12;
        _passwordTextField.secureTextEntry = YES;
        [self addSubview:_passwordTextField];
    }
    return _passwordTextField;
}

- (UIView *)usernameTextFieldLine {
    if (!_usernameTextFieldLine) {
        _usernameTextFieldLine = [[UIView alloc] init];
        _usernameTextFieldLine.backgroundColor = kColorC4_5;
        [self addSubview:_usernameTextFieldLine];

    }
    return _usernameTextFieldLine;
}

- (UIView *)passwordTextFieldLine {
    if (!_passwordTextFieldLine) {
        _passwordTextFieldLine = [[UIView alloc] init];
        _passwordTextFieldLine.backgroundColor = kColorC4_5;
        [self addSubview:_passwordTextFieldLine];

    }
    return _passwordTextFieldLine;
}

- (UIButton *)confirmButton {
    
    if (!_confirmButton) {
        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_confirmButton setTitle:self.title forState:UIControlStateNormal];
        _confirmButton.backgroundColor = [BMXCOLOR_HEX(0x0079F4) colorWithAlphaComponent:0.1];
        [_confirmButton setTitleColor:[BMXCOLOR_HEX(0x333333) colorWithAlphaComponent:0.4] forState:UIControlStateDisabled];
        [_confirmButton setTitleColor:BMXCOLOR_HEX(0xffffff) forState:UIControlStateNormal];
        [_confirmButton addTarget:self action:@selector(confirmButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        _confirmButton.layer.masksToBounds = YES;
        _confirmButton.layer.cornerRadius = 12;
        _confirmButton.enabled = NO;
        [self addSubview:_confirmButton];
    }
    return _confirmButton;
}

- (UIView *)phoneTextFieldLine {
    if (!_phoneTextFieldLine) {
        _phoneTextFieldLine = [[UIView alloc] init];
        _phoneTextFieldLine.backgroundColor = kColorC4_5;
        [self addSubview:_phoneTextFieldLine];
    }
    return _phoneTextFieldLine;
}

- (UIView *)smsTextFieldLine {
    if (!_smsTextFieldLine) {
        _smsTextFieldLine = [[UIView alloc] init];
        _smsTextFieldLine.backgroundColor = kColorC4_5;
        [self addSubview:_smsTextFieldLine];
    }
    return _smsTextFieldLine;
}

- (UITextField *)phoneTextField {
    
    if (!_phoneTextField) {
        _phoneTextField = [[UITextField alloc] init];
        _phoneTextField.tag = kUsernameTextFieldTag;
//        _phoneTextField.backgroundColor = [BMXCOLOR_HEX(0x999999) colorWithAlphaComponent:0.1];
        _phoneTextField.placeholder = NSLocalizedString(@"enter_phone_number", @"请输入手机号");
        _phoneTextField.font = [UIFont systemFontOfSize:14];
//        _phoneTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        _phoneTextField.leftViewMode = UITextFieldViewModeAlways;
        _phoneTextField.layer.masksToBounds = YES;
        _phoneTextField.layer.cornerRadius = 12;
        _phoneTextField.tag = kPhoneTextFieldTag;
        [self addSubview:_phoneTextField];
    }
    return _phoneTextField;
}

- (UITextField *)smsTextField {
    
    if (!_smsTextField) {
        _smsTextField = [[UITextField alloc] init];
        _smsTextField.tag = kSmsTextFieldTag;
//        _smsTextField.backgroundColor = [BMXCOLOR_HEX(0x999999) colorWithAlphaComponent:0.1];
        _smsTextField.placeholder = NSLocalizedString(@"enter_your_captcha", @"请输入验证码");
        _smsTextField.font = [UIFont systemFontOfSize:14];
//        _smsTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        _smsTextField.leftViewMode = UITextFieldViewModeAlways;
        _smsTextField.layer.masksToBounds = YES;
        _smsTextField.layer.cornerRadius = 12;
        [self addSubview:_smsTextField];
    }
    return _smsTextField;
}

- (UIButton *)getSmsButton {
    
    if (!_getSmsButton) {
        _getSmsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_getSmsButton setTitle:NSLocalizedString(@"Get_captcha", @"获取验证码") forState:UIControlStateNormal];
        _getSmsButton.titleLabel.font = [UIFont systemFontOfSize:12];
        
//        _getSmsButton.backgroundColor = [BMXCOLOR_HEX(0x0079F4) colorWithAlphaComponent:0.1];
        [_getSmsButton setTitleColor:[BMXCOLOR_HEX(0x333333) colorWithAlphaComponent:0.4] forState:UIControlStateDisabled];
        [_getSmsButton setTitleColor:BMXCOLOR_HEX(0x0079F4) forState:UIControlStateNormal];
        
        
        _getSmsButton.enabled = NO;
        _getSmsButton.layer.masksToBounds = YES;
        _getSmsButton.layer.cornerRadius = 12;
        
        [_getSmsButton addTarget:self action:@selector(smsButtonClicked:) forControlEvents:UIControlEventTouchUpInside];

        [self addSubview:_getSmsButton];
    }
    return _getSmsButton;
}

- (UIButton *)commitPhoneButton {
    if (!_commitPhoneButton) {
        _commitPhoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_commitPhoneButton setTitle:NSLocalizedString(@"Register", @"注册") forState:UIControlStateNormal];
        
        _commitPhoneButton.backgroundColor = [BMXCOLOR_HEX(0x0079F4) colorWithAlphaComponent:0.1];
        [_commitPhoneButton setTitleColor:BMXCOLOR_HEX(0xffffff) forState:UIControlStateNormal];
        [_commitPhoneButton setTitleColor:[BMXCOLOR_HEX(0x333333) colorWithAlphaComponent:0.4] forState:UIControlStateDisabled];
        
        [_commitPhoneButton addTarget:self action:@selector(commitButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        _commitPhoneButton.layer.masksToBounds = YES;
        _commitPhoneButton.layer.cornerRadius = 12;
        _commitPhoneButton.enabled = NO;
        [self addSubview:_commitPhoneButton];
    }
    return _commitPhoneButton;
}

- (UIButton *)scanLoginButton {
    if (!_scanLoginButton) {
        _scanLoginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_scanLoginButton setTitle:NSLocalizedString(@"Scan_QR_Code_to_login", @"扫描二维码登录") forState:UIControlStateNormal];
//        _scanLoginButton.backgroundColor = BMXCOLOR_HEX(0x0079F4);
        [_scanLoginButton setTitleColor:BMXCOLOR_HEX(0x333333) forState:UIControlStateNormal];
        [_scanLoginButton addTarget:self action:@selector(scanLoginButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        _scanLoginButton.layer.masksToBounds = YES;
        _scanLoginButton.layer.cornerRadius = 12;
        [self addSubview:_scanLoginButton];
    }
    return _scanLoginButton;
}
- (UIButton *)closeButton {
    
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setTitle:NSLocalizedString(@"Login_directly", @"直接登录") forState:UIControlStateNormal];
        [_closeButton setTitleColor:BMXCOLOR_HEX(0x04A4A4A) forState:UIControlStateNormal];
        _closeButton.titleLabel.font = [UIFont systemFontOfSize:14];
    }
    return _closeButton;
}

- (UIButton *)tipButton {
    if (_tipButton == nil) {
        _tipButton = [UIButton buttonWithType:UIButtonTypeCustom];
        NSString *str = NSLocalizedString(@"Registration_signifies_acceptance", @"注册即代表同意《用户服务及隐私政策》");
        _tipButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_tipButton setTitle:str forState:UIControlStateNormal];
        _tipButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_tipButton setTitleColor:BMXCOLOR_HEX(0x333333) forState:UIControlStateNormal];
        [_tipButton addTarget:self action:@selector(p_clickTipButton:)
             forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_tipButton];
    }
    return _tipButton;
}
- (UIButton *)scanConsuleButton {
    if (!_scanConsuleButton) {
        _scanConsuleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_scanConsuleButton setImage:[UIImage imageNamed:@"scanbutton"] forState:UIControlStateNormal];
        //        _scanLoginButton.backgroundColor = BMXCOLOR_HEX(0x0079F4);
        [_scanConsuleButton setTitleColor:BMXCOLOR_HEX(0x333333) forState:UIControlStateNormal];
        [_scanConsuleButton addTarget:self action:@selector(scanConsuleButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        _scanConsuleButton.layer.masksToBounds = YES;
        _scanConsuleButton.layer.cornerRadius = 12;
        [self addSubview:_scanConsuleButton];
    }
    return _scanConsuleButton;
}

- (UIView *)wechatLine1 {
    if (!_wechatLine1) {
        _wechatLine1 = [[UIView alloc] init];
        _wechatLine1.backgroundColor = kColorC4_5;
        [self addSubview:_wechatLine1];
    }
    return _wechatLine1;
}

- (UIView *)wechatLine {
    if (!_wechatLine) {
        _wechatLine = [[UIView alloc] init];
        _wechatLine.backgroundColor = kColorC4_5;
        [self addSubview:_wechatLine];
    }
    return _wechatLine;
    
}

- (UILabel *)wechatLabel {
    if (!_wechatLabel) {
        _wechatLabel = [[UILabel alloc] init];
        _wechatLabel.textColor = BMXCOLOR_HEX(0xAFAFAF);
        _wechatLabel.font = [UIFont systemFontOfSize:14];
        _wechatLabel.text = NSLocalizedString(@"Quick_login", @"快捷登录");
        [self addSubview:_wechatLabel];
    }
    return _wechatLabel;
    
}

- (UIButton *)otherLoginButton {
    if (!_otherLoginButton) {
        _otherLoginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_otherLoginButton setImage:[UIImage imageNamed:@"wechat"] forState:UIControlStateNormal];
//        _otherLoginButton.backgroundColor = BMXCOLOR_HEX(0x0079F4);
        [_otherLoginButton addTarget:self action:@selector(otherLoginButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        _otherLoginButton.layer.masksToBounds = YES;
        _otherLoginButton.layer.cornerRadius = 12;
        [self addSubview:_otherLoginButton];
    }
    return _otherLoginButton;
}

- (UIButton *)transformDNSBtn {
    if (!_transformDNSBtn) {
        _transformDNSBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_transformDNSBtn setTitle:NSLocalizedString(@"Switch_DNS", @"切换DNS") forState:UIControlStateNormal];
        [_transformDNSBtn setTitleColor:BMXCOLOR_HEX(0x333333) forState:UIControlStateNormal];
        [_transformDNSBtn addTarget:self action:@selector(transformDNSBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        _transformDNSBtn.layer.masksToBounds = YES;
        _transformDNSBtn.layer.cornerRadius = 10;
        [self addSubview:_transformDNSBtn];
    }
    return _otherLoginButton;
}

- (CodeTimerManager *)codeTimerManager {
    if (_codeTimerManager == nil) {
        _codeTimerManager = [CodeTimerManager sharedTimeManager];
        _codeTimerManager.timeDelegate = self;
    }
    return _codeTimerManager;
}

- (void)removeFromSuperview {
    [super removeFromSuperview];
    [self endEditing:YES];
    [self.codeTimerManager timeStop];

}

@end
