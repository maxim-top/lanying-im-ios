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
#import <floo-ios/floo_proxy.h>

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
    BMXGroupList *groupList = [[BMXGroupList alloc] init];
    [[[BMXClient sharedClient] groupService] getApplicationList:groupList cursor:@"" pageSize:100 completion:^(BMXGroupApplicationPage* res, BMXError *error) {
        if (!error)  {
            NSMutableArray *applicationList = [[NSMutableArray alloc] init];
            unsigned long sz = res.result.size;
            BMXGroupApplicationList *result = res.result;
            for (int i=0; i<sz; i++) {
                [applicationList addObject:[result get:i]];
            }
            
            self.applicationArray = applicationList;
            NSSet* set = [NSSet setWithArray:self.applicationArray];
            
            ListOfLongLong * idList = [[ListOfLongLong alloc] init];
            for (BMXGroupApplication* application in set) {
                long long val = application.getMApplicationId;
                [idList addWithX: &val];
            }
            
            [self searchRostersByidList: idList];
        } else {
            
        }
    }];
}

- (void)searchRostersByidList:(ListOfLongLong *)idList {
    [[[BMXClient sharedClient] rosterService] searchWithRosterIdList:idList forceRefresh:YES completion:^(BMXRosterItemList *rosterList, BMXError *error) {
        unsigned long sz = rosterList.size;
        MAXLog(@"%ld", sz);
        for (int i=0; i<sz; i++) {
            BMXRosterItem* roster = [rosterList get:i];
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
    BMXRosterItem* roster = [self.rosterInfos objectForKey:[NSString stringWithFormat:@"%lld", application.getMApplicationId]];
    [cell cellApplicationContentWithRoster:roster group:self.group applicationStatus:application.getMStatus exp:application.getMExpired actionHandler:^(BOOL ret) {
        [self touchedActionWithRet:ret atIndex:indexPath.row];
    }];
    return cell;
}

-(void) touchedActionWithRet:(BOOL) ret atIndex:(NSInteger) index {
    BMXGroupApplication* application = [self.applicationArray objectAtIndex:index];
    if(ret) { //同意
        [[[BMXClient sharedClient] groupService] acceptApplicationWithGroup:self.group applicantId:application.getMApplicationId completion:^(BMXError *error) {
            MAXLog(@"同意成功...");
            if (!error) {
                [self getApplyList];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"KEY_NOTIFICATION_GROUP_MEMBER_UPDATED" object:nil];
            }
            
        }];
    }else {
        [[[BMXClient sharedClient] groupService] declineApplicationWithGroup:self.group applicantId:application.getMApplicationId reason:@"" completion:^(BMXError *error) {
            MAXLog(@"拒绝成功...");
            [self getApplyList];
        }];
    }
}

- (void)setUpNavItem{
    [self setNavigationBarTitle:NSLocalizedString(@"Join_group_application", @"入群申请") navLeftButtonIcon:@"blackback"];
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
