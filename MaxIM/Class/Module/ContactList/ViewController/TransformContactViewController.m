//
//  TransformContactViewController.m
//  MaxIM
//
//  Created by 韩雨桐 on 2019/8/27.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "TransformContactViewController.h"
#import "RosterDetailViewController.h"
#import "ImageTitleBasicTableViewCell.h"
#import "LHChatVC.h"
#import "GroupListViewController.h"

#import <floo-ios/floo_proxy.h>
#import "UIViewController+CustomNavigationBar.h"
#import "MAXUtils.h"

@interface TransformContactViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *rosterArray;
@property (nonatomic, strong) NSArray *rosterIdArray;
@property (nonatomic, strong) NSArray *actionArray;
@property (nonatomic, strong) NSArray *keyArray;


@end

@implementation TransformContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpNavItem];
    [self tableView];
    [self getAllRoster];
    [self actionArray];
    [self.tableView reloadData];
}

// 获取好友列表
- (void)getAllRosterWithToast:(BOOL)isNeed {
    if (isNeed == YES) {
        [HQCustomToast showWating];
    }
    [MAXUtils getAllRosterWithCompletion:^(NSArray *arr) {
        [HQCustomToast hideWating];
        self.rosterArray = arr;
        [self.tableView reloadData];
    }];
}

// 获取好友列表
- (void)getAllRoster {
    [HQCustomToast showWating];
    [MAXUtils getAllRosterWithCompletion:^(NSArray *arr) {
        [HQCustomToast hideWating];
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
        return self.actionArray.count;
    } else {
        return self.rosterArray.count ? self.rosterArray.count : 0;
    }
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ImageTitleBasicTableViewCell *cell = [ImageTitleBasicTableViewCell ImageTitleBasicTableViewCellWith:tableView];
    if (indexPath.section == 0) {
        NSString *titleStr = [NSString stringWithFormat:@"%@", self.actionArray[indexPath.row]];
        [cell refreshByTitle:titleStr];
    } else {
        BMXRosterItem *roster = self.rosterArray[indexPath.row];
        [cell refresh:roster];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        GroupListViewController *vc = [[GroupListViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        BMXRosterItem *roster = self.rosterArray[indexPath.row];
        if (self.delegate && [self.delegate respondsToSelector:@selector(transterSlectedRoster:)]) {
            [self.delegate transterSlectedRoster:roster];
        }
    }
    [self.navigationController popViewControllerAnimated:YES];

}

- (NSArray *)actionArray {
    return @[NSLocalizedString(@"Group", @"群组")];
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

- (void)setUpNavItem {
    [self setNavigationBarTitle:NSLocalizedString(@"Select_who_to_forward", @"选择要转发的人") navLeftButtonIcon:@"blackback"];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
