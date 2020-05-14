//
//  LoginView.m
//  MaxIM
//
//  Created by 韩雨桐 on 2019/11/15.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "LoginView.h"
#import "CodeTimerManager.h"
#import "UIView+BMXframe.h"
#import "CaptchaApi.h"
#import "DropdownListView.h"

#define kUsernameTextFieldTag 1000
#define kPasswordTextFieldTag 1001
#define kPhoneTextFieldTag 1002
#define kSmsTextFieldTag 1003


@interface LoginView () <TimeProtocol>

@property (nonatomic, strong) UILabel *appIDLabel; // show appid
@property (nonatomic, strong) UIButton *editButton; //appid edit
@property (nonatomic, strong) UIButton *scanConsuleButton; // scan button

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UITextField *usernameTextField;
@property (nonatomic, strong) UIView *usernameTextFieldLine;

@property (nonatomic, strong) UITextField *passwordTextField;
@property (nonatomic, strong) UIView *passwordTextFieldLine;
@property (nonatomic, strong) UIButton *safeButton;
@property (nonatomic, strong) UIButton *captchButton;

//@property (nonatomic, strong) UITextField *smsTextField;
//@property (nonatomic, strong) UIView *smsTextFieldLine;
//@property (nonatomic, strong) UIButton *getSmsButton;

@property (nonatomic, strong) UILabel *privacyLabel;
@property (nonatomic, strong) UIButton *privacyButton;

@property (nonatomic, strong) UIButton *termsButton;


@property (nonatomic, strong) UILabel *errorLabel;

@property (nonatomic, strong) UIButton *confirmButton;
@property (nonatomic, strong) UIButton *leftControlBttton;
@property (nonatomic, strong) UIButton *rightControlBttton;
@property (nonatomic, strong) UIView *verticalSepLine;

@property (nonatomic, strong) UIView *wechatLine;
@property (nonatomic, strong) UIView *wechatLine1;
@property (nonatomic, strong) UILabel *wechatLabel;
@property (nonatomic, strong) UIButton *otherLoginButton;

@property (nonatomic,copy) NSString *title;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *password;

@property (nonatomic, strong) CodeTimerManager *codeTimerManager;

@property (nonatomic, strong) UIButton *logButton;

//@property (nonatomic, strong) DropdownListView *tableview;

@end

@implementation LoginView


+ (instancetype)createLoginVieWithTitle:(NSString *)title {
    LoginView *loginView = [[LoginView alloc] initWithFrame:CGRectMake(0, 0, MAXScreenW, MAXScreenH) title:title];
    return loginView;
}

- (instancetype)initWithFrame:(CGRect)frame
                        title:(NSString *)title {
    
    if (self = [super initWithFrame:frame]) {
        
        self.title = title;
        self.titleLabel.text = title;
        [self setupCommonSubviews];
    }
    return self;
}


- (void)setupCommonSubviews {
    
    self.backgroundColor = [UIColor whiteColor];
    
    self.titleLabel.bmx_top = NavHeight + 60;
    self.titleLabel.bmx_size = CGSizeMake(200, 40);
    self.titleLabel.bmx_left = 48;
    
    self.usernameTextField.bmx_top = self.titleLabel.bmx_bottom + 24;
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
    
    self.errorLabel.bmx_left = self.usernameTextFieldLine.bmx_left;
    self.errorLabel.bmx_top = self.usernameTextFieldLine.bmx_top + 2;
    
    self.confirmButton.bmx_top = self.passwordTextField.bmx_bottom + 46;
    self.confirmButton.bmx_left = self.usernameTextField.bmx_left;
    self.confirmButton.bmx_width = self.usernameTextField.bmx_width;
    self.confirmButton.bmx_height = 55;
    
    [self textFieldChangedListener];
   
}


#pragma mark - private
- (void)textFieldChangedListener {

    [self.usernameTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.passwordTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}

- (void)textFieldDidChange:(UITextField *)textField {
    if (textField.tag == kUsernameTextFieldTag) {
        self.username = textField.text;
    }else if (textField.tag == kPasswordTextFieldTag){
        self.password = textField.text;
    }
    
    if (textField.tag == kUsernameTextFieldTag && [textField.text length] > 0) {
        self.captchButton.enabled = YES;
    }
    
    
    if (self.username.length > 0 && self.password.length > 0) {
        self.confirmButton.enabled = YES;
        self.confirmButton.backgroundColor = BMXCOLOR_HEX(0x0079F4);
    }else {
        self.confirmButton.enabled = NO;
        self.confirmButton.backgroundColor = [BMXCOLOR_HEX(0x0079F4) colorWithAlphaComponent:0.1];
    }
}

- (void)smsButtonClicked:(UIButton *)button {
    
    NSString *phoneNum = self.usernameTextField.text;
    if (phoneNum.length <= 0) {
        
        [HQCustomToast showDialog:@"请输入手机号"];
        return;
    }
    
    CaptchaApi *api = [[CaptchaApi alloc] initWithMobile:self.usernameTextField.text];
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

#pragma mark - sms

- (void)p_configGetSmsButtonWith:(BOOL)isStart{
    if (![self.codeTimerManager lastTimeIsFinish]) {
        return;
    }
    if (isStart) {
        [self.codeTimerManager beginTimeWithTotalTime:60];
        [self.captchButton setTitle:@"60秒后重发" forState:UIControlStateNormal];
        [self.captchButton setTitleColor:kColorC3_7 forState:UIControlStateNormal];
        self.captchButton.enabled = NO;
    } else {
        [self.captchButton setTitle:@"获取验证码" forState:UIControlStateNormal];
        
        if ([self.usernameTextField.text length]) {
            [self.captchButton setTitleColor:BMXCOLOR_HEX(0x4a90e2) forState:UIControlStateNormal];
            self.captchButton.enabled = YES;
        } else {
            
            [self.captchButton setTitleColor:[BMXCOLOR_HEX(0x333333) colorWithAlphaComponent:0.4] forState:UIControlStateDisabled];
            self.captchButton.enabled = NO;
        }
    }
}

- (void)smsButtonhighlight:(BOOL)highlight {
    if (highlight == YES) {
        [self p_configCodeInitialStatus];
        [self p_configGetSmsButtonWith:YES];
    }
}

- (void)p_configCodeInitialStatus {
    if (![self.codeTimerManager lastTimeIsFinish]) {
        self.captchButton.enabled = NO;
        [self.codeTimerManager beginTimeWithTotalTime:[self.codeTimerManager resultTime]];
    }
}

- (void)timeLast:(NSTimeInterval)lastTime {
    [self.captchButton setTitle:[NSString stringWithFormat:@"%.0f秒后重发", lastTime] forState:UIControlStateNormal];
}

- (void)timeFinish {
    [self p_configGetSmsButtonWith:NO];
}

#pragma mark - public

- (void)addAppIDLabelButtonClickWithAppid:(NSString *)appId {
    
    self.appIDLabel.text = [NSString stringWithFormat:@"APPID: %@", appId];
    self.appIDLabel.bmx_size = CGSizeMake(200, 30);
    [self.appIDLabel sizeToFit];
    

    
    self.appIDLabel.bmx_top = NavHeight + 4  ;
    self.appIDLabel.bmx_left = 48;
    
    self.editButton.bmx_size = CGSizeMake(50, 30);
    self.editButton.bmx_centerY =  self.appIDLabel.bmx_centerY;
    self.editButton.bmx_left = self.appIDLabel.bmx_right + 5;
    
}

- (void)addScanConsuleButton {
    self.scanConsuleButton.bmx_width = 30;
    self.scanConsuleButton.bmx_height = 30;
    self.scanConsuleButton.bmx_top = NavHeight -3 ;
    self.scanConsuleButton.bmx_left = MAXScreenW - 100;
}

- (void)addLogButton {
    self.logButton.bmx_width = 100;
    self.logButton.bmx_height = 30;
    self.logButton.bmx_top = self.confirmButton.bmx_centerY + 100;
    self.logButton.bmx_centerX = MAXScreenW/2.0;

}


- (void)setPlaceHoderWithText:(NSString *)firstText
                   SecondText:(NSString *)secondText {
    
    self.usernameTextField.placeholder = firstText;
    self.passwordTextField.placeholder = secondText;
}

- (void)setConfirmButtonTitle:(NSString *)title {
    
    [self.confirmButton setTitle:title forState:UIControlStateNormal];
    [self.confirmButton setTitle:title forState:UIControlStateDisabled];
}

- (void)addJumpButtonLeftButton:(NSString *)leftButtonName
                    rightButton:(NSString *)rightButtonName {
    
    if (rightButtonName.length == 0) {
        
        UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [leftButton setTitle:leftButtonName forState:UIControlStateNormal];
        [leftButton addTarget:self action:@selector(leftJumpButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [leftButton setTitleColor:BMXCOLOR_HEX(0x576B95) forState:UIControlStateNormal];
        leftButton.frame = CGRectMake(0, 0, 200, 20);
        leftButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:leftButton];
        leftButton.bmx_top = self.confirmButton.bmx_bottom + 18;
        leftButton.bmx_centerX = self.bmx_centerX;
        leftButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
        
    }else {
        
        UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [leftButton setTitle:leftButtonName forState:UIControlStateNormal];
        [leftButton addTarget:self action:@selector(leftJumpButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [leftButton setTitleColor:BMXCOLOR_HEX(0x576B95) forState:UIControlStateNormal];
        leftButton.frame = CGRectMake(0, 0, 120, 20);
        leftButton.titleLabel.textAlignment = NSTextAlignmentRight;
        leftButton.titleLabel.font = [UIFont systemFontOfSize:14.0];

        [self addSubview:leftButton];
        
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [rightButton setTitle:rightButtonName forState:UIControlStateNormal];
        [rightButton addTarget:self action:@selector(rightJumpButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [rightButton setTitleColor:BMXCOLOR_HEX(0x576B95) forState:UIControlStateNormal];
        rightButton.titleLabel.textAlignment = NSTextAlignmentLeft;
        rightButton.titleLabel.font = [UIFont systemFontOfSize:14.0];

        rightButton.frame = CGRectMake(0, 0, 60, 20);
        [self addSubview:rightButton];
        
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 20)];
        line.backgroundColor = BMXCOLOR_HEX(0x576B95);
        [self addSubview:line];
        
        line.bmx_top = self.confirmButton.bmx_bottom + 18;
        line.bmx_centerX = self.bmx_centerX + 10;
        
        leftButton.bmx_top = self.confirmButton.bmx_bottom + 18;
        leftButton.bmx_right = line.bmx_left + 3;
        
        rightButton.bmx_top = self.confirmButton.bmx_bottom + 18;
        rightButton.bmx_left = line.bmx_right + 5;
        
    }
}

- (void)addWechatButton {
    
    
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
}

- (void)removeWechatButton {
    [self.otherLoginButton removeFromSuperview];
    [self.wechatLine removeFromSuperview];
    [self.wechatLine1 removeFromSuperview];
    [self.wechatLabel removeFromSuperview];
    
    _otherLoginButton = nil;
    _wechatLine = nil;
    _wechatLine1 = nil;
    _wechatLabel = nil;
    
}

- (void)addPrivacyLabel {
    
    self.privacyLabel.bmx_bottom = self.confirmButton.bmx_top - 5;
    self.privacyLabel.bmx_left = self.confirmButton.bmx_left;
    
    self.privacyButton.bmx_centerY = self.privacyLabel.bmx_centerY;
    self.privacyButton.bmx_left = self.privacyLabel.bmx_right;
    
    self.termsButton.bmx_centerY = self.privacyLabel.bmx_centerY;
    self.termsButton.bmx_left = self.privacyButton.bmx_right;

}

- (void)addSkipButton {
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(skipButtonClick) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(0, 0, 35, 25);
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    [button setTitle:@"跳过" forState:UIControlStateNormal];
    [button setTitleColor:BMXCOLOR_HEX(0x333333) forState:UIControlStateNormal];
    [self addSubview:button];

    button.bmx_top = NavHeight - 12 ;
    button.bmx_left = MAXScreenW - 100;
    
}

- (void)showCaptchButton {
    
    if (@available(iOS 10.0, *)) {
        self.usernameTextField.keyboardType = self.passwordTextField.keyboardType = UIKeyboardTypeASCIICapableNumberPad;
    } else {
        // Fallback on earlier versions
        self.usernameTextField.keyboardType = self.passwordTextField.keyboardType = UIKeyboardTypeNumberPad;
    }
    
    self.passwordTextField.rightView = self.captchButton;
    self.passwordTextField.secureTextEntry = NO;
}

- (void)showErrorText:(NSString *)errorText {
    
    self.errorLabel.text = errorText;
    
}

- (void)inputUserName:(NSString *)name {
    
    self.usernameTextField.text = name;
    self.username = name;
}



#pragma mark - action


- (NSString *)firstTextfieldText {
    return self.usernameTextField.text;
}

- (NSString *)secondTextfieldText {
    return self.passwordTextField.text;
}


- (void)safeButtonClieck {
    
    self.passwordTextField.secureTextEntry = !self.passwordTextField.secureTextEntry;
    [self.safeButton setSelected:!self.safeButton.isSelected];
}

- (void)leftJumpButtonClick {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(leftJumpButtonClick)]) {
        [self.delegate leftJumpButtonClick];
    }
}

- (void)rightJumpButtonClick {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(rightJumpButtonClick)]) {
        [self.delegate rightJumpButtonClick];
    }
}

- (void)privacyButtonClick {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(privacyButtonClick)]) {
        [self.delegate privacyButtonClick];
    }
}

- (void)termsButtonClick {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(termsButtonClick)]) {
        [self.delegate termsButtonClick];
    }
}

- (void)otherLoginButtonClick {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(wechatButtonClick)]) {
        [self.delegate wechatButtonClick];
    }
}

- (void)confirmButtonClicked {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(confirmButtonClick)]) {
        [self.delegate confirmButtonClick];
    }
}

- (void)scanConsuleButtonClicked {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(scanButtonClick)]) {
        [self.delegate scanButtonClick];
    }
}

- (void)logButtonClicked {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(logButtonClick)]) {
        [self.delegate logButtonClick];
    }
}


- (void)editButtonClick {

    if (self.delegate && [self.delegate respondsToSelector:@selector(editButtonClick)]) {
        [self.delegate editButtonClick];
    }
}

- (void)skipButtonClick {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(skipButtonClick)]) {
        [self.delegate skipButtonClick];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self endEditing:YES];
}

#pragma mark - lazy load


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

// app config
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

- (UILabel *)privacyLabel {
    
    if (!_privacyLabel) {
        _privacyLabel = [[UILabel alloc] init];
        _privacyLabel.textAlignment = NSTextAlignmentRight;
        _privacyLabel.frame = CGRectMake(0, 0, 100, 18);
        _privacyLabel.font = [UIFont systemFontOfSize:12];
        _privacyLabel.textColor = BMXCOLOR_HEX(0x4A4A4A);
        _privacyLabel.text = @"注册即代表您同意";
        [self addSubview:_privacyLabel];
    
    }
    return _privacyLabel;
    
}

- (UIButton *)privacyButton {
    
    if (!_privacyButton) {
        _privacyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _privacyButton.frame = CGRectMake(0, 0, 115, 18);
        _privacyButton.titleLabel.font = [UIFont systemFontOfSize:12];
        _privacyButton.titleLabel.textAlignment = NSTextAlignmentLeft;
        [_privacyButton setTitle:@"《用户隐私协议》" forState:UIControlStateNormal];
        [_privacyButton setTitleColor:BMXCOLOR_HEX(0x4A90E2) forState:UIControlStateNormal];
        [_privacyButton addTarget:self action:@selector(privacyButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [_privacyButton sizeToFit];

        [self addSubview:_privacyButton];
    }
    return _privacyButton;
}

- (UIButton *)termsButton {
    if (!_termsButton) {
        _termsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _termsButton.frame = CGRectMake(0, 0, 115, 18);
        _termsButton.titleLabel.font = [UIFont systemFontOfSize:12];
        _termsButton.titleLabel.textAlignment = NSTextAlignmentLeft;
        [_termsButton setTitle:@"《用户服务条款》" forState:UIControlStateNormal];
        [_termsButton setTitleColor:BMXCOLOR_HEX(0x4A90E2) forState:UIControlStateNormal];
        [_termsButton addTarget:self action:@selector(termsButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [_termsButton sizeToFit];
        [self addSubview:_termsButton];
    }
    return _termsButton;
}

- (UIButton *)editButton {
    if (!_editButton) {
        _editButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_editButton setImage:[UIImage imageNamed:@"appidedit"] forState:UIControlStateNormal];
        [_editButton addTarget:self action:@selector(editButtonClick) forControlEvents:UIControlEventTouchUpInside];
        _editButton.layer.masksToBounds = YES;
        _editButton.layer.cornerRadius = 7;
        _editButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_editButton setTitleColor:BMXCOLOR_HEX(0x0079F4) forState:UIControlStateNormal];
        
        [self addSubview:_editButton];
    }
    return _editButton;
}

- (UIButton *)scanConsuleButton {
    if (!_scanConsuleButton) {
        _scanConsuleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_scanConsuleButton setImage:[UIImage imageNamed:@"scanbutton"] forState:UIControlStateNormal];;
        [_scanConsuleButton setTitleColor:BMXCOLOR_HEX(0x333333) forState:UIControlStateNormal];
        [_scanConsuleButton addTarget:self action:@selector(scanConsuleButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        _scanConsuleButton.layer.masksToBounds = YES;
        _scanConsuleButton.layer.cornerRadius = 12;
        [self addSubview:_scanConsuleButton];
    }
    return _scanConsuleButton;
}

- (UIButton *)logButton {
    if (!_logButton) {
        _logButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_logButton setTitle:@"查看日志" forState:UIControlStateNormal];;
        [_logButton setTitleColor:BMXCOLOR_HEX(0x333333) forState:UIControlStateNormal];
        [_logButton addTarget:self action:@selector(logButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        _logButton.layer.masksToBounds = YES;
        _logButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [self addSubview:_logButton];
    }
    return _logButton;
}


//login input
- (UITextField *)usernameTextField {
    if (!_usernameTextField) {
        _usernameTextField = [[UITextField alloc] init];
        _usernameTextField.tag = kUsernameTextFieldTag;
        _usernameTextField.placeholder = @"请输入用户名";
        _usernameTextField.font = [UIFont systemFontOfSize:14];
        _usernameTextField.leftViewMode = UITextFieldViewModeAlways;
        _usernameTextField.layer.masksToBounds = YES;
        _usernameTextField.layer.cornerRadius = 12;
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:@"" forState:UIControlStateNormal];
        [button setBackgroundColor:[UIColor redColor]];
        [self addSubview:_usernameTextField];
    }
    return _usernameTextField;
}

- (UITextField *)passwordTextField {
    
    if (!_passwordTextField) {
        _passwordTextField = [[UITextField alloc] init];
        _passwordTextField.tag = kPasswordTextFieldTag;
        _passwordTextField.placeholder = @"请输输入密码";
        _passwordTextField.font = [UIFont systemFontOfSize:14];
        _passwordTextField.leftViewMode = UITextFieldViewModeAlways;
        _passwordTextField.layer.masksToBounds = YES;
        _passwordTextField.layer.cornerRadius = 12;
        _passwordTextField.secureTextEntry = YES;
        _passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _passwordTextField.rightView = self.safeButton;
        _passwordTextField.rightViewMode = UITextFieldViewModeAlways;
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

- (UILabel *)errorLabel {
    
    if (!_errorLabel) {
        _errorLabel = [[UILabel alloc] init];
        _errorLabel.frame = CGRectMake(0, 0, MAXScreenW - 96, 18);
        _errorLabel.textColor = BMXCOLOR_HEX(0xD0021B);
        _errorLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:_errorLabel];
    }
    return _errorLabel;
}

- (UIButton *)safeButton {
    
    if (!_safeButton) {
        _safeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _safeButton.frame = CGRectMake(0, 0, 30, 30);
        [_safeButton setImage:[UIImage imageNamed:@"sl_EyeClose"] forState:UIControlStateNormal];
        [_safeButton setImage:[UIImage imageNamed:@"sl_EyeOpen"] forState:UIControlStateSelected];

        [_safeButton addTarget:self action:@selector(safeButtonClieck) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _safeButton;
}

- (UIButton *)captchButton{
    if (!_captchButton) {
        _captchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _captchButton.frame = CGRectMake(0, 0, 120, 40);
        [_captchButton addTarget:self action:@selector(smsButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_captchButton setTitle:@"获取验证码" forState:UIControlStateNormal];
        [_captchButton setTitleColor:[BMXCOLOR_HEX(0x333333) colorWithAlphaComponent:0.4] forState:UIControlStateDisabled];
        [_captchButton setTitleColor:BMXCOLOR_HEX(0x4a90e2) forState:UIControlStateNormal];
        _captchButton.enabled = NO;
    }
    return _captchButton;
}

- (UIButton *)confirmButton {
    
    if (!_confirmButton) {
        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _confirmButton.backgroundColor = [BMXCOLOR_HEX(0x0079F4) colorWithAlphaComponent:0.1];
        [_confirmButton setTitleColor:[BMXCOLOR_HEX(0x333333) colorWithAlphaComponent:0.4] forState:UIControlStateDisabled];
        [_confirmButton setTitleColor:BMXCOLOR_HEX(0xffffff) forState:UIControlStateNormal];
        [_confirmButton addTarget:self action:@selector(confirmButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        _confirmButton.layer.masksToBounds = YES;
        _confirmButton.layer.cornerRadius = 12;
        _confirmButton.enabled = NO;
        [self addSubview:_confirmButton];
    }
    return _confirmButton;
}


//- (UIView *)smsTextFieldLine {
//    if (!_smsTextFieldLine) {
//        _smsTextFieldLine = [[UIView alloc] init];
//        _smsTextFieldLine.backgroundColor = kColorC4_5;
//        [self addSubview:_smsTextFieldLine];
//    }
//    return _smsTextFieldLine;
//}
//
//- (UITextField *)smsTextField {
//
//    if (!_smsTextField) {
//        _smsTextField = [[UITextField alloc] init];
//        _smsTextField.tag = kSmsTextFieldTag;
//        //        _smsTextField.backgroundColor = [BMXCOLOR_HEX(0x999999) colorWithAlphaComponent:0.1];
//        _smsTextField.placeholder = @"请输入验证码";
//        _smsTextField.font = [UIFont systemFontOfSize:14];
//        //        _smsTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
//        _smsTextField.leftViewMode = UITextFieldViewModeAlways;
//        _smsTextField.layer.masksToBounds = YES;
//        _smsTextField.layer.cornerRadius = 12;
//        [self addSubview:_smsTextField];
//    }
//    return _smsTextField;
//}

//- (UIButton *)getSmsButton {
//    
//    if (!_getSmsButton) {
//        _getSmsButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_getSmsButton setTitle:@"获取验证码" forState:UIControlStateNormal];
//        _getSmsButton.titleLabel.font = [UIFont systemFontOfSize:12];
//        
//        //        _getSmsButton.backgroundColor = [BMXCOLOR_HEX(0x0079F4) colorWithAlphaComponent:0.1];
//        [_getSmsButton setTitleColor:[BMXCOLOR_HEX(0x333333) colorWithAlphaComponent:0.4] forState:UIControlStateDisabled];
//        [_getSmsButton setTitleColor:BMXCOLOR_HEX(0x0079F4) forState:UIControlStateNormal];
//        
//        
//        _getSmsButton.enabled = NO;
//        _getSmsButton.layer.masksToBounds = YES;
//        _getSmsButton.layer.cornerRadius = 12;
//        
//        [_getSmsButton addTarget:self action:@selector(smsButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//        
//        [self addSubview:_getSmsButton];
//    }
//    return _getSmsButton;
//}

// 微信登录Block
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
        _wechatLabel.text = @"快捷登录";
        [self addSubview:_wechatLabel];
    }
    return _wechatLabel;
    
}

- (UIButton *)otherLoginButton {
    if (!_otherLoginButton) {
        _otherLoginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_otherLoginButton setImage:[UIImage imageNamed:@"wechat"] forState:UIControlStateNormal];
        [_otherLoginButton addTarget:self action:@selector(otherLoginButtonClick) forControlEvents:UIControlEventTouchUpInside];
        _otherLoginButton.layer.masksToBounds = YES;
        _otherLoginButton.layer.cornerRadius = 12;
        [self addSubview:_otherLoginButton];
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

//- (DropdownListView *)tableview {
//    if (!_tableview) {
//        CGFloat x = 0;
//        CGFloat y = CGRectGetMaxY(self.usernameTextField.frame);
//        CGFloat w = MAXScreenW;
//        CGFloat h = 49 * 5;
//
//        _tableview = [[DropdownListView alloc] initWithFrame:CGRectMake(x, y, w, h) style:UITableViewStylePlain];
//        [self addSubview:_tableview];
//    }
//    return _tableview;
//}


- (void)removeFromSuperview {
    [super removeFromSuperview];
    [self endEditing:YES];
    [self.codeTimerManager timeStop];
    
}

- (void)dealloc {
    self.delegate = nil;
}

@end
