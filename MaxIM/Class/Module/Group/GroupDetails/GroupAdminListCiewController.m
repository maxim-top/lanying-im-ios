//
//  ----------------------------------------------------------------------
//   File    :  GroupAdminListCiewController.m
//   Author  : shaohui.yang shaohui@bmxlabs.com
//   Purpose :
//   Created : 2018/12/25 by shaohui.yang shaohui@bmxlabs.com
//
//  ----------------------------------------------------------------------
//
//                    Copyright (C) 2018-2019   MaxIM.Top
//
// You may obtain a copy of the licence at http://www.maxim.top/LICENCE-MAXIM.md
//
//  ----------------------------------------------------------------------
    

#import "GroupAdminListCiewController.h"

#import "GorupLittleCell.h"
#import <floo-ios/BMXClient.h>
#import <floo-ios/BMXGroupMember.h>
#import <floo-ios/BMXRoster.h>

#import "IMAcount.h"
#import "IMAcountInfoStorage.h"
#import "UIViewController+CustomNavigationBar.h"

@interface GroupAdminListCiewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSDictionary* userHash;

@property (nonatomic, strong) NSMutableArray* adminUidArray;
@property (nonatomic, strong) NSMutableArray* normalUidArray;
@property (nonatomic, strong) NSArray* allUidArray;

@property (nonatomic, strong) UITableView* tableView;

@end

@implementation GroupAdminListCiewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpNavItem];
    self.userHash = [NSDictionary dictionary];
    
    self.adminUidArray = [NSMutableArray array];
    self.normalUidArray = [NSMutableArray array];
    self.allUidArray = [NSArray array];
    [self.view addSubview:self.tableView];
    
    [self getMembers];
    [self getManageList];
}

#pragma mark == tableview delegate
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return section == 0 ? self.adminUidArray.count : self.normalUidArray.count;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    return 60;
}

-(UIView*) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] init];
}
-(CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.5;
}

-(UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* sv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MAXScreenW, 24)];
    sv.backgroundColor = [UIColor lh_colorWithHexString:@"EEEEEE"];
    UILabel* sl = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 200, 24)];
    [sv addSubview:sl];
    sl.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14];
    sl.textColor = [UIColor colorWithRed:155/255.0 green:155/255.0 blue:169/255.0 alpha:1/1.0];
    sl.text = section == 1 ? @"普通用户" : @"管理员";
    return sv;
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 24;
}


-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    GorupLittleCell* cell = [tableView dequeueReusableCellWithIdentifier:@"GorupLittleCell"];
    NSMutableArray* arr = section == 0 ? self.adminUidArray : self.normalUidArray;
    NSString* rosterId = [arr objectAtIndex:indexPath.row];
    if(cell == nil) {
        cell = [[GorupLittleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GorupLittleCell"];
    }
    NSString* name = rosterId;
    NSString* avatar = rosterId;
    BMXRoster* roster = [self.userHash objectForKey:rosterId];
    if(roster != nil) {
        name = roster.nickName;
        if(!name || [@"" isEqualToString:name]) {
            name = roster.userName;
        }
        avatar = roster.avatarUrl;
    }
    [cell setAvatarUrl:avatar RosterName:name Selected:NO];
    [cell setDlownAvatar:roster Selected:NO];
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    [self dealWithMembersWithSection:section Row:row];
}

-(void) dealWithMembersWithSection:(NSInteger) section Row:(NSInteger) row
{
    if(section == 0) {// 取消管理
        NSString* uid = [self.adminUidArray objectAtIndex:row];
        [[[BMXClient sharedClient] groupService] removeAdmins:self.group admins:@[uid] reason:@"添加管理" completion:^(BMXError *error) {
            if(!error) {
                [self.adminUidArray removeObject:uid];
                [self.normalUidArray addObject:uid];
                [self.tableView reloadData];
            }else {
                MAXLog(@"error : %ld", error.errorCode);
            }
            
        }];
    }else { //添加管理
        NSString* uid = [self.normalUidArray objectAtIndex:row];
        [[[BMXClient sharedClient] groupService] addAdmins:self.group admins:@[uid] message:@"取消管理" completion:^(BMXError *error) {
            if(!error) {
                [self.normalUidArray removeObject:uid];
                [self.adminUidArray addObject:uid];
                [self.tableView reloadData];
            }else {
                MAXLog(@"error : %ld", error.errorCode);
            }
        }];
    }
}


- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NavHeight, MAXScreenW, MAXScreenH - NavHeight - TabBarHeight) style:UITableViewStyleGrouped];
        _tableView.backgroundColor = [UIColor lh_colorWithHex:0xffffff];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
    return _tableView;
}

- (void)setUpNavItem {
    [self setNavigationBarTitle:@"群管理员" navLeftButtonIcon:@"blackback"];
    
//    UIButton *moreBtn = [UIButton buttonWithType:UIButtonTypeSystem];
//    [moreBtn setTitle:@"Save" forState:UIControlStateNormal];
//    [moreBtn addTarget:self action:@selector(touchedRightBar) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *moreItem = [[UIBarButtonItem alloc] initWithCustomView:moreBtn];
//    self.navigationItem.rightBarButtonItem = moreItem;
}


// 获取管理员列表
-(void) getManageList
{
    [[[BMXClient sharedClient] groupService] getAdmins:self.group forceRefresh:YES completion:^(NSArray<BMXGroupMember *> *adminList, BMXError *error) {
        NSMutableArray* adminMularr = [NSMutableArray array];
        IMAcount* acc = [IMAcountInfoStorage loadObject];
        NSString* currentUid  = acc.usedId;
        for (BMXGroupMember* member in adminList) {
            NSString* uidStr = [NSString stringWithFormat:@"%ld", member.uid];
            if(![uidStr isEqualToString:currentUid]) {
                [adminMularr addObject:uidStr];
            }
        }
        self.adminUidArray = [NSMutableArray arrayWithArray:adminMularr];
        [self configureNormalUids];
        [self.tableView reloadData];
    }];
}

// 获取群成员
- (void)getMembers {
    [[[BMXClient sharedClient] groupService] getMembers:self.group forceRefresh:YES completion:^(NSArray<BMXGroupMember *> *groupList, BMXError *error) {
        MAXLog(@"%ld", groupList.count);
        NSMutableArray* array = [NSMutableArray array];
        NSMutableArray* normalMemberArr = [NSMutableArray array];
        IMAcount* acc = [IMAcountInfoStorage loadObject];
        NSString* currentUid  = acc.usedId;
        for (BMXGroupMember* amember in groupList) {
            NSString* uidStr = [NSString stringWithFormat:@"%ld", amember.uid];
            if(![uidStr isEqualToString:currentUid]) {
                [array addObject:uidStr];
            }
        }
        self.allUidArray = [NSArray arrayWithArray:array];
        [self configureNormalUids];
        [self getRostersByidArray:array];
    }];
}

// 获取群成员详情
- (void)getRostersByidArray:(NSArray *)idArray {
    [[[BMXClient sharedClient] rosterService] searchRostersByRosterIdList:idArray forceRefresh:YES completion:^(NSArray<BMXRoster *> *rosterList, BMXError *error) {
        MAXLog(@"%ld", rosterList.count);
        NSMutableDictionary* dict = [NSMutableDictionary dictionary];
        for (BMXRoster* roster in rosterList) {
            NSString* uid = [NSString stringWithFormat:@"%lld", roster.rosterId];
            [dict setObject:roster forKey:uid];
        }
        self.userHash = [NSDictionary dictionaryWithDictionary:dict];
        [self.tableView reloadData];
    }];
}
- (void) configureNormalUids
{
    NSMutableArray* arr = [NSMutableArray array];
    for (NSString* uid in self.allUidArray) {
        if(![self.adminUidArray containsObject:uid]) {
            [arr addObject:uid];
        }
    }
    self.normalUidArray = [NSMutableArray arrayWithArray:arr];
}

@end
