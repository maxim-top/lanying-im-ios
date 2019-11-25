
//
//  RosterSearchViewController.m
//  MaxIM
//
//  Created by hyt on 2018/11/18.
//  Copyright © 2018年 hyt. All rights reserved.
//

#import "RosterSearchViewController.h"
#import "BMXSearchView.h"
#import "ContactTableView.h"
#import "ScanViewController.h"

#import <floo-ios/BMXRoster.h>
#import <floo-ios/BMXClient.h>
#import "UIViewController+CustomNavigationBar.h"

#define SearchViewHeight 56
@interface RosterSearchViewController ()<UITextFieldDelegate>

@property (nonatomic, strong) BMXSearchView *searchView;
@property (nonatomic, strong) ContactTableView *tableview;

@property (nonatomic, strong) BMXClient *client;

@end

@implementation RosterSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupNavBarAndItem];
    [self setupSearchView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addRoster:) name:@"ContanctAddClick" object:nil];
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField {
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    MAXLog(@"%@", textField.text);
    [self.searchView.searchTF endEditing:YES];

    if ([textField.text length]) {
        [self searchByName:[NSString stringWithFormat:@"%@", textField.text]];
//        [self searchById:[NSString stringWithFormat:@"%@", textField.text]];
    }
    return YES;
}

- (void)addRoster:(NSNotification *)noti {
    BMXRoster *roster = noti.object;
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"留言"
                                                                   message:@""
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
                                                         //响应事件
                                                         //得到文本信息
                                                         for(UITextField *text in alert.textFields){
                                                             MAXLog(@"text = %@", text.text);
                                                             [self addRosterId:roster.rosterId reason:[text.text length] ? text.text : @""];
                                                         }
                                                     }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {
                                                             //响应事件
                                                             MAXLog(@"action = %@", alert.textFields);
                                                         }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"请输入申请的留言信息";
    }];
    
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
    
}


#pragma mark - Manager
//通过id搜索好友
- (void)searchById:(NSString *)userId {
    MAXLog(@"通过id搜索好友");
    [[[BMXClient sharedClient] rosterService] searchByRosterId:[userId integerValue] forceRefresh:YES
                                       completion:^(BMXRoster *roster, BMXError *error) {
                                           if (!error) {
                                               NSMutableArray *array = [NSMutableArray arrayWithObject:roster];
                                               [self.tableview refresh:[NSArray arrayWithArray:array]];
                                           }
      
    }];
}

// 通过name搜索好友
- (void)searchByName:(NSString *)name {
    MAXLog(@"通过名字搜索好友");
    [[[BMXClient sharedClient]  rosterService] searchByRoserName:name forceRefresh:NO completion:^(BMXRoster *roster, BMXError *error) {
        if (!error) {
            NSMutableArray *array = [NSMutableArray arrayWithObject:roster];
            [self.tableview refresh:[NSArray arrayWithArray:array]];
        } else {
            [HQCustomToast showWatingWithString:error.errorMessage];
        }
    }];
}

// 添加好友
- (void)addRosterId:(long long)rosterId reason:(NSString *)reason {
    MAXLog(@"%@", [[BMXClient sharedClient] rosterService]);
    [[[BMXClient sharedClient] rosterService] applyAddRoster:rosterId reason:reason completion:^(BMXRoster *roster, BMXError *error) {
        MAXLog(@"%@", roster);
        if (!error) {
            [HQCustomToast showDialog:@"已发送添加好友申请"];
            [self.navigationController popViewControllerAnimated:YES];

        } else {
            [HQCustomToast showDialog:error.errorMessage];
        }
    }];
}

- (void)setTableViewHidden:(BOOL)hidden {
    //配置不隐藏，添加view上
    //配置隐藏，从view移除
#warning - hyt
    if (hidden  == NO) {
        [self tableview];
    } else {
        
    }
}

- (void)clickSearch:(id)sender {
    ScanViewController *vc = [[ScanViewController alloc] init];
    [self.navigationController pushViewController:vc animated: YES];
}

- (void)setupSearchView {
    self.searchView = [BMXSearchView searchView];
    self.searchView.searchTF.delegate = self;
    self.searchView.searchTF.returnKeyType = UIReturnKeySearch;
    [self.view addSubview:self.searchView];
}

- (void)setupNavBarAndItem{
    [self setNavigationBarTitle:@"添加好友" navLeftButtonIcon:@"blackback" navRightButtonTitle:@"扫一扫"];
    [self.navRightButton addTarget:self action:@selector(clickSearch:) forControlEvents:UIControlEventTouchUpInside];
}

- (ContactTableView *)tableview {
    if (!_tableview) {
        CGFloat x = 0;
        CGFloat y = MaxNavHeight + 56+10;
        CGFloat w = MAXScreenW;
        CGFloat h = MAXScreenH - MaxNavHeight - 56;

        _tableview = [[ContactTableView alloc] initWithFrame:CGRectMake(x, y, w, h) style:UITableViewStylePlain];
        [self.view addSubview:_tableview];
    }
    return _tableview;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
