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
#import <floo-ios/floo_proxy.h>

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
    [[[BMXClient sharedClient] groupService] getInvitationList:@"" pageSize:100 completion:^(BMXGroupInvitationPage* res, BMXError *error) {
        if (!error)  {
            NSMutableArray *invitationList = [[NSMutableArray alloc] init];
            unsigned long sz = res.result.size;
            BMXGroupInvitationList *result = res.result;
            NSMutableSet* rosterIdSet = [NSMutableSet set];
            NSMutableSet* groupIdSet = [NSMutableSet set];
            for (int i=0; i<sz; i++) {
                BMXGroupInvitation * invitation = [result get:i];
                [invitationList addObject:invitation];
                long long rosterId = invitation.getMInviterId;
                long long groupId = invitation.getMGroupId;
                [rosterIdSet addObject:[NSNumber numberWithLongLong:rosterId]];
                [groupIdSet addObject:[NSNumber numberWithLongLong:groupId]];
            }
            ListOfLongLong *rosterIds = [[ListOfLongLong alloc] init];
            for (NSNumber *val in rosterIdSet) {
                long long v = [val longLongValue];
                [rosterIds addWithX: &v];
            }
            ListOfLongLong *groupIds = [[ListOfLongLong alloc] init];
            for (NSNumber *val in groupIdSet) {
                long long v = [val longLongValue];
                [groupIds addWithX: &v];
            }

            self.invitationList = invitationList;
            for (BMXGroupInvitation* invitation in invitationList) {
                [rosterIdSet addObject:[NSNumber numberWithLongLong:invitation.getMInviterId]];
                [groupIdSet addObject:[NSNumber numberWithLongLong:invitation.getMGroupId]];
            }
            [self searchGroupInfosByGids:groupIds andRosters:rosterIds];
        } else {
            
        }
    }];

}

- (void) searchGroupInfosByGids:(ListOfLongLong*) gids andRosters:(ListOfLongLong*) rosterIds
{
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
        dispatch_group_enter(group);
        [[[BMXClient sharedClient] rosterService] searchWithRosterIdList:rosterIds forceRefresh:NO completion:^(BMXRosterItemList *rosterList, BMXError *error) {
            unsigned long sz = rosterList.size;
            MAXLog(@"%lu", sz);
            for (int i=0; i<sz; i++) {
                BMXRosterItem* roster = [rosterList get:i];
                [self.rosterInfos setObject:roster forKey:[NSString stringWithFormat:@"%lld", roster.rosterId]];
            }
            dispatch_group_leave(group);
        }];
//        // 下面是群的。。。。
        dispatch_group_enter(group);
        [[[BMXClient sharedClient] groupService] fetchGroupsByIdListWithGroupIdList:gids forceRefresh:NO completion:^(BMXGroupList *aGroups, BMXError *aError) {
            unsigned long sz = aGroups.size;
            MAXLog(@"%ld",sz);
            for (int i=0; i<sz; i++) {
                BMXGroup *group = [aGroups get:i];
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
    BMXRosterItem* roster = [self.rosterInfos objectForKey:[NSString stringWithFormat:@"%lld", invitation.getMInviterId]];
    BMXGroup* group = [self.groupInfos objectForKey:[NSString stringWithFormat:@"%lld", invitation.getMGroupId]];
    
    [cell cellInviteContentWithRoster:roster group:group inviteStatus:invitation.getMStatus exp:invitation.getMExpired actionHandler:^(BOOL ret) {
        [self touchedActionWithRet:ret atIndex:indexPath.row];
    }];
    return cell;
}

- (void) touchedActionWithRet:(BOOL) ret atIndex: (NSInteger) index
{
    BMXGroupInvitation* invitation = [self.invitationList objectAtIndex:index];
    BMXGroup* group = [self.groupInfos objectForKey:[NSString stringWithFormat:@"%lld", invitation.getMGroupId]];
    if(ret) { //同意
        [[[BMXClient sharedClient] groupService] acceptInvitationWithGroup:group inviter:invitation.getMInviterId completion:^(BMXError *error) {
            MAXLog(@"同意成功...");
            [self getApplyList];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"KEY_NOTIFICATION_GROUP_MEMBER_UPDATED" object:nil];
        }];
    }else {
        [[[BMXClient sharedClient] groupService] declineInvitationWithGroup:group inviter:invitation.getMInviterId reason:@"" completion:^(BMXError *error) {
            MAXLog(@"拒绝成功...");
            [self getApplyList];
        }];
    }
}

- (void)setUpNavItem{
    [self setNavigationBarTitle:NSLocalizedString(@"Join_group_invitation", @"入群邀请") navLeftButtonIcon:@"blackback"];

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
