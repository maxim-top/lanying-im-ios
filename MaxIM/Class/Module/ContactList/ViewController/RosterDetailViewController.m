

//
//  RosterDetailViewController.m
//  MaxIM
//
//  Created by 韩雨桐 on 2018/12/15.
//  Copyright © 2018 hyt. All rights reserved.
//

#import "RosterDetailViewController.h"
#import "ContactTableViewCell.h"

#import <floo-ios/floo_proxy.h>
#import "MAXUtils.h"
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
    BMXRosterItem *roster = noti.object;
    [self acceptAddRosterById:(NSInteger)roster.rosterId];
}

#pragma mark - manager
// 获取申请添加好友列表
- (void)getApplicationList {
    [HQCustomToast showWating];
    [[[BMXClient sharedClient] rosterService] getApplicationList:@"" pageSize:50 completion:^(BMXRosterApplicationResultPage *res, BMXError *error) {
        [HQCustomToast hideWating];
        if (!error) {
            NSMutableArray *arr = [[NSMutableArray alloc] init];
            ListOfLongLong *idList = [[ListOfLongLong alloc] init];
            unsigned long sz = res.result.size;
            for (int i=0; i<sz; i++) {
                BMXRosterServiceApplication *app = [res.result get:i];
                [arr addObject:app];
                long long val = app.getMRosterId;
                [idList addWithX: &val];
            }
            self.rosterApplicationArray = arr;
            [self searchRostersByidList:idList];
            MAXLog(@"%lu", (unsigned long)self.rosterApplicationArray.count);
        }
    }];
}

// 批量搜索用户
- (void)searchRostersByidList:(ListOfLongLong *)list {
    [MAXUtils getRostersByidArray:list completion:^(NSArray *arr) {
        self.rosterArray = arr;
        [self.tableView reloadData];
    }];
}

// 添加好友
- (void)acceptAddRosterById:(NSInteger)rosterId {
    [[[BMXClient sharedClient] rosterService] acceptWithRosterId:rosterId completion:^(BMXError *error) {
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
    BMXRosterServiceApplication *application = self.rosterApplicationArray[indexPath.row];
    BMXRosterItem *rosterProfile= self.rosterArray[indexPath.row];
    ContactTableViewCell *cell = [ContactTableViewCell contactTableViewCellWith:tableView];
    [cell refresh:rosterProfile];
    cell.nicknameLabel.text = rosterProfile.username;

    cell.infoLabel.text = application.getMReason;
    if (application.getMStatus == BMXRosterService_ApplicationStatus_Accepted) {
        [cell.button setHidden:YES];
        [cell.contentLabel setHidden:NO];
        cell.contentLabel.text = NSLocalizedString(@"Added_as_Friend", @"已添加为好友");
    } else if (application.getMStatus == BMXRosterService_ApplicationStatus_Pending) {
        [cell.button setHidden:NO];
        [cell.contentLabel setHidden:YES];
        [cell.button setTitle:NSLocalizedString(@"Agree", @"同意") forState:UIControlStateNormal];
    } else {
        [cell.button setHidden:YES];
        [cell.contentLabel setHidden:NO];
        cell.contentLabel.text = NSLocalizedString(@"Rejected", @"已拒绝");
    }
    return cell;
}

- (void)setUpNavItem{
    [self setNavigationBarTitle:NSLocalizedString(@"Application_and_notification", @"申请与通知") navLeftButtonIcon:@"blackback"];
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
