
//
//  LoginCodeImageViewController.m
//  MaxIM
//
//  Created by 韩雨桐 on 2019/4/16.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "LoginCodeImageViewController.h"
#import "UIView+BMXframe.h"
#import "LoginQRCodeInfoApi.h"
#import <ZXingObjC.h>
#import "UIViewController+CustomNavigationBar.h"

@interface LoginCodeImageViewController ()

@property (nonatomic, strong) UIImageView *codeImageView;
@property (nonatomic, strong) UILabel *tipLabel;

@end

@implementation LoginCodeImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self setUpNavItem];
    [self setUpSubview];
    
    [self  getCodeInfo];
}

- (void)getCodeInfo {
    [HQCustomToast showWating];
    LoginQRCodeInfoApi *api = [[LoginQRCodeInfoApi alloc] init];
    [api startWithSuccessBlock:^(ApiResult * _Nullable result) {
        if ([result isOK]) {
            [HQCustomToast hideWating];

            NSDictionary *dic = result.resultData;
            [self configLoginQRCodeWithQRCodeInfo:dic];
        }
    } failureBlock:^(NSError * _Nullable error) {
        [HQCustomToast hideWating];
        [HQCustomToast showDialog:@"网路异常"];
    }];
}

- (void)configLoginQRCodeWithQRCodeInfo:(NSDictionary *)info {
    NSString *data = [NSString stringWithFormat:@"L_%@", info[@"qr_info"]];
    if (![data length]) return;
    
    ZXMultiFormatWriter *writer = [[ZXMultiFormatWriter alloc] init];
    ZXBitMatrix *r = [writer encode:data
                             format:kBarcodeFormatQRCode
                              width:self.codeImageView.frame.size.width
                             height:self.codeImageView.frame.size.width
                              error:nil];
    if (info) {
        ZXImage *image = [ZXImage imageWithMatrix:r];
        self.codeImageView.image = [UIImage imageWithCGImage:image.cgimage];
    } else {
        self.codeImageView.image = nil;
    }
}

- (void)setUpSubview {
    [self codeImageView];
}

- (UIImageView *)codeImageView {
    if (!_codeImageView) {
        _codeImageView = [[UIImageView alloc] init];
        _codeImageView.bmx_top =  MAXScreenH /2.0 - 50;
        _codeImageView.bmx_left = 30;
        _codeImageView.bmx_size = CGSizeMake(MAXScreenW - 100, MAXScreenW - 80);
        [self.view addSubview:_codeImageView];
    }
    return _codeImageView;
}

- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.bmx_top = self.codeImageView.bottom + 20;
        _tipLabel.text = @"扫码登录MaxIM";
        [self.view addSubview:_tipLabel];
    }
    return _tipLabel;
}

- (void)setUpNavItem  {
    [self setNavigationBarTitle:@"我的二维码" navLeftButtonIcon:@"blackback"];
}

@end
