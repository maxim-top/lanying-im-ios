//
//  ChangePasswordView.m
//  MaxIM
//
//  Created by 韩雨桐 on 2020/4/19.
//  Copyright © 2020 hyt. All rights reserved.
//

#import "ChangePasswordView.h"
#import <Masonry.h>

@interface ChangePasswordView ()

@property (nonatomic, strong) UITextField *firstPwdTextfield;
@property (nonatomic, strong) UITextField *secondPwdTextfield;
@property (nonatomic, strong) UIButton *continueButton;

@end

@implementation ChangePasswordView


- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}


- (void)setupUI {
    
    self.backgroundColor = BMXCOLOR_HEX(0xffffff);
    
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.text = NSLocalizedString(@"enter_your_new_password", @"请输入新密码");
        titleLabel.font = [UIFont systemFontOfSize:14];
        titleLabel.textColor = BMXCOLOR_HEX(0x666666);
        [self addSubview:titleLabel];
        
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(48);
            make.top.equalTo(self).offset(34);
        }];
        
        [self.firstPwdTextfield mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(titleLabel.mas_bottom).offset(40);
            make.left.equalTo(self).offset(48);
            make.right.equalTo(self).offset(-48);
        }];
    
    
    
    UIView *topLine = [[UIView alloc] init];
    topLine.backgroundColor = BMXCOLOR_HEX(0xB2B2B2);
    [self addSubview:topLine];
    [topLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.firstPwdTextfield);
        make.top.equalTo(self.firstPwdTextfield.mas_bottom).offset(9);
        make.height.mas_equalTo(@1.0);
    }];
    
    [self.secondPwdTextfield mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.firstPwdTextfield);
        make.right.equalTo(self.firstPwdTextfield);
        make.top.equalTo(topLine.mas_bottom).offset(35);
    }];
    
    UIView *bottomLine = [[UIView alloc] init];
    bottomLine.backgroundColor = BMXCOLOR_HEX(0xB2B2B2);
    [self addSubview:bottomLine];
    [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.firstPwdTextfield);
        make.top.equalTo(self.secondPwdTextfield.mas_bottom).offset(9);
        make.height.mas_equalTo(@1.0);
    }];
    
    
    self.continueButton.enabled = NO;
    [self.continueButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(bottomLine);
        make.top.equalTo(bottomLine.mas_bottom).offset(40);
        make.height.mas_equalTo(@50.0);
    }];
}

- (void)continueButtonClick {
    
    NSLog(@"1 = %@, 2= %@",self.firstPwdTextfield.text, self.secondPwdTextfield.text);
    if (![self.firstPwdTextfield.text isEqualToString:self.secondPwdTextfield.text]) {
        [HQCustomToast showDialog:NSLocalizedString(@"Entered_passwords_differ", @"两次输入密码不一致")];
        return;
    }
    
    if (self.changeBlock) {
        self.changeBlock([self.firstPwdTextfield.text copy]);
    }
}



- (void)textFieldDidChange:(UITextField *)textField {
    
    if (self.firstPwdTextfield.text.length > 0  && self.secondPwdTextfield.text.length > 0) {
        self.continueButton.enabled = YES;
        self.continueButton.backgroundColor = BMXCOLOR_HEX(0x00A1E9);
    }else {
        self.continueButton.enabled = NO;
        self.continueButton.backgroundColor = [BMXCOLOR_HEX(0x00A1E9) colorWithAlphaComponent:0.2];
    }
    
}

- (UITextField *)firstPwdTextfield {
    
    if (!_firstPwdTextfield) {
        _firstPwdTextfield = [[UITextField alloc] init];
        _firstPwdTextfield.secureTextEntry = YES;
        _firstPwdTextfield.font = [UIFont systemFontOfSize:14];
        _firstPwdTextfield.placeholder = NSLocalizedString(@"enter_your_new_password", @"请输入新密码");
        [self addSubview:_firstPwdTextfield];
        [_firstPwdTextfield addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        
        
    }
    return _firstPwdTextfield;
}

- (UITextField *)secondPwdTextfield {
    
    if (!_secondPwdTextfield) {
        _secondPwdTextfield = [[UITextField alloc] init];
        _secondPwdTextfield.secureTextEntry = YES;
        _secondPwdTextfield.font = [UIFont systemFontOfSize:14];
        _secondPwdTextfield.placeholder = NSLocalizedString(@"enter_the_new_password_again", @"请再次输入新密码");
        [self addSubview:_secondPwdTextfield];
        [_secondPwdTextfield addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        
        
    }
    return _secondPwdTextfield;
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

- (void)removeFromSuperview {
    
    [super removeFromSuperview];
    [self endEditing:YES];
    
}

@end
