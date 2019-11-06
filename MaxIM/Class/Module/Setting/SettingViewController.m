
//
//  SettingViewController.m
//  MaxIM
//
//  Created by hyt on 2018/11/19.
//  Copyright © 2018年 hyt. All rights reserved.
//

#import "SettingViewController.h"
#import "SettingTableView.h"

#import "BMXClient.h"


@interface SettingViewController ()

@property (nonatomic, strong) SettingTableView *tableview;

@end

@implementation SettingViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //状态栏改为白色
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
}


- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    //状态栏改为黑色
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
     
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getprofile];

}

- (void)settingRefreshIfNeededToast:(BOOL)isNeed {
    [self getprofileWithToast:isNeed];
}

#pragma mark - manager
- (void)getprofileWithToast:(BOOL)isNeed {
    if (isNeed == YES) {
        [HQCustomToast showWating];
    }
    [[[BMXClient sharedClient] userService] getProfileForceRefresh:NO completion:^(BMXUserProfile *profile, BMXError *aError) {
        [HQCustomToast hideWating];
        if (aError == nil) {
            [self.tableview refeshProfile:profile];
        }
    }];
}

- (void)getprofile {
    [HQCustomToast showWating];
    [[[BMXClient sharedClient] userService] getProfileForceRefresh:NO completion:^(BMXUserProfile *profile, BMXError *aError) {
        [HQCustomToast hideWating];
        if (aError == nil) {
            [self setupTableView];
            [self.tableview refeshProfile:profile];
        }
    }];
}


- (void)setupTableView {
    self.tableview = [[SettingTableView alloc] initWithFrame:CGRectMake(0, 0, MAXScreenW, MAXScreenH - kTabBarHeight) style:UITableViewStylePlain];
    [self.view addSubview:self.tableview];
}

@end
