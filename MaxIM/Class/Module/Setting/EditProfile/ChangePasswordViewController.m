//
//  ChangePasswordViewController.m
//  MaxIM
//
//  Created by 韩雨桐 on 2020/4/19.
//  Copyright © 2020 hyt. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "ChangePasswordView.h"
#import "UIViewController+CustomNavigationBar.h"

#import "PwdChangeApi.h"

@interface ChangePasswordViewController ()

@property (nonatomic, strong) ChangePasswordView *contentView;

@end

@implementation ChangePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addContentView];
    [self setUpNavItem];
}

- (void)addContentView {
    
    [self.view addSubview:self.contentView];
    __weak ChangePasswordViewController *weakSelf = self;
    self.contentView.changeBlock = ^(NSString * _Nonnull newPassword) {
        [weakSelf changePasswordApi:newPassword];
    };
}

- (void)setUpNavItem {
    [self setNavigationBarTitle:@"修改密码" navLeftButtonIcon:@"blackback"];
}

- (void)changePasswordApi:(NSString *)newPassword {
    
    PwdChangeApi *api = [[PwdChangeApi alloc] initWithPassword:newPassword newPasswordCheck:newPassword sign:self.sign];
    [api startWithSuccessBlock:^(ApiResult * _Nullable result) {
        if (result.isOK) {
            [self.navigationController popToRootViewControllerAnimated:YES];
        } else {
            [HQCustomToast showDialog:result.errmsg];
        }
        
    } failureBlock:^(NSError * _Nullable error) {
        [HQCustomToast showNetworkError];

    }];
    
}

- (ChangePasswordView *)contentView {
    
    if (!_contentView) {
        _contentView = [[ChangePasswordView alloc] initWithFrame:CGRectMake(0, NavHeight, MAXScreenW, MAXScreenH - NavHeight)];
    }
    return _contentView;
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
