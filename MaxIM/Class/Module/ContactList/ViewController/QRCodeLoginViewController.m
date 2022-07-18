//
//  QRCodeLoginViewController.m
//  MaxIM
//
//  Created by 韩雨桐 on 2019/4/25.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "QRCodeLoginViewController.h"
#import "UIView+BMXframe.h"
#import "QRCodeLoginApi.h"

@interface QRCodeLoginViewController ()

@property (nonatomic,copy) NSString *info;


@end

@implementation QRCodeLoginViewController

- (instancetype)initWithInfo:(NSString *)info {
    if (self = [super init]) {
        self.info = info;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addSubview];
}


- (void)addSubview {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(MAXScreenW / 2.0 - 100 /2.0, 200, 100, 80)];
    imageView.backgroundColor = [UIColor redColor];
    [self.view addSubview:imageView];
    

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(MAXScreenW / 2.0 - 100 /2.0, imageView.bmx_bottom + 10, 100, 40)];
    label.text = NSLocalizedString(@"MaxIM_login_confirmation", @"Lanying IM登录确认");
    [self.view addSubview:label];
    
    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [loginButton setTitle:NSLocalizedString(@"Confirm_to_login", @"确认登录") forState:UIControlStateNormal];
    loginButton.backgroundColor = BMXCOLOR_HEX(0xF7E700);
    [loginButton setTitleColor:BMXCOLOR_HEX(0x333333) forState:UIControlStateNormal];
    [loginButton addTarget:self action:@selector(loginButtonClick) forControlEvents:UIControlEventTouchUpInside];
    loginButton.layer.masksToBounds = YES;
    loginButton.layer.cornerRadius = 12;
    [self.view addSubview:loginButton];
}


- (void)loginButtonClick {
    [self login];
}

- (void)login {
    QRCodeLoginApi *api = [[QRCodeLoginApi alloc] initWithQRCode:self.info];
    [api startWithSuccessBlock:^(ApiResult * _Nullable result) {
        if (result.isOK) {
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
            
        }
        
    } failureBlock:^(NSError * _Nullable error) {
        
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
