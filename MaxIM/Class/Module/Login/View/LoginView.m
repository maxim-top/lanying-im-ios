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
#import "WXApi.h"

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

@property (nonatomic, strong) UITextView *privacyLabel;
@property (nonatomic, strong) UIButton *privacyButton;

@property (nonatomic, strong) UIButton *termsButton;


@property (nonatomic, strong) UILabel *errorLabel;

@property (nonatomic, strong) UIButton *confirmButton;
@property (nonatomic, strong) UIButton *leftControlBttton;
@property (nonatomic, strong) UIButton *rightControlBttton;
@property (nonatomic, strong) UIView *verticalSepLine;

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
    
    self.titleLabel.bmx_top = NavHeight + 80;
    self.titleLabel.bmx_size = CGSizeMake(280, 40);
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
    
    self.confirmButton.bmx_top = self.passwordTextField.bmx_bottom + 86;
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

- (void)updateConfirmButton{
    if (self.username.length > 0 && self.password.length > 0 &&(!_privacyLabel ||  _privacyCheckButton.selected)) {
        self.confirmButton.enabled = YES;
        self.confirmButton.backgroundColor = BMXCOLOR_HEX(0x0079F4);
    }else {
        self.confirmButton.enabled = NO;
        self.confirmButton.backgroundColor = [BMXCOLOR_HEX(0x0079F4) colorWithAlphaComponent:0.1];
    }
}

- (void)textFieldDidChange:(UITextField *)textField {
    if (textField.tag == kUsernameTextFieldTag) {
        self.username = textField.text;
        [self showErrorText:@""];
    }else if (textField.tag == kPasswordTextFieldTag){
        self.password = textField.text;
    }
    
    if (textField.tag == kUsernameTextFieldTag && [textField.text length] > 0) {
        self.captchButton.enabled = YES;
    }
    [self updateConfirmButton];
}

- (void)smsButtonClicked:(UIButton *)button {
    
    NSString *phoneNum = self.usernameTextField.text;
    if (phoneNum.length <= 0) {
        
        [HQCustomToast showDialog:NSLocalizedString(@"enter_phone_number", @"请输入手机号")];
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
        [self.captchButton setTitle:NSLocalizedString(@"sixtysec_later_to_resend", @"60秒后重发") forState:UIControlStateNormal];
        [self.captchButton setTitleColor:kColorC3_7 forState:UIControlStateNormal];
        self.captchButton.enabled = NO;
    } else {
        [self.captchButton setTitle:NSLocalizedString(@"Get_captcha", @"获取验证码") forState:UIControlStateNormal];
        
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
    [self.captchButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"nsec_later_to_resend", @"%.0f秒后重发"), lastTime] forState:UIControlStateNormal];
}

- (void)timeFinish {
    [self p_configGetSmsButtonWith:NO];
}

#pragma mark - public

- (void)addAppIDLabelButtonClickWithAppid:(NSString *)appId {
    
    self.appIDLabel.text = [NSString stringWithFormat:@"%@", appId];
    self.appIDLabel.bmx_size = CGSizeMake(200, 30);
    [self.appIDLabel sizeToFit];
    
    self.appIDLabel.bmx_top = self.scanConsuleButton.bmx_bottom + 10  ;
    self.appIDLabel.bmx_centerX = self.centerX;
}

- (void)addScanConsuleButton {
    self.scanConsuleButton.bmx_width = 50;
    self.scanConsuleButton.bmx_height = 50;
    self.scanConsuleButton.bmx_top = MAXScreenH - 120;
    self.scanConsuleButton.bmx_centerX = self.centerX - ([WXApi isWXAppInstalled] ? 0 : 50);
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
        leftButton.frame = CGRectMake(0, 0, 180, 20);
        leftButton.titleLabel.textAlignment = NSTextAlignmentRight;
        leftButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [leftButton sizeToFit];
        [self addSubview:leftButton];
        
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [rightButton setTitle:rightButtonName forState:UIControlStateNormal];
        [rightButton addTarget:self action:@selector(rightJumpButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [rightButton setTitleColor:BMXCOLOR_HEX(0x576B95) forState:UIControlStateNormal];
        rightButton.titleLabel.textAlignment = NSTextAlignmentLeft;
        rightButton.titleLabel.font = [UIFont systemFontOfSize:14.0];

        rightButton.frame = CGRectMake(0, 0, 60, 20);
        [rightButton sizeToFit];

        [self addSubview:rightButton];
        
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 20)];
        line.backgroundColor = BMXCOLOR_HEX(0x576B95);
        [self addSubview:line];
        
        int padding = 10;
        int lineWidth = 1;
        int width = leftButton.bmx_width + rightButton.bmx_width + padding * 2 + lineWidth;
        int left = (MAXScreenW - width) / 2;
        
        leftButton.bmx_top = self.confirmButton.bmx_bottom + 18;
        leftButton.bmx_left = left;

        line.bmx_top = self.confirmButton.bmx_bottom + 21;
        line.bmx_centerX = leftButton.bmx_right + padding;
        
        rightButton.bmx_top = self.confirmButton.bmx_bottom + 18;
        rightButton.bmx_left = line.bmx_right + padding;
        
    }
}

- (void)addWechatButton {
    self.otherLoginButton.bmx_top = self.scanConsuleButton.bmx_top;
    self.otherLoginButton.bmx_right = self.scanConsuleButton.bmx_left - self.scanConsuleButton.bmx_width - 50;
    self.otherLoginButton.bmx_width = self.scanConsuleButton.bmx_width;
    self.otherLoginButton.bmx_height = self.scanConsuleButton.bmx_height;

    self.editButton.bmx_size = self.scanConsuleButton.size;
    self.editButton.bmx_top =  self.scanConsuleButton.bmx_top;
    self.editButton.bmx_left = self.scanConsuleButton.bmx_right + ([WXApi isWXAppInstalled] ? 50 : 50);
}

- (void)removeWechatButton {
    [self.otherLoginButton removeFromSuperview];
    _otherLoginButton = nil;
}

- (void)addPrivacyLabel {
    
    self.privacyCheckButton.bmx_top = self.confirmButton.bmx_top - 48;
    self.privacyCheckButton.bmx_left = self.confirmButton.bmx_left;
    
    self.privacyLabel.bmx_top = self.confirmButton.bmx_top - 53;
    self.privacyLabel.bmx_left = self.privacyCheckButton.bmx_right + 10;
    self.privacyLabel.textContainer.lineFragmentPadding = 0;
    self.privacyLabel.textContainerInset = UIEdgeInsetsZero;
}

- (void)addSkipButton {
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(skipButtonClick) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(0, 0, 35, 25);
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    [button setTitle:NSLocalizedString(@"Skip", @"跳过") forState:UIControlStateNormal];
    [button setTitleColor:BMXCOLOR_HEX(0x666666) forState:UIControlStateNormal];
    [self addSubview:button];

    button.bmx_top = self.confirmButton.bmx_bottom + 30 ;
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
    _usernameTextField.layer.borderWidth = errorText.length > 0 ? 1.0 : 0;
}

- (void)inputUserName:(NSString *)name {
    
    self.usernameTextField.text = name;
    self.username = name;
}

- (void)inputPassword:(NSString *)password {
    
    self.passwordTextField.text = password;
    self.password = password;
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

- (void)privacyLinkClick:(NSString *)url{
    if (self.delegate && [self.delegate respondsToSelector:@selector(privacyLinkClick:)]) {
        [self.delegate privacyLinkClick:url];
    }
}

- (void)privacyButtonClick {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(privacyButtonClick)]) {
        [self.delegate privacyButtonClick];
    }
}

- (void)privacyCheckButtonClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self updateConfirmButton];
    if (self.delegate && [self.delegate respondsToSelector:@selector(privacyCheckButtonClick)]) {
        [self.delegate privacyCheckButtonClick];
    }
}

- (void)termsButtonClick {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(termsButtonClick)]) {
        [self.delegate termsButtonClick];
    }
}

- (void)otherLoginButtonClick {
    if (_privacyCheckButton && !_privacyCheckButton.selected) {
        [HQCustomToast showDialog:NSLocalizedString(@"check_first", @"请先点击勾选“我已阅读并同意《用户隐私协议》《用户服务条款》”")];
        return;
    }
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
        _appIDLabel.font = [UIFont systemFontOfSize:16];
        _appIDLabel.textColor = BMXCOLOR_HEX(0x888888);
        [self addSubview:_appIDLabel];
    }
    return _appIDLabel;
}

- (UIButton *)privacyCheckButton {
    
    if (!_privacyCheckButton) {
        _privacyCheckButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_privacyCheckButton setFrame:CGRectMake(0, 0, 20, 20)];
        [_privacyCheckButton setImage:[UIImage imageNamed:@"checkbox_circle_gray"] forState:UIControlStateNormal];
        [_privacyCheckButton setImage:[UIImage imageNamed:@"checkbox_selected_circle"] forState:UIControlStateSelected];
        [_privacyCheckButton addTarget:self action:@selector(privacyCheckButtonClick:) forControlEvents:UIControlEventTouchUpInside];

        [self addSubview:_privacyCheckButton];
    }
    return _privacyCheckButton;
}

- (UITextView *)privacyLabel {
    
    if (!_privacyLabel) {
        _privacyLabel = [[UITextView alloc] init];
        _privacyLabel.textAlignment = NSTextAlignmentLeft;
        _privacyLabel.frame = CGRectMake(0, 0, 250, 36);
        _privacyLabel.font = [UIFont systemFontOfSize:12];
        NSString *text = NSLocalizedString(@"Registration_signifies_your_acceptance", @"我已阅读并同意《用户隐私协议》和《用户服务条款》");
        
        _privacyLabel.linkTextAttributes = @{};

        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:text];
        
        //Set font color
        [attributedText addAttribute:NSForegroundColorAttributeName value:BMXCOLOR_HEX(0x555555) range:NSMakeRange(0, attributedText.length)];

        //Set paragraph line spaceing
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 6;
        [attributedText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attributedText.length)];
        
        NSRange linkRange = [text rangeOfString:NSLocalizedString(@"Doc_User_Privacy_Agreement", @"《用户隐私协议》") options:NSCaseInsensitiveSearch];

        if (linkRange.location != NSNotFound) {
            NSURL *url = [NSURL URLWithString:NSLocalizedString(@"protocol_privacy", @"https://www.lanyingim.com/privacy")];
            [attributedText addAttribute:NSLinkAttributeName value:url range:linkRange];
        }
        
        [attributedText addAttribute:NSForegroundColorAttributeName value:BMXCOLOR_HEX(0x4A90E2) range:linkRange];

        linkRange = [text rangeOfString:NSLocalizedString(@"User_Services_Agreement_bookname", @"《用户服务条款》") options:NSCaseInsensitiveSearch];

        if (linkRange.location != NSNotFound) {
            NSURL *url = [NSURL URLWithString:NSLocalizedString(@"protocol_terms", @"https://www.lanyingim.com/terms")];
            [attributedText addAttribute:NSLinkAttributeName value:url range:linkRange];
        }
        
        [attributedText addAttribute:NSForegroundColorAttributeName value:BMXCOLOR_HEX(0x4A90E2) range:linkRange];

        [_privacyLabel setUserInteractionEnabled:YES];  // 允许用户交互以启用超链接
        _privacyLabel.attributedText = attributedText;

        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [_privacyLabel addGestureRecognizer:tapGesture];
        
        [self addSubview:_privacyLabel];
    
    }
    return _privacyLabel;
    
}

- (NSInteger)characterIndexAt:(CGPoint)point attributedText:(NSAttributedString *)attributedText {
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:attributedText];
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    [textStorage addLayoutManager:layoutManager];
    
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
    [layoutManager addTextContainer:textContainer];
    textContainer.lineFragmentPadding = 0;
    
    NSUInteger glyphIndex = [layoutManager glyphIndexForPoint:point inTextContainer:textContainer];
    NSInteger characterIndex = [layoutManager characterIndexForGlyphAtIndex:glyphIndex];
    
    return characterIndex;
}

- (void)handleTap:(UITapGestureRecognizer *)gestureRecognizer {
    UILabel *label = (UILabel *)gestureRecognizer.view;
    NSAttributedString *attributedText = label.attributedText;
    if (!label || !attributedText) {
        return;
    }

    // 检查点击的位置是否在某个链接范围内
    CGPoint location = [gestureRecognizer locationInView:label];
    NSInteger characterIndex = [self characterIndexAt:location attributedText:attributedText];
    NSDictionary *attributes = [attributedText attributesAtIndex:characterIndex effectiveRange:nil];
    NSURL *url = attributes[NSLinkAttributeName];
    if (url) {
        [self privacyLinkClick: url.absoluteString];
    }
}

- (UIButton *)privacyButton {
    
    if (!_privacyButton) {
        _privacyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _privacyButton.frame = CGRectMake(0, 0, 115, 18);
        _privacyButton.titleLabel.font = [UIFont systemFontOfSize:12];
        _privacyButton.titleLabel.textAlignment = NSTextAlignmentLeft;
        [_privacyButton setTitle:NSLocalizedString(@"Doc_User_Privacy_Agreement", @"《用户隐私协议》") forState:UIControlStateNormal];
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
        [_termsButton setTitle:NSLocalizedString(@"User_Services_Agreement_bookname", @"《用户服务条款》") forState:UIControlStateNormal];
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
        [_editButton setBackgroundImage:[UIImage imageNamed:@"settings"] forState:UIControlStateNormal];
        [_editButton addTarget:self action:@selector(editButtonClick) forControlEvents:UIControlEventTouchUpInside];
        _editButton.layer.masksToBounds = YES;
        _editButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_editButton setTitleColor:BMXCOLOR_HEX(0x0079F4) forState:UIControlStateNormal];
        
        [self addSubview:_editButton];
    }
    return _editButton;
}

- (UIButton *)scanConsuleButton {
    if (!_scanConsuleButton) {
        _scanConsuleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_scanConsuleButton setBackgroundImage:[UIImage imageNamed:@"scan"] forState:UIControlStateNormal];;
        [_scanConsuleButton setTitleColor:BMXCOLOR_HEX(0x333333) forState:UIControlStateNormal];
        [_scanConsuleButton addTarget:self action:@selector(scanConsuleButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        _scanConsuleButton.layer.masksToBounds = YES;
        [self addSubview:_scanConsuleButton];
    }
    return _scanConsuleButton;
}

- (UIButton *)logButton {
    if (!_logButton) {
        _logButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_logButton setTitle:NSLocalizedString(@"View_log", @"查看日志") forState:UIControlStateNormal];;
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
        _usernameTextField.placeholder = NSLocalizedString(@"enter_username", @"请输入用户名");
        _usernameTextField.font = [UIFont systemFontOfSize:14];
        _usernameTextField.leftViewMode = UITextFieldViewModeAlways;
        _usernameTextField.layer.masksToBounds = YES;
        _usernameTextField.layer.cornerRadius = 12;
        _usernameTextField.borderStyle = UITextBorderStyleNone;
        UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, _usernameTextField.frame.size.height)];
        _usernameTextField.leftView = leftView;
        _usernameTextField.leftViewMode = UITextFieldViewModeAlways;
        _usernameTextField.layer.cornerRadius = 5.0;
        _usernameTextField.layer.borderColor = [UIColor redColor].CGColor;
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
        _passwordTextField.placeholder = NSLocalizedString(@"enter_password", @"请输输入密码");
        _passwordTextField.font = [UIFont systemFontOfSize:14];
        _passwordTextField.leftViewMode = UITextFieldViewModeAlways;
        _passwordTextField.layer.masksToBounds = YES;
        _passwordTextField.layer.cornerRadius = 12;
        UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, _usernameTextField.frame.size.height)];
        _passwordTextField.leftView = leftView;
        _passwordTextField.leftViewMode = UITextFieldViewModeAlways;
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
        _errorLabel.frame = CGRectMake(0, 0, MAXScreenW - 96, 38);
        _errorLabel.textColor = BMXCOLOR_HEX(0xD0021B);
        _errorLabel.font = [UIFont systemFontOfSize:12];
        _errorLabel.numberOfLines = 2;
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
        [_captchButton setTitle:NSLocalizedString(@"Get_captcha", @"获取验证码") forState:UIControlStateNormal];
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
//        _smsTextField.placeholder = NSLocalizedString(@"enter_your_captcha", @"请输入验证码");
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
//        [_getSmsButton setTitle:NSLocalizedString(@"Get_captcha", @"获取验证码") forState:UIControlStateNormal];
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

- (UIButton *)otherLoginButton {
    if (!_otherLoginButton) {
        _otherLoginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_otherLoginButton setBackgroundImage:[UIImage imageNamed:@"wechat"] forState:UIControlStateNormal];
        [_otherLoginButton addTarget:self action:@selector(otherLoginButtonClick) forControlEvents:UIControlEventTouchUpInside];
        _otherLoginButton.layer.masksToBounds = YES;
        _otherLoginButton.layer.cornerRadius = 12;
        if ([WXApi isWXAppInstalled]) {
            [self addSubview:_otherLoginButton];
        }
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
