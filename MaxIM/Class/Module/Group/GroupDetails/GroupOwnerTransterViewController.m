//
//  ----------------------------------------------------------------------
//   File    :  GroupOwnerTransterViewController.m
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
    

#import "GroupOwnerTransterViewController.h"
#import "GorupLittleCell.h"
#import "BMXClient.h"
#import "BMXGroupMember.h"
#import "BMXRoster.h"
#import "UIViewController+CustomNavigationBar.h"


@interface GroupOwnerTransterViewController ()<UITabBarDelegate, UITableViewDataSource>
{
    NSInteger _selectedIndex ;
}

@property (nonatomic ,strong) NSArray* memberList;

@property (nonatomic, strong) UITableView* tableView;
@end

@implementation GroupOwnerTransterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];

    self.memberList = [NSArray array];
    
    [self setUpNavItem];
    [self initViews];
    [self getMembers];
    
//    self.isTransformMessage = YES;
    
}

-(void) initViews
{
    [self.view addSubview:self.tableView];
}

#pragma mark == tableview delegate
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.memberList.count;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    return 60;
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GorupLittleCell* cell = [tableView dequeueReusableCellWithIdentifier:@"GorupLittleCell"];
    BMXRoster* roster = [self.memberList objectAtIndex:indexPath.row];
    if(cell == nil) {
        cell = [[GorupLittleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GorupLittleCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NSString* uname = (roster.nickName && ![@"" isEqualToString:roster.nickName]) ? roster.nickName : roster.userName;
    BOOL isSelected = indexPath.row == _selectedIndex;
    [cell setAvatarRoster:roster RosterName:uname Selected:isSelected];
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    BMXRoster* roster = [self.memberList objectAtIndex:indexPath.row];

//    if (self.isTransformMessage) {
//        if (self.delegate && [self.delegate respondsToSelector:@selector(groupOwnerTransterVCdidSelect:)]) {
//            [self.delegate groupOwnerTransterVCdidSelect:roster];
//            [self.navigationController popViewControllerAnimated:YES];
//            self.isTransformMessage =NO;
//        }
//
//    } else {
//
    if(_selectedIndex > -1) {
        GorupLittleCell* old = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_selectedIndex inSection:0]];
        [old setSelect:NO];
    }
    GorupLittleCell* current = [tableView cellForRowAtIndexPath:indexPath];
    [current setSelect:YES];
    _selectedIndex = indexPath.row;
//    }
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NavHeight, MAXScreenW, MAXScreenH - NavHeight) style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor lh_colorWithHex:0xffffff];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.tableHeaderView = [[UIView alloc] init];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
    return _tableView;
}

-(void) touchedRightBar
{
    BMXRoster* roster = [self.memberList objectAtIndex:_selectedIndex];
    NSString* ownerIdStr = [NSString stringWithFormat:@"%ld", self.group.ownerId];
    NSString* rosterIdStr = [NSString stringWithFormat:@"%lld", roster.rosterId];
    if([ownerIdStr isEqualToString:rosterIdStr] || _selectedIndex == -1) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"警告" message:@"您选的群主没有改变" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }else {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"警告" message:@"确定要转让群主么？" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self transferOwner];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

-(void) transferOwner
{
    BMXRoster* roster = [self.memberList objectAtIndex:_selectedIndex];
    [[[BMXClient sharedClient] groupService] transferOwnerByGroup:self.group newOwnerId:roster.rosterId completion:^(BMXError *error) {
        if (error) {
            MAXLog(@"group transfer error: %d", error.errorCode);
        }else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

- (void)setUpNavItem {
    [self setNavigationBarTitle:@"群主转让" navLeftButtonIcon:@"blackback" navRightButtonTitle:@"保存"];
    [self.navRightButton addTarget:self action:@selector(touchedRightBar) forControlEvents:UIControlEventTouchUpInside];
}


// 获取群成员
- (void)getMembers {
    [[[BMXClient sharedClient] groupService] getMembers:self.group forceRefresh:YES completion:^(NSArray<BMXGroupMember *> *groupList, BMXError *error) {
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
    [[[BMXClient sharedClient] rosterService] searchRostersByRosterIdList:idArray forceRefresh:YES completion:^(NSArray<BMXRoster *> *rosterList, BMXError *error) {
        MAXLog(@"%ld", rosterList.count);
        self.memberList = [NSArray arrayWithArray: rosterList];
        for (NSInteger i=0; i<self.memberList.count; i++) {
            BMXRoster* roster = [self.memberList objectAtIndex:i];
            NSString* ownerIdStr = [NSString stringWithFormat:@"%ld", self.group.ownerId];
            NSString* rosterIdStr = [NSString stringWithFormat:@"%lld", roster.rosterId];
            if([ownerIdStr isEqualToString:rosterIdStr]) {
                _selectedIndex = i;
            }
            
        }
        [self.tableView reloadData];
    }];
}


@end
