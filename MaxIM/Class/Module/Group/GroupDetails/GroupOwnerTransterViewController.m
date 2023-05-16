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
#import <floo-ios/floo_proxy.h>
#import "MAXUtils.h"
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
    BMXRosterItem* roster = [self.memberList objectAtIndex:indexPath.row];
    if(cell == nil) {
        cell = [[GorupLittleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GorupLittleCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NSString* uname = (roster.nickname && ![@"" isEqualToString:roster.nickname]) ? roster.nickname : roster.username;
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
    BMXRosterItem* roster = [self.memberList objectAtIndex:_selectedIndex];
    NSString* ownerIdStr = [NSString stringWithFormat:@"%lld", self.group.ownerId];
    NSString* rosterIdStr = [NSString stringWithFormat:@"%lld", roster.rosterId];
    if([ownerIdStr isEqualToString:rosterIdStr] || _selectedIndex == -1) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Warning", @"警告") message:NSLocalizedString(@"The_group_owner_you_selected_has_no_changed", @"您选的群主没有改变") preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", @"确定") style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }else {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Warning", @"警告") message:NSLocalizedString(@"Confirm_to_transfer_the_group_owner", @"确定要转让群主么？") preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", @"确定") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self transferOwner];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"取消") style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

-(void) transferOwner
{
    BMXRosterItem* roster = [self.memberList objectAtIndex:_selectedIndex];
    [[[BMXClient sharedClient] groupService] transferOwnerWithGroup:self.group newOwnerId:roster.rosterId completion:^(BMXError *error) {
        if (error) {
            MAXLog(@"group transfer error: %ld", (long)error.errorCode);
        }else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

- (void)setUpNavItem {
    [self setNavigationBarTitle:NSLocalizedString(@"Group_owner_transferred", @"群主转让") navLeftButtonIcon:@"blackback" navRightButtonTitle:NSLocalizedString(@"Save", @"保存")];
    [self.navRightButton addTarget:self action:@selector(touchedRightBar) forControlEvents:UIControlEventTouchUpInside];
}


// 获取群成员
- (void)getMembers {
    [MAXUtils getMemberIdsWithGroup:self.group completion:^(ListOfLongLong *idList) {
        [self getRostersByidArray:idList];;
    }];
}

// 获取群成员详情
- (void)getRostersByidArray:(ListOfLongLong *)idList {
    [MAXUtils getRostersByidArray:idList completion:^(NSArray *arr) {
        MAXLog(@"%ld", arr.count);
        self.memberList = arr;
        for (NSInteger i=0; i<self.memberList.count; i++) {
            BMXRosterItem* roster = [self.memberList objectAtIndex:i];
            NSString* ownerIdStr = [NSString stringWithFormat:@"%lld", self.group.ownerId];
            NSString* rosterIdStr = [NSString stringWithFormat:@"%lld", roster.rosterId];
            if([ownerIdStr isEqualToString:rosterIdStr]) {
                self->_selectedIndex = i;
            }
        }

        [self.tableView reloadData];
    }];

}


@end
