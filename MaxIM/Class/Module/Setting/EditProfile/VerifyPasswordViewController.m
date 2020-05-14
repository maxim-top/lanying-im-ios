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
#import "ChangePasswordViewController.h"
#import "PwdChangeVerifyByPasswordApi.h"


@interface VerifyPasswordViewController ()<VerifyPasswordProtocol>

@property (nonatomic, strong) VerifyPasswordView *contentView;

@property (nonatomic,assign) EditType editType;

@end

@implementation VerifyPasswordViewController

- (instancetype)initWithEditType:(EditType)type {
    
    if (self = [super init]) {
        self.editType = type;
    }
    return self;
    
}

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
    [self setNavigationBarTitle:@"验证密码" navLeftButtonIcon:@"blackback"];
}


- (void)commitWithPassword:(NSString *)password {
    
    if (self.editType == EditTypePhone) {
        [self changePhoneWithPassword:password];
    }else {
        [self changePassword:password];
    }
    
}

- (void)changePassword:(NSString *)password {
    
    PwdChangeVerifyByPasswordApi *api = [[PwdChangeVerifyByPasswordApi alloc] initWithPassword:password];
    [api startWithSuccessBlock:^(ApiResult * _Nullable result) {
        if (result.isOK) {
            ChangePasswordViewController *changePwdVC = [[ChangePasswordViewController alloc] init];
            changePwdVC.sign = result.resultData[@"sign"];
            [self.navigationController pushViewController:changePwdVC animated:YES];
        } else {
            [HQCustomToast showDialog:result.errmsg];
        }
    } failureBlock:^(NSError * _Nullable error) {
        [HQCustomToast showNetworkError];

    }];
    
}

- (void)changePhoneWithPassword:(NSString *)password {
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
        [HQCustomToast showNetworkError];

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
