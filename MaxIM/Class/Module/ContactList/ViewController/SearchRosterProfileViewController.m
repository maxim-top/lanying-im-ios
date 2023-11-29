//
//  SearchRosterProfileViewController.m
//  MaxIM
//
//  Created by 韩雨桐 on 2019/3/22.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "SearchRosterProfileViewController.h"
#import <floo-ios/floo_proxy.h>
#import "LHChatVC.h"
#import "UIViewController+CustomNavigationBar.h"

@interface SearchRosterProfileViewController ()
@property (nonatomic, strong) BMXRosterItem *roster;


@end

@implementation SearchRosterProfileViewController


- (instancetype)initWithRoster:(BMXRosterItem *)roster {
    if (self = [super initWithRoster:roster]) {
        self.roster = roster;
    }
    return self;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavigationBarTitle:self.roster.username navLeftButtonIcon:@"blackback" navRightButtonTitle:nil];
    [[[BMXClient sharedClient] userService] getProfile:NO completion:^(BMXUserProfile *profile, BMXError *aError) {
        if (self.roster.rosterId == profile.userId) {
            
        } else {
            UIButton *joinBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            joinBtn.frame = CGRectMake(MAXScreenW - 30 - 30, NavHeight - 5 -30, 30, 30);
            [joinBtn addTarget:self action:@selector(joinBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            [joinBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [joinBtn setTitle:NSLocalizedString(@"Add", @"添加") forState:UIControlStateNormal];
            [joinBtn sizeToFit];
            [self.navigationBar addSubview:joinBtn];
        }
    }];
}

- (void)addRoster {
    BMXRosterItem *roster = self.roster;
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

- (void)joinBtnClick:(UIButton *)button {
    [self addRoster];
}

- (void)returnButtonClick {
    [self.navigationController popToRootViewControllerAnimated:YES];
}


// 添加好友
- (void)addRosterId:(long long)rosterId reason:(NSString *)reason {
    [[[BMXClient sharedClient] rosterService] applyWithRosterId:rosterId message:reason completion:^(BMXError *error) {
        MAXLog(@"%lld", rosterId);
        if (!error) {
            [HQCustomToast showDialog:NSLocalizedString(@"Request_sent", @"已发出请求")];
            [self.navigationController popToRootViewControllerAnimated:YES];
            
        } else if (error.errorCode == BMXErrorCode_CurrentUserIsInRoster){
            [self.navigationController  popToRootViewControllerAnimated:NO];
            
            UITabBarController *bar =  (UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
            UINavigationController *currentNav =  (UINavigationController *)bar.selectedViewController;
            
            LHChatVC *vc = [[LHChatVC alloc] initWithRoster:self.roster messageType:BMXMessage_MessageType_Single];
            vc.hidesBottomBarWhenPushed = YES;
            [currentNav pushViewController:vc animated:YES];
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

- (NSArray *)getSettingConfigDataArray {
    NSDictionary *configDic = [NSDictionary dictionaryWithDictionary:[self readLocalFileWithName:@"searchDetailProfiledetail"]];
    NSMutableArray *dataArray = [NSMutableArray array];
    for (NSDictionary *dic in configDic[@"cells"]) {
        [dataArray addObject:dic];
    }
    return dataArray;
}

- (NSDictionary *)readLocalFileWithName:(NSString *)name {
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"json"];
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    return [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
}


@end
