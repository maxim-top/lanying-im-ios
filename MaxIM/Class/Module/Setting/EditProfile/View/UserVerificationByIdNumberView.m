#import "UserVerificationByIdNumberView.h"
#import <Masonry.h>
#import "CaptchaApi.h"
#import "MAXUtils.h"

@interface UserVerificationByIdNumberView ()

@property (nonatomic, strong) UITextField *nameTextfield;
@property (nonatomic, strong) UITextField *idNumberTextfield;
@property (nonatomic, strong) UIButton *skipButton;
@property (nonatomic, strong) UIButton *continueButton;

@end

@implementation UserVerificationByIdNumberView

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUIWithTitleText:@""];
    }
    return self;
}

- (void)setupUIWithTitleText:(NSString *)titleText {
    
    self.backgroundColor = BMXCOLOR_HEX(0xffffff);
    
    [self.nameTextfield mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(84);
        make.left.equalTo(self).offset(48);
        make.right.equalTo(self).offset(-48);
    }];
    
    [self.skipButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.nameTextfield);
        make.bottom.equalTo(self.nameTextfield.mas_top).offset(-15);
        make.height.mas_equalTo(20);
    }];
    bool canSkip = [MAXUtils isOptionalVerification:@"id_card"];
    [self.skipButton setHidden:!canSkip];

    UIView *topLine = [[UIView alloc] init];
    topLine.backgroundColor = BMXCOLOR_HEX(0xB2B2B2);
    [self addSubview:topLine];
    [topLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.nameTextfield);
        make.top.equalTo(self.nameTextfield.mas_bottom).offset(9);
        make.height.mas_equalTo(@1.0);
    }];
    
    [self.idNumberTextfield mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameTextfield);
        make.right.equalTo(self.nameTextfield);
        make.top.equalTo(topLine.mas_bottom).offset(35);
    }];
    
    UIView *bottomLine = [[UIView alloc] init];
    bottomLine.backgroundColor = BMXCOLOR_HEX(0xB2B2B2);
    [self addSubview:bottomLine];
    [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.nameTextfield);
        make.top.equalTo(self.idNumberTextfield.mas_bottom).offset(9);
        make.height.mas_equalTo(@1.0);
    }];
    
    
    self.continueButton.enabled = NO;
    [self.continueButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(bottomLine);
        make.top.equalTo(bottomLine.mas_bottom).offset(40);
        make.height.mas_equalTo(@50.0);
    }];
}

- (void)skipButtonClick {
    if (self.delegate && [self.delegate respondsToSelector:@selector(commitName:idNumber:)]) {
        [self.delegate commitName:@"" idNumber:@""];
    }
}

- (void)continueButtonClick {
    if (self.delegate && [self.delegate respondsToSelector:@selector(commitName:idNumber:)]) {
        [self.delegate commitName:self.nameTextfield.text idNumber:self.idNumberTextfield.text];
    }
}

- (void)textFieldDidChange:(UITextField *)textField {
    
    if (self.nameTextfield.text.length > 0  && self.idNumberTextfield.text.length > 0) {
        self.continueButton.enabled = YES;
        self.continueButton.backgroundColor = BMXCOLOR_HEX(0x00A1E9);
    }else {
        self.continueButton.enabled = NO;
        self.continueButton.backgroundColor = [BMXCOLOR_HEX(0x00A1E9) colorWithAlphaComponent:0.2];
    }
    
}

- (UITextField *)nameTextfield {
    
    if (!_nameTextfield) {
        _nameTextfield = [[UITextField alloc] init];
        _nameTextfield.keyboardType = UIKeyboardTypeNamePhonePad;
        _nameTextfield.autocapitalizationType = UITextAutocapitalizationTypeWords;
        _nameTextfield.autocorrectionType = UITextAutocorrectionTypeNo;
        _nameTextfield.returnKeyType = UIReturnKeyDone;
        _nameTextfield.font = [UIFont systemFontOfSize:14];
        _nameTextfield.placeholder = NSLocalizedString(@"realname_verification_name", @"姓名");
        [self addSubview:_nameTextfield];
        [_nameTextfield addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        
        
    }
    return _nameTextfield;
}

- (UITextField *)idNumberTextfield {
    if (!_idNumberTextfield) {
        _idNumberTextfield = [[UITextField alloc] init];
        _idNumberTextfield.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        _idNumberTextfield.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _idNumberTextfield.autocorrectionType = UITextAutocorrectionTypeNo;
        _idNumberTextfield.font = [UIFont systemFontOfSize:14];
        _idNumberTextfield.placeholder = NSLocalizedString(@"realname_verification_id_number", @"身份证号");
        [self addSubview:_idNumberTextfield];
        [_idNumberTextfield addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        _idNumberTextfield.delegate = self;
    }
    return _idNumberTextfield;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField != _idNumberTextfield) {
        return YES;
    }
    // 1. 限制最大输入长度为18位（中国身份证号标准长度）
    NSString *proposedText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (proposedText.length > 18) {
        return NO;
    }
    
    // 2. 允许输入数字0-9
    NSCharacterSet *numberSet = [NSCharacterSet decimalDigitCharacterSet];
    // 3. 允许输入字母X（包括小写x，后续可统一转为大写）
    NSCharacterSet *allowedCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"Xx0123456789"];
    
    // 4. 检查新输入的字符是否在允许的字符集内
    for (int i = 0; i < [string length]; i++) {
        unichar c = [string characterAtIndex:i];
        if (![allowedCharacterSet characterIsMember:c]) {
            return NO; // 包含非法字符，禁止输入
        }
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField != _idNumberTextfield) {
        return;
    }

    // 输入完成后，将末尾的字母统一转换为大写X，提升格式一致性
    if (textField.text.length > 0) {
        NSString *lastChar = [textField.text substringFromIndex:textField.text.length - 1];
        if ([lastChar isEqualToString:@"x"]) {
            NSString *newText = [textField.text substringToIndex:textField.text.length - 1];
            newText = [newText stringByAppendingString:@"X"];
            textField.text = newText;
        }
    }
}

- (UIButton *)skipButton {
    if (!_skipButton) {
        _skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _skipButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_skipButton setTitle:NSLocalizedString(@"Skip", @"跳过") forState:UIControlStateNormal];
        [_skipButton setTitleColor:BMXCOLOR_HEX(0x4A90E2) forState:UIControlStateNormal];
        [_skipButton addTarget:self action:@selector(skipButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_skipButton];
        [_skipButton setTitleColor:BMXCOLOR_HEX(0x666666) forState:UIControlStateDisabled];
    }
    return _skipButton;
    
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
