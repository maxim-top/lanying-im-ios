//
//  AccountMangementViewController.m
//  MaxIM
//
//  Created by 韩雨桐 on 2019/12/17.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "AccountMangementViewController.h"
#import "UIViewController+CustomNavigationBar.h"
#import "AccountListStorage.h"
#import "AccountInfoTableViewCell.h"
#import "DeviceTableViewCell.h"
#import "IMAcount.h"
#import "IMAcountInfoStorage.h"
#import <floo-ios/BMXClient.h>
#import "AppIDManager.h"
#import "AppDelegate.h"

#import "GetTokenApi.h"
#import "MAXGlobalTool.h"
#import "AccountManagementManager.h"
#import "AccountListStorage.h"

@interface AccountMangementViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *accountArray;
@property (nonatomic, strong) IMAcount *currentAccount;

@end

@implementation AccountMangementViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setUpNavItem];
    [self loadAccountData];
    
    self.currentAccount = [IMAcountInfoStorage loadObject];
}
- (void)loadAccountData {
    NSArray *list = [AccountListStorage loadObject];
    self.accountArray = list;
    
    IMAcount *a = self.accountArray[0];
    [[[BMXClient sharedClient] rosterService] searchByRosterId:[a.usedId integerValue] forceRefresh:YES completion:^(BMXRoster *roster, BMXError *error) {
        
        
    }];
    
    
    [self.tableView reloadData];
}

- (void)setUpNavItem {
    [self setNavigationBarTitle:@"切换账号" navLeftButtonIcon:@"blackback"];
}

- (void)changeNewAccount:(IMAcount *)account{

    [self logoutDealWithData];
    [self loginWithaccount:account];
    
}

- (void)logoutDealWithData {
    
    [AppIDManager clearAppid];
    [IMAcountInfoStorage clearObject];
}

- (void)loginWithaccount:(IMAcount *)account {
    
    [HQCustomToast showWating];
    
    [[BMXClient sharedClient] changeAppID:account.appid completion:^(BMXError * _Nonnull error) {
        if (!error) {
            [self signByaccount:account];
        } else {
            [HQCustomToast hideWating];

            [IMAcountInfoStorage clearObject]; //清除当前存储的账号
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [appDelegate userLogout];
            // 切换失败之后，退出登录状态，但是保存切换后的appid
            [appDelegate reloadAppID:account.appid];
        }
        
    }];
}

- (void)signByaccount:(IMAcount *)account {
        [[BMXClient sharedClient] signInByName:account.userName password:account.password completion:^(BMXError * _Nonnull error) {
            [HQCustomToast hideWating];
                if (!error) {
                    
                    MAXLog(@"登录成功 username = %@ , password = %@",account.userName, account.password);
        //            [self uploadAppIdIfNeededWithUserName:name];
                    
                    [self saveLastLoginAppid];
                    
                    [self getAppTokenWithName:account.userName password:account.password];
                    
                    [self getProfile];
                    
                    [self bindDeviceToken];
                    
                    [self saveIMAcountName:account.userName password:account.password];
                    
                    IMAcount *account = [IMAcountInfoStorage loadObject];
                    account.isLogin = YES;
                    [IMAcountInfoStorage saveObject:account];
                    

                    [UIApplication sharedApplication].delegate.window.rootViewController = [MAXGlobalTool share].rootViewController;
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"loginSuccess" object:nil];
                    
                    [[MAXGlobalTool share].rootViewController addIMListener];
                    
                    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                    [appDelegate userLogout];
                    [[MAXGlobalTool share].rootViewController addIMListener];

                    
                    
                }else {
                    
                    [IMAcountInfoStorage clearObject]; //清除当前存储的账号
                    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                    [appDelegate userLogout];
                    // 切换失败之后，退出登录状态，但是保存切换后的appid
                    [appDelegate reloadAppID:account.appid];
                }
            }];
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    BOOL iscurrentAccount = 
//    
//    if (indexPath.section == 0 || self.tag != 0) {
//        return NO;
//    }
    return YES;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 添加一个删除按钮
    
    UITableViewRowAction *deleteRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除"handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        MAXLog(@"点击了删除");
        IMAcount *account = self.accountArray[indexPath.row];
        
        if ([account.usedId isEqualToString:self.currentAccount.usedId]) {
            [HQCustomToast showDialog:@"不能删除当前账户"];
        } else {
            [self removeAccount:account];

        }
        
    }];
    
    return @[deleteRowAction];
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

- (void)removeAccount:(IMAcount *)account {
    [AccountListStorage removeAccount:account];
    NSMutableArray *arrayM = [NSMutableArray arrayWithArray:self.accountArray];
    [arrayM removeObject:account];
    self.accountArray = [NSArray arrayWithArray:arrayM];
    [self.tableView reloadData];
}

- (void)saveIMAcountName:(NSString *)name password:(NSString *)password {
    
    IMAcount *a = [[IMAcount alloc] init];
    a.isLogin = YES;
    a.password = password;
    a.userName = [NSString stringWithFormat:@"%@", name];
    [IMAcountInfoStorage saveObject: a];
    
}

- (void)bindDeviceToken {
    NSString *deviceToken = [[NSUserDefaults standardUserDefaults] valueForKey:@"deviceToken"];
    if ([deviceToken length]) {
        [[[BMXClient sharedClient] userService] bindDevice:deviceToken completion:^(BMXError *error) {
            MAXLog(@"绑定成功 %@", deviceToken);
        }];
    }
}

- (void)getProfile {
    [[[BMXClient sharedClient] userService] getProfileForceRefresh:YES completion:^(BMXUserProfile *profile, BMXError *aError) {
        if (!aError) {
            IMAcount *account = [IMAcountInfoStorage loadObject];
            account.usedId = [NSString stringWithFormat:@"%lld", profile.userId];
            account.userName = profile.userName;
            [IMAcountInfoStorage saveObject:account];
            account.appid = [[BMXClient sharedClient] sdkConfig].appID;
            [self saveAccountToLoaclListWithaccount:account];
            
            [[[BMXClient sharedClient] userService] downloadAvatarWithProfile:profile thumbnail:YES progress:^(int progress, BMXError *error) {
                
            } completion:^(BMXUserProfile *profile, BMXError *error) {
                
            }];
        }
        
    }];
}

- (void)saveAccountToLoaclListWithaccount:(IMAcount *)account {
    [[AccountManagementManager sharedAccountManagementManager] addAccountUserName:account.userName password:account.password userid:account.usedId appid:account.appid];
}


- (void)getAppTokenWithName:(NSString *)name password:(NSString *)password {
    GetTokenApi *api = [[GetTokenApi alloc] initWithName:name password:password];
    [api startWithSuccessBlock:^(ApiResult * _Nullable result) {
        if (result.isOK) {
            IMAcount *account = [IMAcountInfoStorage loadObject];
            NSDictionary *dic = result.resultData;
            account.token = dic[@"token"];
            [IMAcountInfoStorage saveObject:account];
            MAXLog(@"已获取token");
            
        }
    } failureBlock:^(NSError * _Nullable error) {
        
    }];
}

- (void)saveLastLoginAppid {
    
    BMXSDKConfig *sdkconfig = [[BMXClient sharedClient] sdkConfig];

    [AppIDManager changeAppid:sdkconfig.appID isSave:YES];

    [[NetWorkingManager netWorkingManager] resetHeaderWithAppID:sdkconfig.appID];
    
//    BMXSDKConfig *sdkconfig = [[BMXClient sharedClient] sdkConfig];
//    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    [appDelegate reloadAppID:sdkconfig.appID];

}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.accountArray.count > 0 ? self.accountArray.count : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AccountInfoTableViewCell *cell = [AccountInfoTableViewCell cellWithTableView:tableView];
    IMAcount *account = self.accountArray[indexPath.row];
    
    if ([account.usedId isEqualToString:self.currentAccount.usedId]) {
        [cell.selectImageView setHidden:NO];
    } else {
        [cell.selectImageView setHidden:YES];
    }
    
    cell.titleLabel.text = [NSString stringWithFormat:@"%@ (AppID:%@)",account.userName, account.appid];
    cell.subtitleLabel.text = account.usedId;
    MAXLog(@"====%@",NSStringFromCGRect(cell.titleLabel.frame));
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    IMAcount *account = self.accountArray[indexPath.row];
    if ([account.usedId isEqualToString:self.currentAccount.usedId]) {
        
    } else {
        [self changeNewAccount:account];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 69;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NavHeight, MAXScreenW, MAXScreenH - NavHeight - kTabBarHeight) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

- (NSArray *)accountArray {
    if (!_accountArray) {
        _accountArray = [NSArray array];
    }
    return _accountArray;
}

@end
