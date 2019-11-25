//
//  ----------------------------------------------------------------------
//   File    :  GroupApplyViewController.m
//   Author  : shaohui.yang shaohui@bmxlabs.com
//   Purpose :
//   Created : 2018/12/31 by shaohui.yang shaohui@bmxlabs.com
//
//  ----------------------------------------------------------------------
//
//                    Copyright (C) 2018-2019   MaxIM.Top
//
// You may obtain a copy of the licence at http://www.maxim.top/LICENCE-MAXIM.md
//
//  ----------------------------------------------------------------------
    

#import "GroupApplyViewController.h"
#import <floo-ios/BMXClient.h>
#import <floo-ios/BMXGroupApplication.h>
#import "GroupHandleCell.h"
#import "UIViewController+CustomNavigationBar.h"

@interface GroupApplyViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray* applicationArray;
@property (nonatomic, strong) UITableView* tableView;

@property (nonatomic, strong) NSMutableDictionary* rosterInfos;
@end

@implementation GroupApplyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpNavItem];
    self.applicationArray = [NSArray array];
    self.rosterInfos = [NSMutableDictionary dictionary];
    [self.view addSubview:self.tableView];
    [self getApplyList];
}

- (void) getApplyList {
    [[[BMXClient sharedClient] groupService] getApplicationListByCursor:@"" pageSize:100 completion:^(NSArray *applicationList, NSString *cursor, long long offset, BMXError *error) {
        if (!error && applicationList != 0)  {
            
            self.applicationArray = applicationList;
            NSSet* set = [NSSet setWithArray:self.applicationArray];
            
            NSMutableArray * array = [NSMutableArray array];
            for (BMXGroupApplication* application in set) {
                [array addObject:[NSString stringWithFormat:@"%lld", application.applicationId]];
            }
            
            [self searchRostersByidArray:array];
        } else {
            
        }
    }];
}

- (void)searchRostersByidArray:(NSArray *)idArray {
    [[[BMXClient sharedClient] rosterService] searchRostersByRosterIdList:idArray forceRefresh:YES completion:^(NSArray<BMXRoster *> *rosterList, BMXError *error) {
        MAXLog(@"%ld", rosterList.count);
        for (BMXRoster* roster in rosterList) {
            [self.rosterInfos setObject:roster forKey:[NSString stringWithFormat:@"%lld", roster.rosterId]];
        }
        [self.tableView reloadData];
    }];
}

#pragma mark - TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.applicationArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [GroupHandleCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GroupHandleCell* cell = [tableView dequeueReusableCellWithIdentifier:@"GroupHandleCell"];
    if (cell == nil) {
        cell = [[GroupHandleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GroupHandleCell"];
    }
    BMXGroupApplication* application = [self.applicationArray objectAtIndex:indexPath.row];
    BMXRoster* roster = [self.rosterInfos objectForKey:[NSString stringWithFormat:@"%lld", application.applicationId]];
    [cell cellApplicationContentWithRoster:roster group:self.group applicationStatus:application.applicationStatus exp:application.expiredTime actionHandler:^(BOOL ret) {
        [self touchedActionWithRet:ret atIndex:indexPath.row];
    }];
    return cell;
}

-(void) touchedActionWithRet:(BOOL) ret atIndex:(NSInteger) index {
    BMXGroupApplication* application = [self.applicationArray objectAtIndex:index];
    if(ret) { //同意
        [[[BMXClient sharedClient] groupService] acceptApplicationByGroup:self.group applicantId:application.applicationId completion:^(BMXError *error) {
            MAXLog(@"同意成功...");
            if (!error) {
                [self getApplyList];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"KEY_NOTIFICATION_GROUP_MEMBER_UPDATED" object:nil];
            }
            
        }];
    }else {
        [[[BMXClient sharedClient] groupService] declineApplicationByGroup:self.group applicantId:application.applicationId completion:^(BMXError *error) {
            MAXLog(@"拒绝成功...");
            [self getApplyList];
        }];
    }
}

- (void)setUpNavItem{
    [self setNavigationBarTitle:@"入群申请" navLeftButtonIcon:@"blackback"];
}

- (UITableView *)tableView {
    if (!_tableView) {
        CGFloat x = 0;
        CGFloat y = NavHeight;
        CGFloat w = MAXScreenW;
        CGFloat h = MAXScreenH - NavHeight;
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(x, y, w, h) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

@end
