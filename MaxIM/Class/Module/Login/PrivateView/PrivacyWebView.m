//
//  PrivacyWebView.m
//  MaxIM
//
//  Created by 韩雨桐 on 2019/11/15.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "PrivacyWebView.h"
#import <WebKit/WebKit.h>

#define PYScreenBounds ([UIScreen mainScreen].bounds)
#define PYScreenWidth  ([UIScreen mainScreen].bounds.size.width)
#define PYScreenHeight ([UIScreen mainScreen].bounds.size.height)
#define PYRGB(r, g, b) ([UIColor colorWithRed:r / 255.0 green:g / 255.0 blue:b / 255.0 alpha:1])

@interface PrivacyWebView ()

@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *closeButton;

@property (nonatomic, strong) WKWebView *webView API_AVAILABLE(ios(8.0));

@end

@implementation PrivacyWebView

- (instancetype)initWithFrame:(CGRect)frame PrivacyUrl:(NSString *)pricyUrl {
    if (self = [self initWithFrame:frame]) {
        [self loadPricyUrl:pricyUrl];
    }

    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.titleView.backgroundColor = PYRGB(249, 249, 249);
    self.titleLabel.text = @"用户隐私协议";
    self.closeButton.userInteractionEnabled = true;
}

- (void)loadPricyUrl:(NSString *)pricyUrl {
    NSURL *url = [NSURL URLWithString:pricyUrl];
    if (@available(iOS 8.0, *)) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    }
}

- (void)closeView {
    [UIImageView animateWithDuration:0.25f animations:^{
        CGRect rect = self.frame;
        rect.origin.y = PYScreenHeight;
        self.frame = rect;
    }];
}

#pragma mark - getter

- (UIView *)titleView {
    if (!_titleView) {
        _titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, PYScreenWidth, [self navigationBarHeight])];
        [self addSubview:_titleView];
    }
    return _titleView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, [self navigationBarHeight] - 44, PYScreenWidth, 44)];
        _titleLabel.font = [UIFont boldSystemFontOfSize:16];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.titleView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_closeButton setTitle:@"关闭" forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeView) forControlEvents:UIControlEventTouchUpInside];
        [_closeButton sizeToFit];
        _closeButton.frame = CGRectMake(PYScreenWidth - _closeButton.frame.size.width - 20, [self navigationBarHeight] - 44, _closeButton.frame.size.width, 44);
        [self.titleView addSubview:_closeButton];
    }
    return _closeButton;
}

- (WKWebView *)webView  API_AVAILABLE(ios(8.0))
{
    if (!_webView) {
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, [self navigationBarHeight], PYScreenWidth, PYScreenHeight - [self navigationBarHeight])];
        [self addSubview:_webView];
    }
    return _webView;
}

- (CGFloat)navigationBarHeight {
    if (@available(iOS 11.0, *)) {
        UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
        if (mainWindow.safeAreaInsets.bottom > 0.0) {
            return 88;
        }
    }
    if (UIDevice.currentDevice.userInterfaceIdiom != UIUserInterfaceIdiomPhone) {
        return 64;
    }
    return 64;
}

@end
