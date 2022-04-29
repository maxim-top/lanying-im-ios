//
//  ChangeMobileAlert.m
//  MaxIM
//
//  Created by 韩雨桐 on 2019/12/4.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "ChangeMobileAlert.h"
#import "UIView+BMXframe.h"

NSUInteger kChangeMobileAlertTag = 100030;


@interface ChangeMobileAlert ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subTitleLabel;
@property (nonatomic, strong) UIButton *phonebutton;
@property (nonatomic, strong) UIButton *passwordbutton;
@property (nonatomic, strong) UIView *backgroudView;
@property (nonatomic,copy) NSString *phone;



@end

@implementation ChangeMobileAlert

//+ (void)showAlertWithPhone:(NSString *)phone viewController:(UIViewController<ChangeMobileAlertDelegate> *)vc {
//    ChangeMobileAlert *aler = [[ChangeMobileAlert alloc] initWithFrame:[UIScreen mainScreen].bounds phone:phone];
//    aler.tag = kChangeMobileAlertTag;
//    aler.delegate = vc;
//    [MaxKeyWindow addSubview:aler];
//}
+ (instancetype)alertWithTitle:(NSString *)title
                         Phone:(NSString *)phone  {
    ChangeMobileAlert *aler = [[ChangeMobileAlert alloc] initWithFrame:[UIScreen mainScreen].bounds title:title phone:phone];
    return aler;
}

- (void)show {
    [MaxKeyWindow addSubview:self];
}

- (void)p_remove {
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    UIView *shareView = [MaxKeyWindow viewWithTag:kChangeMobileAlertTag];
    [shareView removeFromSuperview];
    shareView = nil;
    [self removeFromSuperview];
}

- (void)hide {
    [self p_remove];
}

- (instancetype)initWithFrame:(CGRect)frame
                        title:(NSString *)title
                        phone:(NSString *)phone {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = BMXColorAlpha([UIColor grayColor], 0.75);
        self.phone = phone;
        self.subTitleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"You_have_bound_phone_number", @"你已绑定手机号 %@"),phone];
        self.tag = kChangeMobileAlertTag;
        self.titleLabel.text = title;
        [self setupSubview];
    }
    return self;
}

- (void)passwordbuttonClick:(UIButton *)button {
    if (self.delegate && [self.delegate respondsToSelector:@selector(alertDidSelectPasswordButton:)]) {
        [self.delegate alertDidSelectPasswordButton:self];
    }
    
}

- (void)phonebuttonClick:(UIButton *)button {
    if (self.delegate && [self.delegate respondsToSelector:@selector(alertDidSelectCaptchaButton:)]) {
        [self.delegate alertDidSelectCaptchaButton:self];
    }
}

- (void)setupSubview {
    self.backgroudView.bmx_size = CGSizeMake(MAXScreenW - 49 * 2, 222);
    self.backgroudView.bmx_centerX = self.bmx_centerX;
    self.backgroudView.bmx_centerY = self.bmx_centerY;
    
    self.titleLabel.bmx_size = CGSizeMake(self.backgroudView.bmx_width - 20 * 2, 36);
    self.titleLabel.bmx_top = 17;
    self.titleLabel.bmx_centerX = self.bmx_centerX;
    self.titleLabel.bmx_left = 20;

    self.subTitleLabel.bmx_size = CGSizeMake(self.backgroudView.bmx_width - 20 * 2, 36);
    self.subTitleLabel.bmx_top = self.titleLabel.bmx_bottom + 15;
    self.subTitleLabel.bmx_centerX = self.backgroudView.bmx_centerX;
    self.subTitleLabel.bmx_left = 20;
    
    self.phonebutton.bmx_size = CGSizeMake(self.backgroudView.bmx_width - 20 * 2, 36);

    self.phonebutton.bmx_top = self.subTitleLabel.bmx_bottom + 10;
    self.phonebutton.bmx_centerX = self.backgroudView.bmx_centerX;
    self.phonebutton.bmx_left = 20;
    
    self.passwordbutton.bmx_size = CGSizeMake(self.backgroudView.bmx_width - 20 * 2, 36);
    self.passwordbutton.bmx_top = self.phonebutton.bmx_bottom + 10;
    self.passwordbutton.bmx_centerX = self.backgroudView.bmx_centerX;
    self.passwordbutton.bmx_left = 20 ;
}

- (UIView *)backgroudView {
    if (!_backgroudView) {
        _backgroudView = [[UIView alloc] init];
        _backgroudView.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1/1.0];
        _backgroudView.layer.cornerRadius = 10;
        _backgroudView.layer.masksToBounds = YES;
        [self addSubview:_backgroudView];

    }
    return _backgroudView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        [_titleLabel sizeToFit];
        _titleLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:18];
        _titleLabel.textColor =  [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1/1.0];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.backgroudView addSubview:_titleLabel];

    }
    return _titleLabel;
}

- (UILabel *)subTitleLabel {
    if (!_subTitleLabel) {
        _subTitleLabel = [[UILabel alloc] init];
        _subTitleLabel.font =  [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        _subTitleLabel.text = NSLocalizedString(@"Bound_phone_number", @"已绑定手机号：");
        _subTitleLabel.textColor =  [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1/1.0];
        _subTitleLabel.textAlignment = NSTextAlignmentCenter;
        [self.backgroudView addSubview:_subTitleLabel];

    }
    return _subTitleLabel;
}

- (UIButton *)phonebutton {
    if (!_phonebutton) {
        _phonebutton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_phonebutton setTitle:NSLocalizedString(@"by_mobile_captcha", @"通过手机验证码方式") forState:UIControlStateNormal];
        _phonebutton.titleLabel.font =  [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        [_phonebutton setBackgroundColor: [UIColor colorWithRed:0/255.0 green:161/255.0 blue:233/255.0 alpha:1/1.0]];
        [_phonebutton setTitleColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1/1.0] forState:UIControlStateNormal];
        [_phonebutton addTarget:self action:@selector(phonebuttonClick:) forControlEvents:UIControlEventTouchUpInside];
        _phonebutton.titleLabel.textAlignment = NSTextAlignmentCenter;
        _phonebutton.layer.cornerRadius = 8.0;
        [self.backgroudView addSubview:_phonebutton];
        
    }
    return _phonebutton;
}

- (UIButton *)passwordbutton {
    if (!_passwordbutton) {
        _passwordbutton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_passwordbutton setTitle:NSLocalizedString(@"Change_by_password", @"通过密码更换") forState:UIControlStateNormal];
        _passwordbutton.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1/1.0];
        [_passwordbutton setTitleColor:[UIColor colorWithRed:0/255.0 green:161/255.0 blue:233/255.0 alpha:1/1.0] forState:UIControlStateNormal];
        [_passwordbutton addTarget:self action:@selector(passwordbuttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.backgroudView addSubview:_passwordbutton];
        _passwordbutton.titleLabel.font =  [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        _passwordbutton.titleLabel.textAlignment = NSTextAlignmentCenter;
        _passwordbutton.layer.borderColor = [UIColor colorWithRed:0/255.0 green:161/255.0 blue:233/255.0 alpha:1/1.0].CGColor;
        _passwordbutton.layer.cornerRadius = 8.0;
        _passwordbutton.layer.borderWidth = 1;
        
    }
    return _passwordbutton;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self hide]; 
}
@end
