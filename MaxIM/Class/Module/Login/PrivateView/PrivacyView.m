//
//  PrivacyView.m
//  MaxIM
//
//  Created by 韩雨桐 on 2019/11/15.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "PrivacyView.h"
#import "PrivacyWebView.h"

#define PYScreenBounds ([UIScreen mainScreen].bounds)
#define PYScreenWidth  ([UIScreen mainScreen].bounds.size.width)
#define PYScreenHeight ([UIScreen mainScreen].bounds.size.height)
#define PYRGB(r, g, b) ([UIColor colorWithRed:r / 255.0 green:g / 255.0 blue:b / 255.0 alpha:1])

@interface PrivacyView ()

/** 隐私协议的地址 */
@property (nonatomic, copy) NSString *privacyUrl;
/** title */
@property (nonatomic, copy) NSString *title;
/** 不同意 */
@property (nonatomic, copy) NSString *cancelButtonTitle;
/** 同意 */
@property (nonatomic, copy) NSString *otherButtonTitle;
/** 遮罩View */
@property (nonatomic, strong) UIView *shadeView;
/** 标题 Label */
@property (nonatomic, strong) UILabel *titleLabel;
/** message Label */
@property (nonatomic, strong) UILabel *messageLabel;
/** 不同意 */
@property (nonatomic, strong) UIButton *cancelButton;
/** 同意 */
@property (nonatomic, strong) UIButton *otherButton;
/** 协议 */
@property (nonatomic, strong) UIButton *touchButton;

@property (nonatomic, strong) PrivacyWebView *webView;

@property (nonatomic, weak) UIView *supView;

// 自定义参数
@property (nonatomic, strong) UIColor *cancelBtnTextColor;
@property (nonatomic, strong) UIColor *otherBtnTextColor;
@property (nonatomic, strong) UIColor *otherBtnBgColor;
@property (nonatomic, strong) UIColor *linkTextColor;
@property (nonatomic, strong) UIFont *cancelBtnTextFont;
@property (nonatomic, strong) UIFont *otherBtnTextFont;

@end

@implementation PrivacyView

static NSString *userStaticKey;

+ (BOOL)needShowPrivacyWithMaxTimeInterval:(NSTimeInterval)maxTimeInterVal
                                 staticKey:(NSString *)staticKey {
    BOOL hasShow = NO;
    userStaticKey = staticKey;
    if ([[NSDate date] timeIntervalSince1970] > maxTimeInterVal && maxTimeInterVal >= 0) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:userStaticKey];
    }
    hasShow = [[NSUserDefaults standardUserDefaults] boolForKey:userStaticKey];
    return !hasShow;
}

+ (void)showPrivacyWithMaxTimeInterval:(NSTimeInterval)maxTimeInterVal
                                  view:(UIView *)view
                             staticKey:(NSString *)staticKey
                            privacyUrl:(nullable NSString *)privacyUrl
                              delegate:(nullable id<PrivacyProtocol>)delegate;
{
    if ([PrivacyView needShowPrivacyWithMaxTimeInterval:maxTimeInterVal
                                                staticKey:staticKey]) {
        PrivacyView *privacy = [[PrivacyView alloc] initWithCancelButtonTitle:@"不同意"
                                                                 otherButtonTitle:@"同意"
                                                                       privacyUrl:privacyUrl
                                                                         delegate:delegate];
        privacy.supView = view;
        [privacy showWith:view];
    }
}

- (instancetype _Nullable)initWithCancelButtonTitle:(nullable NSString *)cancelButtonTitle
                                   otherButtonTitle:(nullable NSString *)otherButtonTitle
                                         privacyUrl:(nullable NSString *)privacyUrl
                                           delegate:(nullable id<PrivacyProtocol>)delegate {
    if (self = [super initWithFrame:CGRectZero]) {
        if (delegate) {
            self.delegate = delegate;
        }
        self.title = [NSBundle mainBundle].infoDictionary[@"CFBundleDisplayName"];
        self.cancelButtonTitle = [cancelButtonTitle copy] ? : @"不同意";
        self.otherButtonTitle = [otherButtonTitle copy] ? : @"同意";
        self.privacyUrl = privacyUrl;

        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = [UIColor whiteColor];
    [self.shadeView addSubview:self];
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 10;

    [self addSubview:self.titleLabel];
    [self addSubview:self.messageLabel];
    [self addSubview:self.cancelButton];
    [self addSubview:self.otherButton];

    NSString *text1 = [NSString stringWithFormat:@"感谢您使用“%@”！当您开始使用本软件时，我们可能会对您的部分个人信息进行收集、使用和共享。请您仔细阅读《%@用户隐私协议》并确定了解我们对您个人信息的处理规则，包括：\n\n", self.title, self.title];
    NSString *text2 = @"我们可能收集的信息\n我们可能如何使用信息\n您如何访问和控制自己的个人信息\n信息安全\n未成年人信息的保护\n\n";
    NSString *text3 = [NSString stringWithFormat:@"如果您同意《%@用户隐私协议》请点击“同意”并开始使用我们的产品和服务，我们尽全力保护您的个人信息安全。", self.title];

    NSString *allStr = [NSString stringWithFormat:@"%@%@%@", text1, text2, text3];
    NSMutableAttributedString *detail = [[NSMutableAttributedString alloc] initWithString:allStr];

    NSRange range1 = [allStr rangeOfString:text1];
    NSRange range2 = [allStr rangeOfString:text2];
    NSRange range3 = [allStr rangeOfString:text3];

    NSString *text4 = [NSString stringWithFormat:@"《%@用户隐私协议》", self.title];
    NSRange range4 = [text3 rangeOfString:text4];

    [detail setAttributes:@{ NSFontAttributeName: [UIFont systemFontOfSize:13], NSForegroundColorAttributeName: PYRGB(51, 51, 51) } range:range2];
    [detail addAttributes:@{ NSFontAttributeName: [UIFont boldSystemFontOfSize:13], NSForegroundColorAttributeName: PYRGB(51, 51, 51) } range:range1];
    [detail addAttributes:@{ NSFontAttributeName: [UIFont systemFontOfSize:12], NSForegroundColorAttributeName: PYRGB(102, 102, 102) } range:range3];
    //协议
    [detail addAttributes:@{ NSForegroundColorAttributeName: self.linkTextColor } range:NSMakeRange(range3.location + range4.location, range4.length)];
    [detail addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(range3.location + range4.location, range4.length)];

    self.messageLabel.attributedText = detail;

    CGFloat w = PYScreenWidth * 0.8 - 50;
    CGSize size = [detail boundingRectWithSize:CGSizeMake(w, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    NSMutableAttributedString *subStr = [[NSMutableAttributedString alloc] initWithString:text3];
    CGSize downSize = [subStr boundingRectWithSize:CGSizeMake(w, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    self.touchButton.frame = CGRectMake(0, 0, w, downSize.height);
    self.messageLabel.frame = CGRectMake(25 /2.0, 56, w, size.height);
    self.touchButton.frame = CGRectMake(0, self.messageLabel.frame.size.height - downSize.height, w, downSize.height);
}

- (void)selectButtonClick:(UIButton *)btn {
    if (btn.tag == 1) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:userStaticKey];
        if ([self.delegate respondsToSelector:@selector(pvivacyViewConfirmClick:)]) {
            [self.delegate pvivacyViewConfirmClick:self];
        }
        [self dismiss];
    } else {
        [self selectCancel];
    }
}

- (void)selectCancel {
    [self dismiss];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:[NSString stringWithFormat:@"您需同意并接受《%@用户隐私协议》全部条款后才可使用我们的服务", self.title] preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf = self;
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"下一步" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
        [weakSelf showWith:weakSelf.supView];
    }];
    [alert addAction:action];
    [[UIApplication sharedApplication].delegate.window.rootViewController presentViewController:alert animated:true completion:nil];
}

#pragma mark - TYAttributedLabelDelegate
- (void)touchButtonClick:(UIButton *)btn {
    if (self.delegate && [self.delegate respondsToSelector:@selector(linkClick:)]) {
        [self.delegate linkClick:self];
    } else {
        if (self.privacyUrl.length > 0) {
            [self showWbview];
        }
    }
}

#pragma mark - 布局

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat w = PYScreenWidth * 0.8;
    CGFloat btnH = 36;
    CGFloat btnMargin = 6;
    CGFloat btnLeftMargin = 25;
    CGFloat btnLeftMargin1 = 25/2.0;

    CGFloat btnW = (w - 2 * btnLeftMargin - btnMargin) / 2.0;

    self.titleLabel.frame = CGRectMake(btnLeftMargin1, 24, w - 2 * btnLeftMargin, 20);
    self.cancelButton.frame = CGRectMake(btnLeftMargin1, CGRectGetMaxY(self.messageLabel.frame) + 18, btnW, btnH);
    self.otherButton.frame = CGRectMake(CGRectGetMaxX(self.cancelButton.frame) + btnMargin, self.cancelButton.frame.origin.y, btnW, btnH);
    self.frame = CGRectMake(0, 0, w, CGRectGetMaxY(self.otherButton.frame) + btnLeftMargin *2 );
    self.center = self.shadeView.center;
}

- (void)showWith:(UIView *)view {
    self.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
    __weak typeof(self) weakSelf = self;
    
//    [UIView animateWithDuration:3 animations:^{
//        [weakSelf dismiss];
//        weakSelf.transform = CGAffineTransformIdentity;
    self.shadeView.frame = view.frame;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
         [view addSubview:self.shadeView];
    });
}

- (void)dismiss {
    
    [self.shadeView removeFromSuperview];
//
//    NSEnumerator *subviewsEnum = [[UIApplication sharedApplication].delegate.window.rootViewController.view.subviews reverseObjectEnumerator];
//    for (UIView *subview in subviewsEnum) {
//        if (subview.tag == 1000) {
//            [subview removeFromSuperview];
//        }
//    }
}

#pragma mark - WebView

- (void)showWbview {
    [UIImageView animateWithDuration:0.25f animations:^{
        CGRect frame = self.webView.frame;
        frame.origin.y = 0;
        self.webView.frame = frame;
    }];
}

- (void)closeView {
}

#pragma mark - UIProtocol

- (UIColor *)cancelBtnTextColor {
    UIColor *color;
    if (self.delegate && [self.delegate respondsToSelector:@selector(privacyViewGetCancelBtnTextColor:)]) {
        color = [self.delegate privacyViewGetCancelBtnTextColor:self];
    }
    return color ? color : PYRGB(51, 51, 51);
}

- (UIColor *)otherBtnTextColor {
    UIColor *color;
    if (self.delegate && [self.delegate respondsToSelector:@selector(privacyViewGetOtherBtnTextColor:)]) {
        color = [self.delegate privacyViewGetOtherBtnTextColor:self];
    }
    return color ? color : PYRGB(255, 255, 255);
}

- (UIColor *)otherBtnBgColor {
    UIColor *color;
    if (self.delegate && [self.delegate respondsToSelector:@selector(privacyViewGetOtherBtnBgColor:)]) {
        color = [self.delegate privacyViewGetOtherBtnBgColor:self];
    }
    return color ? color : PYRGB(250, 39, 59);
}

- (UIColor *)linkTextColor {
    UIColor *color;
    if (self.delegate && [self.delegate respondsToSelector:@selector(privacyViewLinkTextColor:)]) {
        color = [self.delegate privacyViewLinkTextColor:self];
    }
    return color ? color : PYRGB(250, 39, 59);
}

- (UIFont *)cancelBtnTextFont {
    UIFont *font;
    if (self.delegate && [self.delegate respondsToSelector:@selector(privacyViewGetCancelBtnTextFont:)]) {
        font = [self.delegate privacyViewGetCancelBtnTextFont:self];
    }
    return font ? font : [UIFont fontWithName:@"PingFang-SC-Medium" size:15];
}

- (UIFont *)otherBtnTextFont {
    UIFont *font;
    if (self.delegate && [self.delegate respondsToSelector:@selector(pvivacyViewGetOtherBtnTextFont:)]) {
        font = [self.delegate pvivacyViewGetOtherBtnTextFont:self];
    }
    return font ? font : [UIFont fontWithName:@"PingFang-SC-Medium" size:15];
}

#pragma mark - Setter

- (void)setCancelButtonTitle:(NSString *)cancelButtonTitle {
    _cancelButtonTitle = cancelButtonTitle;
    [self.cancelButton setTitle:cancelButtonTitle forState:UIControlStateNormal];
}

- (void)setOtherButtonTitle:(NSString *)otherButtonTitle {
    _otherButtonTitle = otherButtonTitle;
    [self.otherButton setTitle:otherButtonTitle forState:UIControlStateNormal];
}

#pragma mark - Getter

- (UIView *)shadeView {
    if (!_shadeView) {
        _shadeView = [[UIView alloc] initWithFrame:PYScreenBounds];
        _shadeView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        _shadeView.tag = 1000;
    }
    return _shadeView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = [NSString stringWithFormat:@"%@用户隐私协议", self.title];
        _titleLabel.textColor = PYRGB(51, 51, 51);
        _titleLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:19];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (UILabel *)messageLabel {
    if (!_messageLabel) {
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.numberOfLines = 0;
        _messageLabel.userInteractionEnabled = true;
        _messageLabel.font = [UIFont systemFontOfSize:13.f];
        _messageLabel.backgroundColor = [UIColor whiteColor];
        [_messageLabel addSubview:self.touchButton];
    }
    return _messageLabel;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelButton setTitle:self.cancelButtonTitle forState:UIControlStateNormal];
        [_cancelButton setTitleColor:self.cancelBtnTextColor forState:UIControlStateNormal];
        _cancelButton.titleLabel.font = self.cancelBtnTextFont;
        [_cancelButton addTarget:self action:@selector(selectButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        _cancelButton.tag = 0;
        _cancelButton.layer.borderColor = PYRGB(151, 151, 151).CGColor;
        _cancelButton.layer.borderWidth = 0.5;
        _cancelButton.layer.cornerRadius = 2.5;
        _cancelButton.layer.masksToBounds = YES;
    }
    return _cancelButton;
}

- (UIButton *)touchButton {
    if (!_touchButton) {
        _touchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_touchButton setBackgroundColor:[UIColor colorWithWhite:0.667 alpha:0]];
        [_touchButton addTarget:self action:@selector(touchButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _touchButton;
}

- (UIButton *)otherButton {
    if (!_otherButton) {
        _otherButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_otherButton setTitle:self.otherButtonTitle forState:UIControlStateNormal];
        [_otherButton setTitleColor:self.otherBtnTextColor forState:UIControlStateNormal];
        _otherButton.backgroundColor = self.otherBtnBgColor;
        _otherButton.layer.cornerRadius = 2.5;
        _otherButton.layer.masksToBounds = YES;
        _otherButton.titleLabel.font = self.otherBtnTextFont;
        [_otherButton addTarget:self action:@selector(selectButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        _otherButton.tag = 1;
    }
    return _otherButton;
}

- (PrivacyWebView *)webView {
    if (!_webView) {
        _webView = [[PrivacyWebView alloc] initWithFrame:CGRectMake(0, PYScreenHeight, PYScreenWidth, PYScreenHeight)
                                                PrivacyUrl:self.privacyUrl];
        [self.shadeView addSubview:_webView];
    }
    return _webView;
}

@end
