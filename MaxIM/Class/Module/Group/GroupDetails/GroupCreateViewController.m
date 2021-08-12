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
#import <floo-ios/BMXClient.h>
#import <floo-ios/BMXRoster.h>
#import "GorupLittleCell.h"
#import "GroupCreateAlertView.h"

#import "GroupCreateAlertView.h"
#import <floo-ios/BMXGroupMember.h>

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
    [[[BMXClient sharedClient] groupService] getMembers:self.currentGroup forceRefresh:NO completion:^(NSArray<BMXGroupMember *> *groupList, BMXError *error) {
        MAXLog(@"%ld", groupList.count);
        NSMutableArray* array = [NSMutableArray array];
        for (BMXGroupMember* amember in groupList) {
            NSString* uidStr = [NSString stringWithFormat:@"%ld", amember.uid];
            [array addObject:uidStr];
        }
        [self getRostersByidArray:array];
    }];
}

// 获取群成员详情
- (void)getRostersByidArray:(NSArray *)idArray {
    [[[BMXClient sharedClient] rosterService] searchRostersByRosterIdList:idArray forceRefresh:NO completion:^(NSArray<BMXRoster *> *rosterList, BMXError *error) {
        MAXLog(@"%ld", rosterList.count);
        self.rosterArray = [NSArray arrayWithArray: rosterList];
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
    BMXRoster* roster = [self.rosterArray objectAtIndex:indexPath.row];
    NSString* idStr = [NSString stringWithFormat:@"%lld", roster.rosterId];
    NSString* dicIdValue = [_selectedUids objectForKey:idStr];
    BOOL isSelected = ([dicIdValue isEqualToString:@"0"] || dicIdValue == nil) ? NO : YES;
    NSString* name = roster.nickName;
    if([name isEqualToString:@""] || name == nil) {
        name = roster.userName;
    }
    [cell setAvatarStr:roster.avatarUrl RosterName: name Selected: isSelected];
    [cell setDlownAvatar:roster Selected:isSelected];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BMXRoster* roster = [self.rosterArray objectAtIndex:indexPath.row];
    NSString* idStr = [NSString stringWithFormat:@"%lld", roster.rosterId];
    NSString* selected = [_selectedUids objectForKey:idStr];
    NSString* ret = [selected isEqualToString:@"0"] || selected == nil ? @"1" : @"0";
    [_selectedUids setObject:ret forKey:idStr];
    [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];

    
}
// 获取好友列表
- (void)getAllRoster {
    [[[BMXClient sharedClient] rosterService] getRosterListforceRefresh:YES completion:^(NSArray *rostIdList, BMXError *error) {
        if (!error) {
            [self searchRostersByidArray:[NSArray arrayWithArray:rostIdList]];
        }
    }];
}

// 批量搜索用户
- (void)searchRostersByidArray:(NSArray *)idArray {
    [HQCustomToast showWating];
    [[[BMXClient sharedClient] rosterService] searchRostersByRosterIdList:idArray forceRefresh:YES completion:^(NSArray<BMXRoster *> *rosterList, BMXError *error) {
        [HQCustomToast hideWating];
        if (error == nil) {
            MAXLog(@"%ld", rosterList.count);
            self.rosterArray = [NSArray arrayWithArray:rosterList];
            [self.tableView reloadData];
        }
      
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
    NSMutableArray* ids = [NSMutableArray array];
    NSArray* allKey = _selectedUids.allKeys;
    for (NSString* idkey in allKey) {
        if ([[_selectedUids objectForKey:idkey] isEqualToString:@"1"]) {
            [ids addObject:idkey];
        }
    }
    
   
    NSMutableArray *arry =[NSMutableArray array];
    if (self.isAt == YES) {
        for (NSString* idkey in allKey) {
            for (BMXRoster *roster in self.rosterArray) {
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
        
        if(ids.count == 0 ) {
            MAXLog(@"please select ....");
        }else {
            [self createGroupWithIds:ids];
        }
    }
}

-(void) createGroupWithIds:(NSArray*)ids {
    [[GroupCreateAlertView alloc] initWithFrame:CGRectZero Text:@"创建信息" OK:^(NSString *title, NSString *description, NSString *message, BOOL isChatroom) {
        BMXCreatGroupOption *option = [[BMXCreatGroupOption alloc] initWithGroupName:title groupDescription:description isPublic:YES];
        option.message = message;
        option.members = ids;
        option.isChatroom = isChatroom;
        [[[BMXClient sharedClient] groupService] creatGroupWithCreateGroupOption:option completion:^(BMXGroup *group, BMXError *error) {
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
        [self setNavigationBarTitle:@"选择提醒的人" navLeftButtonIcon:@"blackback" navRightButtonTitle:@"保存"];
        [self.navRightButton addTarget:self action:@selector(touchedRightBar) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [self setNavigationBarTitle:@"创建群组" navLeftButtonIcon:@"blackback" navRightButtonTitle:@"保存"];
        [self.navRightButton addTarget:self action:@selector(touchedRightBar) forControlEvents:UIControlEventTouchUpInside];
    }
   
}



@end
