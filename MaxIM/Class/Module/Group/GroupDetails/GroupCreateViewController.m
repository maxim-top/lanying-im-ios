//
//  ----------------------------------------------------------------------
//   File    :  GroupCreateViewController.m
//   Author  : shaohui.yang shaohui@bmxlabs.com
//   Purpose :
//   Created : 2018/12/27 by shaohui.yang shaohui@bmxlabs.com
//
//  ----------------------------------------------------------------------
//
//                    Copyright (C) 2018-2019   MaxIM.Top
//
// You may obtain a copy of the licence at http://www.maxim.top/LICENCE-MAXIM.md
//
//  ----------------------------------------------------------------------
    

#import "GroupCreateViewController.h"
#import "UIViewController+CustomNavigationBar.h"
#import "GorupLittleCell.h"
#import "GroupCreateAlertView.h"

#import "GroupCreateAlertView.h"
#import <floo-ios/floo_proxy.h>
#import "MAXUtils.h"

@interface GroupCreateViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    NSMutableDictionary* _selectedUids;
}
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray* rosterArray;

//@property (nonatomic, strong) NSArray *memberList;
@property (nonatomic, strong) BMXGroup *currentGroup;


@end

@implementation GroupCreateViewController

- (instancetype)initWithCurrentGroup:(BMXGroup *)group {
    if (self = [super init]) {
        self.currentGroup = group;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _selectedUids = [NSMutableDictionary dictionary];
    [self setUpNavItem];
    self.rosterArray = [NSArray array];
    [self.view addSubview:self.tableView];
    
    if (self.isAt == YES) {
        [self getMembers];
//        [self getManageList];
    } else {
        [self getAllRoster];
    }
}


// 获取群成员
- (void)getMembers {
    [MAXUtils getMemberIdArrayWithGroup:self.currentGroup completion:^(NSArray *arr) {
        ListOfLongLong *list = [[ListOfLongLong alloc] init];
        for (NSString *sId in arr) {
            long long lId = [sId longLongValue];
            [list addWithX: &lId];
        }
        [self getRostersByidArray:list];
    }];

}

// 获取群成员详情
- (void)getRostersByidArray:(ListOfLongLong *)list {
    [MAXUtils getRostersByidArray:list completion:^(NSArray *arr) {
        self.rosterArray = arr;
        [self.tableView reloadData];
    }];
}

//-(void) getManageList // 管理员不能被操作.
//{
//    [[[BMXClient sharedClient] groupService] getAdmins:self.currentGroup forceRefresh:YES completion:^(NSArray<BMXGroupMember *> *adminList, BMXError *error) {
//        for (BMXGroupMember* member in adminList) {
//            NSString* uidStr = [NSString stringWithFormat:@"%ld", member.mUid];
//            if([self isSelf:uidStr]) {
//                _isAdmin = YES;
//            }
//            [_adlinDictionary setObject:[NSNumber numberWithBool:YES] forKey:uidStr];
//        }
//        if (adminList != nil && adminList.count > 0) {
//            [_tableView reloadData];
//        }
//    }];
//}

#pragma mark - TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.rosterArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GorupLittleCell* cell = [tableView dequeueReusableCellWithIdentifier:@"GorupLittleCell"];
    if(cell == nil) {
        cell = [[GorupLittleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GorupLittleCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    BMXRosterItem* roster = [self.rosterArray objectAtIndex:indexPath.row];
    NSString* idStr = [NSString stringWithFormat:@"%lld", roster.rosterId];
    NSString* dicIdValue = [_selectedUids objectForKey:idStr];
    BOOL isSelected = ([dicIdValue isEqualToString:@"0"] || dicIdValue == nil) ? NO : YES;
    NSString* name = roster.nickname;
    if([name isEqualToString:@""] || name == nil) {
        name = roster.username;
    }
    [cell setAvatarStr:roster.avatarUrl RosterName: name Selected: isSelected];
    [cell setDlownAvatar:roster Selected:isSelected];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BMXRosterItem* roster = [self.rosterArray objectAtIndex:indexPath.row];
    NSString* idStr = [NSString stringWithFormat:@"%lld", roster.rosterId];
    NSString* selected = [_selectedUids objectForKey:idStr];
    NSString* ret = [selected isEqualToString:@"0"] || selected == nil ? @"1" : @"0";
    [_selectedUids setObject:ret forKey:idStr];
    [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];

    
}
// 获取好友列表
- (void)getAllRoster {
    [MAXUtils getAllRosterWithCompletion:^(NSArray *arr) {
        self.rosterArray = arr;
        [self.tableView reloadData];
    }];
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
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

-(void) touchedRightBar {
    ListOfLongLong* ids = [[ListOfLongLong alloc] init];
    NSArray* allKey = _selectedUids.allKeys;
    for (NSString* idkey in allKey) {
        if ([[_selectedUids objectForKey:idkey] isEqualToString:@"1"]) {
            long long uid = [idkey longLongValue];
            [ids addWithX:&uid];
        }
    }
    
   
    NSMutableArray *arry =[NSMutableArray array];
    if (self.isAt == YES) {
        for (NSString* idkey in allKey) {
            for (BMXRosterItem *roster in self.rosterArray) {
                if ([[_selectedUids objectForKey:idkey] isEqualToString:@"1"] && roster.rosterId == [idkey longLongValue]) {
                    [arry addObject:roster];
                }
            }
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(atgroupmemberVCdidPopToLastVC:)]) {
            [self.delegate atgroupmemberVCdidPopToLastVC:arry];
            [self.navigationController popViewControllerAnimated:YES];
            self.isAt = NO;
        }
    }  else {
        
        if(ids.size == 0 ) {
            MAXLog(@"please select ....");
        }else {
            [self createGroupWithIds:ids];
        }
    }
}

-(void) createGroupWithIds:(ListOfLongLong*)ids {
    [[GroupCreateAlertView alloc] initWithFrame:CGRectZero Text:NSLocalizedString(@"Create_message", @"创建信息") OK:^(NSString *title, NSString *description, NSString *message, BOOL isChatroom) {
        BMXGroupServiceCreateGroupOptions *option = [[BMXGroupServiceCreateGroupOptions alloc] initWithName:title description:description isPublic:YES];
        [option setMMessage: message];
        [option setMMembers: ids];
        [option setMIsChatroom: isChatroom];
        [[[BMXClient sharedClient] groupService] createWithOptions:option completion:^(BMXGroup *group, BMXError *error) {
            if (!error) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"KGroupListModified" object:nil];
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
    } Cancel:^{
        
    }];
}

- (void)setUpNavItem {
    
    if (self.isAt == YES) {
        [self setNavigationBarTitle:NSLocalizedString(@"Select_who_to_alert", @"选择提醒的人") navLeftButtonIcon:@"blackback" navRightButtonTitle:NSLocalizedString(@"Save", @"保存")];
        [self.navRightButton addTarget:self action:@selector(touchedRightBar) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [self setNavigationBarTitle:NSLocalizedString(@"Create_group", @"创建群组") navLeftButtonIcon:@"blackback" navRightButtonTitle:NSLocalizedString(@"Save", @"保存")];
        [self.navRightButton addTarget:self action:@selector(touchedRightBar) forControlEvents:UIControlEventTouchUpInside];
    }
   
}



@end
