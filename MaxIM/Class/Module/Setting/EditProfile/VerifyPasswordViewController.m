//
//  VerifyPasswordViewController.m
//  MaxIM
//
//  Created by 韩雨桐 on 2019/12/5.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "VerifyPasswordViewController.h"
#import "VerifyPasswordView.h"
#import "UIViewController+CustomNavigationBar.h"
#import "IMAcount.h"
#import "IMAcountInfoStorage.h"
#import "BindNewViewController.h"
#import "UserMobilePrechangeByPasswordApi.h"

@interface VerifyPasswordViewController ()<VerifyPasswordProtocol>

@property (nonatomic, strong) VerifyPasswordView *contentView;

@end

@implementation VerifyPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    [self setUpNavItem];
    [self addContentView];
    
}
- (void)addContentView {
    [self.view addSubview:self.contentView];
}

- (void)setUpNavItem {
    [self setNavigationBarTitle:@"更换手机号" navLeftButtonIcon:@"blackback"];
}


- (void)commitWithPassword:(NSString *)password {
    UserMobilePrechangeByPasswordApi *api = [[UserMobilePrechangeByPasswordApi alloc] initWithPassword:password];
    [api startWithSuccessBlock:^(ApiResult * _Nullable result) {
        if (result.isOK) {
            BindNewViewController *vc = [[BindNewViewController alloc] init];
            vc.sign = result.resultData[@"sign"];

            [self.navigationController pushViewController:vc animated:YES];
        } else {
            [HQCustomToast showDialog:result.errmsg];
        }
        
    } failureBlock:^(NSError * _Nullable error) {
        
    }];
}

- (VerifyPasswordView *)contentView {
    
    if (!_contentView) {
        _contentView = [[VerifyPasswordView alloc] initWithFrame:CGRectMake(0, NavHeight, MAXScreenW, MAXScreenH - NavHeight) titleText:@"登录密码验证身份" continueButtonName:@"继续"];
        _contentView.delegate = self;
    }
    return _contentView;
}

@end
