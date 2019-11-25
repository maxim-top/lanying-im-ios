//
//  SearchRosterProfileViewController.m
//  MaxIM
//
//  Created by 韩雨桐 on 2019/3/22.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "SearchRosterProfileViewController.h"
#import <floo-ios/BMXClient.h>
#import <floo-ios/BMXRoster.h>
#import "LHChatVC.h"
#import "UIViewController+CustomNavigationBar.h"

@interface SearchRosterProfileViewController ()
@property (nonatomic, strong) BMXRoster *roster;


@end

@implementation SearchRosterProfileViewController


- (instancetype)initWithRoster:(BMXRoster *)roster {
    if (self = [super initWithRoster:roster]) {
        self.roster = roster;
    }
    return self;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self setMainNavigationBarTitle:self.roster.userName];
    
    
    
    [self setNavigationBarTitle:self.roster.userName navLeftButtonIcon:@"blackback" navRightButtonTitle:nil];
    
    
    
    [[[BMXClient sharedClient] userService] getProfileForceRefresh:NO completion:^(BMXUserProfile *profile, BMXError *aError) {
        if (self.roster.rosterId == profile.userId) {
            
        } else {
            UIButton *joinBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            joinBtn.frame = CGRectMake(MAXScreenW - 30 - 30, NavHeight - 5 -30, 30, 30);
            [joinBtn addTarget:self action:@selector(joinBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            [joinBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [joinBtn setTitle:@"添加" forState:UIControlStateNormal];
            [joinBtn sizeToFit];
            [self.navigationBar addSubview:joinBtn];
        }
    }];
}

- (void)joinBtnClick:(UIButton *)button {
    [self addRosterId:self.roster.rosterId reason:@""];
}

- (void)returnButtonClick {
    [self.navigationController popToRootViewControllerAnimated:YES];
}


// 添加好友
- (void)addRosterId:(long long)rosterId reason:(NSString *)reason {
    MAXLog(@"%@", [[BMXClient sharedClient] rosterService]);
    [[[BMXClient sharedClient] rosterService] applyAddRoster:rosterId reason:reason completion:^(BMXRoster *roster, BMXError *error) {
        MAXLog(@"%@", roster);
        if (!error) {
            [HQCustomToast showDialog:@"已发出请求"];
            [self.navigationController popToRootViewControllerAnimated:YES];
            
        } else if (error.errorCode == BMXCurrentUserIsInRoster){
            [self.navigationController  popToRootViewControllerAnimated:NO];
            
            UITabBarController *bar =  (UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
            UINavigationController *currentNav =  (UINavigationController *)bar.selectedViewController;
            
            LHChatVC *vc = [[LHChatVC alloc] initWithRoster:self.roster messageType:BMXMessageTypeSingle];
            vc.hidesBottomBarWhenPushed = YES;
            [currentNav pushViewController:vc animated:YES];
        } else {
            [HQCustomToast showDialog:error.errorMessage];
        }
    }];
}


- (NSArray *)getSettingConfigDataArray {
    NSDictionary *configDic = [NSDictionary dictionaryWithDictionary:[self readLocalFileWithName:@"searchDetailProfiledetail"]];
    MAXLog(@"%@", configDic);
    NSMutableArray *dataArray = [NSMutableArray array];
    for (NSDictionary *dic in configDic[@"cells"]) {
        [dataArray addObject:dic];
    }
    MAXLog(@"%@", dataArray);
    return dataArray;
}

- (NSDictionary *)readLocalFileWithName:(NSString *)name {
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"json"];
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    return [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
}


@end
