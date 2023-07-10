//
//  VerifyPasswordView.m
//  MaxIM
//
//  Created by 韩雨桐 on 2019/12/5.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "VerifyPasswordView.h"
#import <Masonry.h>


@interface VerifyPasswordView ()

@property (nonatomic, strong) UITextField *textfield;
@property (nonatomic, strong) UIButton *continueButton;

@end

@implementation VerifyPasswordView


- (instancetype)initWithFrame:(CGRect)frame
                    titleText:(NSString *)titleText
           continueButtonName:(NSString *)buttonName {
    
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUIWithTitleText:titleText continueButtonName:buttonName];
    }
    return self;
    
}

- (void)setupUIWithTitleText:(NSString *)titleText
          continueButtonName:(NSString *)buttonName {
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = titleText;
    titleLabel.font = [UIFont systemFontOfSize:14];
    titleLabel.textColor = BMXCOLOR_HEX(0x666666);
    [self addSubview:titleLabel];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(48);
        make.top.equalTo(self).offset(34);
    }];
    
    [self.textfield mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(40);
        make.left.equalTo(self).offset(48);
        make.right.equalTo(self).offset(-48);
    }];
    
    UIView *topLine = [[UIView alloc] init];
    topLine.backgroundColor = BMXCOLOR_HEX(0xB2B2B2);
    [self addSubview:topLine];
    [topLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.textfield);
        make.top.equalTo(self.textfield.mas_bottom).offset(9);
        make.height.mas_equalTo(@1);
    }];
    
    self.continueButton.enabled = NO;
    [self.continueButton setTitle:buttonName forState:UIControlStateNormal];
    [self.continueButton setTitle:buttonName forState:UIControlStateDisabled];
    [self.continueButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(topLine);
        make.top.equalTo(topLine.mas_bottom).offset(40);
        make.height.mas_equalTo(39);
    }];
    
}


- (void)continueButtonClick {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(commitWithPassword:)]) {
        [self.delegate commitWithPassword:self.textfield.text];
    }
}



- (void)textFieldDidChange:(UITextField *)textField {
    
    if (self.textfield.text.length > 0) {
        self.continueButton.enabled = YES;
        self.continueButton.backgroundColor = BMXCOLOR_HEX(0x00A1E9);
    }else {
        self.continueButton.enabled = NO;
        self.continueButton.backgroundColor = [BMXCOLOR_HEX(0x00A1E9) colorWithAlphaComponent:0.2];
    }
    
}

- (UITextField *)textfield {
    
    if (!_textfield) {
        _textfield = [[UITextField alloc] init];
        _textfield.secureTextEntry = YES;
        _textfield.font = [UIFont systemFontOfSize:14];
        _textfield.placeholder = NSLocalizedString(@"Enter_login_password", @"输入登录密码");
        _textfield.clearButtonMode = UITextFieldViewModeWhileEditing;
        [self addSubview:_textfield];
        [_textfield addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        
        
    }
    return _textfield;
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



@end
