//
//  BIndPhoneView.m
//  MaxIM
//
//  Created by 韩雨桐 on 2019/12/4.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "BindPhoneView.h"
#import <Masonry.h>
#import "CodeTimerManager.h"
#import "CaptchaApi.h"

@interface BindPhoneView () <TimeProtocol>

@property (nonatomic, strong) UITextField *phoneTextfield;
@property (nonatomic, strong) UITextField *chptchaTextfield;
@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) UIButton *continueButton;
@property (nonatomic, strong) CodeTimerManager *codeTimerManager;

@end

@implementation BindPhoneView



- (instancetype)initWithFrame:(CGRect)frame
                   needTitle:(BOOL)needTitle
                    titleText:(NSString *)titleText {
    
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUIIsNewPhone:needTitle titleText:titleText];
    }
    return self;
    
}


- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUIIsNewPhone:NO titleText:@""];
    }
    return self;
}

- (void)setPhoneNum:(NSString *)phoneNum {
    
    self.phoneTextfield.text = phoneNum;
    self.phoneTextfield.userInteractionEnabled = NO;
    self.phoneTextfield.textColor = BMXCOLOR_HEX(0x666666);
}



- (void)setupUIIsNewPhone:(BOOL)needTitle
                titleText:(NSString *)titleText {
    
    self.backgroundColor = BMXCOLOR_HEX(0xffffff);
    
    if (!needTitle) {
        [self.phoneTextfield mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(84);
            make.left.equalTo(self).offset(48);
            make.right.equalTo(self).offset(-48);
        }];
    }else {
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.text = titleText;
        titleLabel.font = [UIFont systemFontOfSize:14];
        titleLabel.textColor = BMXCOLOR_HEX(0x666666);
        [self addSubview:titleLabel];
        
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(48);
            make.top.equalTo(self).offset(34);
        }];
        
        [self.phoneTextfield mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(titleLabel.mas_bottom).offset(40);
            make.left.equalTo(self).offset(48);
            make.right.equalTo(self).offset(-48);
        }];
    }
    
   
    
    UIView *topLine = [[UIView alloc] init];
    topLine.backgroundColor = BMXCOLOR_HEX(0xB2B2B2);
    [self addSubview:topLine];
    [topLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.phoneTextfield);
        make.top.equalTo(self.phoneTextfield.mas_bottom).offset(9);
        make.height.mas_equalTo(@1.0);
    }];
    
    [self.sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.phoneTextfield);
        make.top.equalTo(topLine.mas_bottom).offset(35);
        make.height.mas_equalTo(20);
        
        
    }];
    
    [self.chptchaTextfield mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.phoneTextfield);
        make.right.equalTo(self.sendButton.mas_left);
        make.top.equalTo(topLine.mas_bottom).offset(35);
    }];
    
    UIView *bottomLine = [[UIView alloc] init];
    bottomLine.backgroundColor = BMXCOLOR_HEX(0xB2B2B2);
    [self addSubview:bottomLine];
    [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.phoneTextfield);
        make.top.equalTo(self.chptchaTextfield.mas_bottom).offset(9);
        make.height.mas_equalTo(@1.0);
    }];
    
    
    self.continueButton.enabled = NO;
    [self.continueButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(bottomLine);
        make.top.equalTo(bottomLine.mas_bottom).offset(40);
        make.height.mas_equalTo(@50.0);
    }];
}

- (void)sendButtonClick {
    
    NSString *phoneNum = self.phoneTextfield.text;
    if (phoneNum.length < 11) {
        [HQCustomToast showDialog:NSLocalizedString(@"enter_a_correct_phone_number", @"请输入正确手机号")];
        return;
    }
    
//    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeGoing) userInfo:nil repeats:YES];
//    if (self.delegate && [self.delegate respondsToSelector:@selector(sendChaptchaWithPhone:)]) {
//        [self.delegate sendChaptchaWithPhone:phoneNum];
//    }
    
    
    CaptchaApi *api = [[CaptchaApi alloc] initWithMobile:self.phoneTextfield.text];
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

- (void)continueButtonClick {
    if (self.delegate && [self.delegate respondsToSelector:@selector(commitPhone:chptcha:)]) {
        [self.delegate commitPhone:self.phoneTextfield.text chptcha:self.chptchaTextfield.text];
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
        self.sendButton.enabled = NO;
        [self.codeTimerManager beginTimeWithTotalTime:[self.codeTimerManager resultTime]];
    }
}

- (void)p_configGetSmsButtonWith:(BOOL)isStart{
    if (![self.codeTimerManager lastTimeIsFinish]) {
        return;
    }
    if (isStart) {
        [self.codeTimerManager beginTimeWithTotalTime:60];
        [self.sendButton setTitle:NSLocalizedString(@"sixtysec_later_to_resend", @"60秒后重发") forState:UIControlStateNormal];
        [self.sendButton setTitleColor:kColorC3_7 forState:UIControlStateNormal];
        self.sendButton.enabled = NO;
    } else {
        [self.sendButton setTitle:NSLocalizedString(@"Get_captcha", @"获取验证码") forState:UIControlStateNormal];
        
        if ([self.phoneTextfield.text length]) {
            [self.sendButton setTitleColor:BMXCOLOR_HEX(0x4a90e2) forState:UIControlStateNormal];
            self.sendButton.enabled = YES;
        } else {
            
            [self.sendButton setTitleColor:[BMXCOLOR_HEX(0x333333) colorWithAlphaComponent:0.4] forState:UIControlStateDisabled];
            self.sendButton.enabled = NO;
        }
    }
}

- (void)timeFinish {
    [self p_configGetSmsButtonWith:NO];
}

- (void)timeLast:(NSTimeInterval)lastTime {
    [self.sendButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"nsec_later_to_resend", @"%.0f秒后重发"), lastTime] forState:UIControlStateNormal];
}

- (void)textFieldDidChange:(UITextField *)textField {
    
    if (self.phoneTextfield.text.length > 0  && self.chptchaTextfield.text.length > 0) {
        self.continueButton.enabled = YES;
        self.continueButton.backgroundColor = BMXCOLOR_HEX(0x00A1E9);
    }else {
        self.continueButton.enabled = NO;
        self.continueButton.backgroundColor = [BMXCOLOR_HEX(0x00A1E9) colorWithAlphaComponent:0.2];
    }
    
}

- (UITextField *)phoneTextfield {
    
    if (!_phoneTextfield) {
        _phoneTextfield = [[UITextField alloc] init];
        _phoneTextfield.keyboardType = UIKeyboardTypePhonePad;
        _phoneTextfield.font = [UIFont systemFontOfSize:14];
        _phoneTextfield.placeholder = NSLocalizedString(@"Phone_number", @"手机号");
        [self addSubview:_phoneTextfield];
        [_phoneTextfield addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        
        
    }
    return _phoneTextfield;
}

- (UITextField *)chptchaTextfield {
    if (!_chptchaTextfield) {
        _chptchaTextfield = [[UITextField alloc] init];
        _chptchaTextfield.keyboardType = UIKeyboardTypePhonePad;
        _chptchaTextfield.font = [UIFont systemFontOfSize:14];
        _chptchaTextfield.placeholder = NSLocalizedString(@"Captcha", @"验证码");
        [self addSubview:_chptchaTextfield];
        [_chptchaTextfield addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
    return _chptchaTextfield;
}

- (UIButton *)sendButton {
    if (!_sendButton) {
        _sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _sendButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_sendButton setTitle:NSLocalizedString(@"Get_captcha", @"获取验证码") forState:UIControlStateNormal];
        [_sendButton setTitleColor:BMXCOLOR_HEX(0x4A90E2) forState:UIControlStateNormal];
        [_sendButton addTarget:self action:@selector(sendButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_sendButton];
//        [_sendButton setTitle:@"60秒后重新发送" forState:UIControlStateDisabled];
        [_sendButton setTitleColor:BMXCOLOR_HEX(0x666666) forState:UIControlStateDisabled];
//        _sendButton.enabled = NO;

    }
    return _sendButton;
    
}

- (UIButton *)continueButton {
    
    if (!_continueButton) {
        _continueButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _continueButton.titleLabel.font = [UIFont systemFontOfSize:16];
        _continueButton.layer.masksToBounds = YES;
        _continueButton.layer.cornerRadius = 12;
        [_continueButton setTitle:NSLocalizedString(@"Continue", @"继续") forState:UIControlStateDisabled];
        [_continueButton setTitle:NSLocalizedString(@"Continue", @"继续") forState:UIControlStateNormal];
        [_continueButton setTitleColor:[BMXCOLOR_HEX(0x333333) colorWithAlphaComponent:0.4] forState:UIControlStateDisabled];
        _continueButton.backgroundColor = [BMXCOLOR_HEX(0x00A1E9) colorWithAlphaComponent:0.2];
        [_continueButton addTarget:self action:@selector(continueButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_continueButton];
    }
    return _continueButton;
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
