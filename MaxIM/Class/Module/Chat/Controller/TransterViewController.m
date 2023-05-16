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

#import <floo-ios/floo_proxy.h>
#import "MAXUtils.h"

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
    [MAXUtils getAllRosterIdsWithCompletion:^(ListOfLongLong *list) {
        [self searchRostersByidArray: list];
    }];
}

// 获取群list
- (void)getGroupList {
    [[[BMXClient sharedClient] groupService] get:YES completion:^(BMXGroupList *res, BMXError *aError) {
        unsigned long sz = res.size;
        MAXLog(@"%ld", sz);
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        if (!aError) {
            for (int i=0; i<sz; i++) {
                [arr addObject:[res get: i]];
            }
            self.groupArray = arr;
            [self.tableView reloadData];
        }
    }];
}

// 批量搜索用户
- (void)searchRostersByidArray:(ListOfLongLong *)list {
    [MAXUtils getRostersByidArray:list completion:^(NSArray *arr) {
        self.rosterArray = arr;
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
        BMXRosterItem *roster = self.rosterArray[indexPath.row];
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
        BMXRosterItem *roster = self.rosterArray[indexPath.row];
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
//    self.navigationItem.title = NSLocalizedString(@"Select_contact", @"选择联系人");
    
    [self setNavigationBarTitle: NSLocalizedString(@"Select_contact", @"选择联系人") navLeftButtonIcon:@"blackback"];
    
}



@end
