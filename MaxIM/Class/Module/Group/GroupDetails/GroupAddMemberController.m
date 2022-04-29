//
//  ----------------------------------------------------------------------
//   File    :  GroupAddMemberController.m
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
    

#import "GroupAddMemberController.h"
#import <floo-ios/BMXClient.h>
#import <floo-ios/BMXGroup.h>
#import <floo-ios/BMXRoster.h>
#import <floo-ios/BMXGroupMember.h>
#import "GorupLittleCell.h"
#import "UIViewController+CustomNavigationBar.h"

@interface GroupAddMemberController ()<UITableViewDelegate, UITableViewDataSource, BMXRosterServiceProtocol>
{
    NSMutableDictionary* _selectedUids;
}
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *rosterArray;
@property (nonatomic, strong) NSArray *joinedRosterIds;
@property (nonatomic, strong) NSArray* filteredRosterArray;
@end

@implementation GroupAddMemberController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpNavItem];
    _selectedUids = [NSMutableDictionary dictionary];
    self.joinedRosterIds = [NSArray array];
    self.filteredRosterArray = [NSArray array];
    [self.view addSubview:self.tableView];
    
    [self getMembers];
    [self getAllRoster];
    
}

#pragma mark - TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredRosterArray.count;
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
    BMXRoster* roster = [self.filteredRosterArray objectAtIndex:indexPath.row];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BMXRoster* roster = [self.filteredRosterArray objectAtIndex:indexPath.row];
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
    [[[BMXClient sharedClient] rosterService] searchRostersByRosterIdList:idArray forceRefresh:YES completion:^(NSArray<BMXRoster *> *rosterList, BMXError *error) {
        MAXLog(@"%ld", rosterList.count);
        self.rosterArray = [NSArray arrayWithArray:rosterList];
        [self filterData];
    }];
}

// 获取群成员
- (void)getMembers {
    [[[BMXClient sharedClient] groupService] getMembers:self.group forceRefresh:YES completion:^(NSArray<BMXGroupMember *> *groupList, BMXError *error) {
        MAXLog(@"%ld", groupList.count);
        NSMutableArray* muarr = [NSMutableArray array];
        for (BMXGroupMember* amember in groupList) {
            NSString* uid = [NSString stringWithFormat:@"%ld", amember.uid];
            [muarr addObject:uid];
        }
        self.joinedRosterIds = [NSArray arrayWithArray:muarr];
        [self filterData];
    }];
}

-(void) filterData
{
    NSMutableArray* arr = [NSMutableArray array];
    for (BMXRoster* roster in self.rosterArray) {
        NSString* uid = [NSString stringWithFormat:@"%lld", roster.rosterId];
        if(![self.joinedRosterIds containsObject:uid]) {
            [arr addObject:roster];
        }
    }
    self.filteredRosterArray = [NSArray arrayWithArray:arr];
    [self.tableView reloadData];
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NavHeight, MAXScreenW, MAXScreenH - NavHeight) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

-(void) touchedRightBar
{
    NSMutableArray* ids = [NSMutableArray array];
    NSArray* allKey = _selectedUids.allKeys;
    for (NSString* idkey in allKey) {
        if ([[_selectedUids objectForKey:idkey] isEqualToString:@"1"]) {
            [ids addObject:[NSNumber numberWithLongLong:[idkey longLongValue]]];
        }
    }
    if(ids.count == 0 ) {
        MAXLog(@"please select ....");
    }else {
        [self showAlertWithIds:ids];
    }
}

-(void) showAlertWithIds:(NSArray*) ids {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"enter_your_invitation_message", @"请输入邀请消息") preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"取消") style:UIAlertActionStyleCancel handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", @"确定") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField* tfield = alertController.textFields.firstObject;
        NSString* message = tfield.text;
        [[[BMXClient sharedClient] groupService] addMembersToGroup:self.group memberIdlist:ids message:message completion:^(BMXError *error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"KEY_NOTIFICATION_GROUP_MEMBER_UPDATED" object:nil];
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }]];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField* textField) {
        textField.placeholder=NSLocalizedString(@"enter_your_invitation_message", @"请输入邀请消息");
    }];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

- (void)setUpNavItem {
    [self setNavigationBarTitle: NSLocalizedString(@"Set_group_members", @"设置群组成员") navLeftButtonIcon:@"blackback" navRightButtonTitle:NSLocalizedString(@"Save", @"保存")];
    [self.navRightButton addTarget:self action:@selector(touchedRightBar) forControlEvents:UIControlEventTouchUpInside];
}


@end
