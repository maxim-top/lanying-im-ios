//
//  UnbindWechatViewController.m
//  MaxIM
//
//  Created by 韩雨桐 on 2019/12/5.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "UnbindWechatViewController.h"
#import "VerifyPasswordView.h"
#import "UIViewController+CustomNavigationBar.h"

@interface UnbindWechatViewController ()<VerifyPasswordProtocol>

@property (nonatomic, strong) VerifyPasswordView *contentView;

@end

@implementation UnbindWechatViewController

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
    [self setNavigationBarTitle:NSLocalizedString(@"Unbind_WeChat_account", @"解绑微信") navLeftButtonIcon:@"blackback"];
}

- (void)commitWithPassword:(NSString *)password {
 
    MAXLog(@"%@", password);
}

- (VerifyPasswordView *)contentView {
 
    if (!_contentView) {
        _contentView = [[VerifyPasswordView alloc] initWithFrame:CGRectMake(0, NavHeight, MAXScreenW, MAXScreenH - NavHeight) titleText:NSLocalizedString(@"enter_password_to_verify_when_unbinding", @"解绑时，需要输入密码验证") continueButtonName:NSLocalizedString(@"Confirm_to_bind", @"确认绑定")];
        _contentView.delegate = self;
    }
    return _contentView;
}

@end
