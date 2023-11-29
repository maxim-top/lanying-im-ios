
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

#import <floo-ios/floo_proxy.h>
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
        if ([self isNumberString: textField.text]) {
            [self searchById:[NSString stringWithFormat:@"%@", textField.text]];
        } else{
            [self searchByName:[NSString stringWithFormat:@"%@", textField.text]];
        }
    }
    return YES;
}

- (void)addRoster:(NSNotification *)noti {
    BMXRosterItem *roster = noti.object;
    NSString *authQuestion = roster.authQuestion;
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:authQuestion.length>0 ? NSLocalizedString(@"Friend_verification_question", @"好友验证问题") : NSLocalizedString(@"Leave_a_message", @"留言")
                                                                   message:authQuestion
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", @"确定") style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
                                                         //响应事件
                                                         //得到文本信息
                                                         for(UITextField *text in alert.textFields){
                                                             MAXLog(@"text = %@", text.text);
                                                             if (authQuestion.length>0){
                                                                 [self addRosterId:roster.rosterId authAnswer:[text.text length] ? text.text : @""];
                                                             }else{
                                                                 [self addRosterId:roster.rosterId reason:[text.text length] ? text.text : @""];
                                                             }
                                                         }
                                                     }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"取消") style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {
                                                             //响应事件
                                                             MAXLog(@"action = %@", alert.textFields);
                                                         }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = authQuestion.length>0 ? NSLocalizedString(@"enter_answer", @"请输入答案") : NSLocalizedString(@"enter_message_for_group_application", @"请输入申请的留言信息");
    }];
    
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
    
}


#pragma mark - Manager
//通过id搜索好友
- (void)searchById:(NSString *)userId {
    MAXLog(@"通过id搜索好友");
    [[[BMXClient sharedClient] rosterService] searchWithRosterId:[userId integerValue] forceRefresh:YES
                                       completion:^(BMXRosterItem *roster, BMXError *error) {
        if (!error) {
            NSMutableArray *array = [NSMutableArray arrayWithObject:roster];
            [self.tableview refresh:[NSArray arrayWithArray:array]];
        } else if (error.errorCode == BMXErrorCode_InvalidParam){
            [HQCustomToast showDialog:NSLocalizedString(@"enter_a_correct_user_id", @"请输入正确的用户ID")];
        } else {
            [HQCustomToast showDialog:[error description]];
        }
    }];

}

- (BOOL)isNumberString: (NSString *)string {
    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
    
    if (string.length > 0) {
        return NO;
    }
    
    return YES;
}
// 通过name搜索好友
- (void)searchByName:(NSString *)name {
    MAXLog(@"通过名字搜索好友");
    [[[BMXClient sharedClient]  rosterService] searchWithName:name forceRefresh:YES completion:^(BMXRosterItem *roster, BMXError *error) {
        if (!error) {
            NSMutableArray *array = [NSMutableArray arrayWithObject:roster];
            [self.tableview refresh:[NSArray arrayWithArray:array]];
        } else if (error.errorCode == BMXErrorCode_InvalidParam){
            [HQCustomToast showDialog:NSLocalizedString(@"enter_a_correct_username", @"请输入正确的用户名")];
        } else {
            [HQCustomToast showDialog:[error description]];
        }
    }];
}

// 添加好友
- (void)addRosterId:(long long)rosterId reason:(NSString *)reason {
    [[[BMXClient sharedClient] rosterService] applyWithRosterId:rosterId message:reason completion:^(BMXError *error) {
        MAXLog(@"%lld", rosterId);
        if (!error) {
            [HQCustomToast showDialog:NSLocalizedString(@"Friend_request_sent", @"已发送添加好友申请")];
            [self.navigationController popViewControllerAnimated:YES];

        } else {
            [HQCustomToast showDialog:[error description]];
        }
    }];
}

// 添加好友
- (void)addRosterId:(long long)rosterId authAnswer:(NSString *)authAnswer {
    [[[BMXClient sharedClient] rosterService] applyWithRosterId:rosterId message:@"" authAnswer:authAnswer completion:^(BMXError *error) {
        MAXLog(@"%lld", rosterId);
        if (!error) {
            [HQCustomToast showDialog:NSLocalizedString(@"Friend_request_sent", @"已发送添加好友申请")];
            [self.navigationController popViewControllerAnimated:YES];

        } else {
            [HQCustomToast showDialog:[error description]];
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
    [self setNavigationBarTitle:NSLocalizedString(@"Add_friend", @"添加好友") navLeftButtonIcon:@"blackback" navRightButtonTitle:NSLocalizedString(@"Scan", @"扫一扫")];
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
