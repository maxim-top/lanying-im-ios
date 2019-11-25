//
//  ContactListViewController.m
//  MaxIM
//
//  Created by hyt on 2018/11/17.
//  Copyright © 2018年 hyt. All rights reserved.
//

#import "TransterViewController.h"

#import "RosterSearchViewController.h"
#import "RosterDetailViewController.h"
#import "ImageTitleBasicTableViewCell.h"
#import "LHChatVC.h"
#import "GroupListViewController.h"
#import "UIViewController+CustomNavigationBar.h"

#import <floo-ios/BMXClient.h>

@interface TransterViewController ()<UITableViewDelegate, UITableViewDataSource, BMXRosterServiceProtocol>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *rosterArray;
@property (nonatomic, strong) NSArray *rosterIdArray;
@property (nonatomic, strong) NSArray *groupArray;

@end

@implementation TransterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setUpNavItem];
    [self tableView];
    [self getAllRoster];
    [self getGroupList];
    [self.tableView reloadData];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getAllRoster) name:@"RefreshContactList" object:nil];
}

#pragma mark - Manager

// 获取好友列表
- (void)getAllRoster {
    [[[BMXClient sharedClient] rosterService] getRosterListforceRefresh:YES completion:^(NSArray *rostIdList, BMXError *error) {
        if (!error) {
            MAXLog(@"%ld", rostIdList.count);
            [self searchRostersByidArray:[NSArray arrayWithArray:rostIdList]];
        }
    }];
}

// 获取群list
- (void)getGroupList {
    [[[BMXClient sharedClient] groupService] getGroupListForceRefresh:YES completion:^(NSArray *groupList, BMXError *error) {
        MAXLog(@"%ld", groupList.count);
        if (!error) {
            self.groupArray = groupList;
            [self.tableView reloadData];
        }
    }];
}

// 批量搜索用户
- (void)searchRostersByidArray:(NSArray *)idArray {
    [[[BMXClient sharedClient] rosterService] searchRostersByRosterIdList:idArray forceRefresh:NO completion:^(NSArray<BMXRoster *> *rosterList, BMXError *error) {
        MAXLog(@"%ld", rosterList.count);
        self.rosterArray = [NSArray arrayWithArray:rosterList];
        [self.tableView reloadData];
    }];
}

#pragma mark - TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.rosterArray.count ? self.rosterArray.count : 0;
        
    }else {
        return self.groupArray.count;
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        
        ImageTitleBasicTableViewCell *cell = [ImageTitleBasicTableViewCell ImageTitleBasicTableViewCellWith:tableView];
        BMXRoster *roster = self.rosterArray[indexPath.row];
        [cell refresh:roster];
        return cell;
        
    }
        ImageTitleBasicTableViewCell *cell = [ImageTitleBasicTableViewCell ImageTitleBasicTableViewCellWith:tableView];
        BMXGroup *group = self.groupArray[indexPath.row];
        [cell refreshByGroup:group];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0 ) {
        BMXRoster *roster = self.rosterArray[indexPath.row];
        if (self.delegate && [self.delegate respondsToSelector:@selector(transterSlectedRoster:)]) {
            [self.delegate transterSlectedRoster:roster];

        }
    }else {
        
        BMXGroup *group = self.groupArray[indexPath.row];
        if (self.delegate && [self.delegate respondsToSelector:@selector(transterSlectedGroup:)]) {
            [self.delegate transterSlectedGroup:group];
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}


- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NavHeight, MAXScreenW, MAXScreenH - NavHeight - TabBarHeight) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[ImageTitleBasicTableViewCell class] forCellReuseIdentifier:@"ImageTitleBasicTableViewCell"];
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

- (NSArray *)rosterArray {
    if (!_rosterArray) {
        _rosterArray = [NSArray array];
    }
    return _rosterArray;
}

- (void)setUpNavItem{
//    self.navigationController.navigationBar.barTintColor = BMXColorNavBar;
//    self.navigationItem.title = @"选择联系人";
    
    [self setNavigationBarTitle: @"选择联系人" navLeftButtonIcon:@"blackback"];
    
}



@end
