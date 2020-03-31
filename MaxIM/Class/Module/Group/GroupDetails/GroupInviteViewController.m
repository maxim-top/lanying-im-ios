//
//  ----------------------------------------------------------------------
//   File    :  GroupInviteViewController.m
//   Author  : shaohui.yang shaohui@bmxlabs.com
//   Purpose :
//   Created : 2019/1/5 by shaohui.yang shaohui@bmxlabs.com
//
//  ----------------------------------------------------------------------
//
//                    Copyright (C) 2018-2019   MaxIM.Top
//
// You may obtain a copy of the licence at http://www.maxim.top/LICENCE-MAXIM.md
//
//  ----------------------------------------------------------------------
    

#import "GroupInviteViewController.h"
#import "UIViewController+CustomNavigationBar.h"
#import <floo-ios/BMXClient.h>
#import <floo-ios/BMXGroupInvitation.h>
#import "GroupHandleCell.h"



@interface GroupInviteViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray* invitationList;
@property (nonatomic, strong) UITableView* tableView;

@property (nonatomic, strong) NSMutableDictionary* rosterInfos;
@property (nonatomic, strong) NSMutableDictionary* groupInfos;

@end

@implementation GroupInviteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpNavItem];
    self.invitationList = [NSArray array];
    [self.view addSubview:self.tableView];
    [self getApplyList];
}


- (void) getApplyList {
    
    [[[BMXClient sharedClient] groupService] getInvitationListByCursor:@"" pageSize:100 completion:^(NSArray *invitationList, NSString *cursor, long long offset, BMXError *error) {
        if(!error && invitationList!= 0) {
            self.invitationList = invitationList;
            NSMutableSet* rosterIdSet = [NSMutableSet set];
            NSMutableSet* groupIdSet = [NSMutableSet set];
            for (BMXGroupInvitation* invitation in invitationList) {
                [rosterIdSet addObject:[NSNumber numberWithLongLong:invitation.inviterId]];
                [groupIdSet addObject:[NSNumber numberWithLongLong:invitation.groupId]];
            }
            [self searchGroupInfosByGids:[NSArray arrayWithArray:[groupIdSet allObjects] ] andRosters:[NSArray arrayWithArray:[rosterIdSet allObjects]]];
        } else {
            [HQCustomToast showDialog:error.errorMessage];
        }
    }];
}

- (void) searchGroupInfosByGids:(NSArray*) gids andRosters:(NSArray*) rosterIds
{
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
        dispatch_group_enter(group);
        [[[BMXClient sharedClient] rosterService] searchRostersByRosterIdList:rosterIds forceRefresh:NO completion:^(NSArray<BMXRoster *> *rosterList, BMXError *error) {
            MAXLog(@"%ld", rosterList.count);
            for (BMXRoster* roster in rosterList) {
                [self.rosterInfos setObject:roster forKey:[NSString stringWithFormat:@"%lld", roster.rosterId]];
            }
            dispatch_group_leave(group);
        }];
//        // 下面是群的。。。。
        dispatch_group_enter(group);
        [[[BMXClient sharedClient] groupService] getGroupInfoByGroupIdArray:gids forceRefresh:NO completion:^(NSArray *aGroups, BMXError *aError) {
            MAXLog(@"%ld",aGroups.count);
            for (BMXGroup *group in aGroups) {                
                [self.groupInfos setObject:group forKey:[NSString stringWithFormat:@"%lld", group.groupId]];
            }
            dispatch_group_leave(group);
        }];
    });
    
    dispatch_group_notify(group, dispatch_get_global_queue(0, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
}


#pragma mark - TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.invitationList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [GroupHandleCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    GroupHandleCell* cell = [tableView dequeueReusableCellWithIdentifier:@"GroupHandleCell"];
    if (cell == nil) {
        cell = [[GroupHandleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GroupHandleCell"];
    }
    
    BMXGroupInvitation* invitation = [self.invitationList objectAtIndex:indexPath.row];
    BMXRoster* roster = [self.rosterInfos objectForKey:[NSString stringWithFormat:@"%lld", invitation.inviterId]];
    BMXGroup* group = [self.groupInfos objectForKey:[NSString stringWithFormat:@"%lld", invitation.groupId]];
    
    [cell cellInviteContentWithRoster:roster group:group inviteStatus:invitation.invitationStatus exp:invitation.expiredTime actionHandler:^(BOOL ret) {
        [self touchedActionWithRet:ret atIndex:indexPath.row];
    }];
    return cell;
}

- (void) touchedActionWithRet:(BOOL) ret atIndex: (NSInteger) index
{
    BMXGroupInvitation* invitation = [self.invitationList objectAtIndex:index];
    BMXRoster* roster = [self.rosterInfos objectForKey:[NSString stringWithFormat:@"%lld", invitation.inviterId]];
    BMXGroup* group = [self.groupInfos objectForKey:[NSString stringWithFormat:@"%lld", invitation.groupId]];
    if(ret) { //同意
        [[[BMXClient sharedClient] groupService] acceptInvitationByGroup:group inviter:invitation.inviterId completion:^(BMXError *error) {
            MAXLog(@"同意成功...");
            [self getApplyList];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"KEY_NOTIFICATION_GROUP_MEMBER_UPDATED" object:nil];
        }];
    }else {
        [[[BMXClient sharedClient] groupService] declineInvitationByGroup:group inviter:invitation.inviterId completion:^(BMXError *error) {
            MAXLog(@"拒绝成功...");
            [self getApplyList];
        }];
    }
}

- (void)setUpNavItem{
    [self setNavigationBarTitle:@"入群邀请" navLeftButtonIcon:@"blackback"];

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

- (NSMutableDictionary *)rosterInfos {
    if (_rosterInfos == nil) {
        _rosterInfos = [NSMutableDictionary dictionary];
    }
    return _rosterInfos;
}

- (NSMutableDictionary *)groupInfos {
    if (_groupInfos == nil) {
        _groupInfos = [NSMutableDictionary dictionary];
    }
    return _groupInfos;
}

@end
