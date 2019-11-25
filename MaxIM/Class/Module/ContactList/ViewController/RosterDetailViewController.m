

//
//  RosterDetailViewController.m
//  MaxIM
//
//  Created by 韩雨桐 on 2018/12/15.
//  Copyright © 2018 hyt. All rights reserved.
//

#import "RosterDetailViewController.h"
#import "ContactTableViewCell.h"

#import <floo-ios/BMXClient.h>
#import <floo-ios/BMXRoster.h>

#import <floo-ios/BMXApplication.h>
#import "UIViewController+CustomNavigationBar.h"

@interface RosterDetailViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *rosterArray;
@property (nonatomic, strong) NSArray *rosterApplicationArray;


@end

@implementation RosterDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpNavItem];
    
    [self getApplicationList];
    
    [self tableView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acceptAddRoster:) name:@"ContanctAddClick" object:nil];
}

- (void)acceptAddRoster:(NSNotification *)noti {
    BMXRoster *roster = noti.object;
    [self acceptAddRosterById:(NSInteger)roster.rosterId];
}

#pragma mark - manager
// 获取申请添加好友列表
- (void)getApplicationList {
    [HQCustomToast showWating];
    [[[BMXClient sharedClient] rosterService] getApplicationListWithCursor:@"" pageSize:50 completion:^(NSArray *applicationList, NSString *cursor, int offset, BMXError *error) {
        [HQCustomToast hideWating];
        if (!error) {
            NSArray *applicationArray = [NSArray arrayWithArray:applicationList];
            self.rosterApplicationArray = applicationArray;
            NSMutableArray *idList = [NSMutableArray array];
            for (BMXApplication *application in applicationArray) {
                [idList addObject:[NSString stringWithFormat:@"%lld", application.rosterId]];
            }
            [self searchRostersByidArray:[NSArray arrayWithArray:idList]];
            MAXLog(@"%lu", (unsigned long)applicationArray.count);
        }
    }];
}

// 批量搜索用户
- (void)searchRostersByidArray:(NSArray *)idArray {
[[[BMXClient sharedClient] rosterService] searchRostersByRosterIdList:idArray forceRefresh:YES completion:^(NSArray<BMXRoster *> *rosterList, BMXError *error) {
    MAXLog(@"%lu", (unsigned long)rosterList.count);
    self.rosterArray = [NSArray arrayWithArray:rosterList];
    [self.tableView reloadData];
}];
}

// 添加好友
- (void)acceptAddRosterById:(NSInteger)rosterId {
    [[[BMXClient sharedClient] rosterService] acceptRosterById:rosterId withCompletion:^(BMXError *error) {
        if (!error) {
            MAXLog(@"添加成功");
            [self getApplicationList];
        }
        MAXLog(@"%@", error);
    }];
}

#pragma mark - TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.rosterArray.count > 0 ? self.rosterArray.count : 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BMXApplication *application = self.rosterApplicationArray[indexPath.row];
    BMXRoster *rosterProfile= self.rosterArray[indexPath.row];
    ContactTableViewCell *cell = [ContactTableViewCell contactTableViewCellWith:tableView];
    [cell refresh:rosterProfile];
    cell.nicknameLabel.text = rosterProfile.userName;   

    cell.infoLabel.text = application.reason;
    if (application.applicationStatus == BMXApplicationStatusAccepted) {
        [cell.button setHidden:YES];
        [cell.contentLabel setHidden:NO];
        cell.contentLabel.text = @"已添加为好友";
    } else if (application.applicationStatus == BMXApplicationStatusPending) {
        [cell.button setHidden:NO];
        [cell.contentLabel setHidden:YES];
        [cell.button setTitle:@"同意" forState:UIControlStateNormal];
    } else {
        [cell.button setHidden:YES];
        [cell.contentLabel setHidden:NO];
        cell.contentLabel.text = @"已拒绝";
    }
    return cell;
}

- (void)setUpNavItem{
    [self setNavigationBarTitle:@"申请与通知" navLeftButtonIcon:@"blackback"];
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NavHeight, MAXScreenW, MAXScreenH - NavHeight) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[ContactTableViewCell class]
           forCellReuseIdentifier:@"ContactTableViewCell"];
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

@end
