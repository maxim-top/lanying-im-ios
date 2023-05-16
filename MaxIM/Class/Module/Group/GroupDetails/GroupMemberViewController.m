//
//  ----------------------------------------------------------------------
//   File    :  GroupMemberViewController.m
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
    

#import "GroupMemberViewController.h"
#import "GorupLittleCell.h"
#import <floo-ios/floo_proxy.h>
#import "MAXUtils.h"
#import "IMAcount.h"
#import "IMAcountInfoStorage.h"
#import "ChatRosterProfileViewController.h"
#import "UIViewController+CustomNavigationBar.h"

@interface GroupMemberViewController ()<UITabBarDelegate, UITableViewDataSource>
{
    NSMutableDictionary* _adlinDictionary;
    BOOL _isAdmin;
}
@property (nonatomic ,strong) NSArray* memberList;
@property (nonatomic, strong) UITableView* tableView;
@end

@implementation GroupMemberViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];

    
    self.memberList = [NSArray array];
    _adlinDictionary = [NSMutableDictionary dictionary];
    [self setUpNavItem];
    [self initViews];
    [self getMembers];
    [self getManageList];
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
    if(cell == nil) {
        cell = [[GorupLittleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GorupLittleCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    BMXRosterItem* roster = [self.memberList objectAtIndex:indexPath.row];
    NSString* uname = (roster.nickname && ![@"" isEqualToString:roster.nickname]) ? roster.nickname : roster.username;
    NSString* rosterIdStr = [NSString stringWithFormat:@"%lld", roster.rosterId];
    BOOL isAdmin = [[_adlinDictionary objectForKey:rosterIdStr] boolValue];
    [cell setAvatarStr:roster.avatarUrl RosterName:uname Selected:NO];
    [cell showAdmin:isAdmin];
    [cell setDlownAvatar:roster Selected:NO];
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    BMXRosterItem* roster = [self.memberList objectAtIndex:indexPath.row];
    ChatRosterProfileViewController *vc = [[ChatRosterProfileViewController alloc] initWithRoster:roster];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

-(BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL canEdit = NO;
    BMXRosterItem* roster = [self.memberList objectAtIndex:indexPath.row];
    NSString* rosterIdStr = [NSString stringWithFormat:@"%lld", roster.rosterId];
    
    if([self isSelf:rosterIdStr]) { //是自己
        //
    }else if([self isOwner]) {
        canEdit = YES;
    }else if(_isAdmin && ![[_adlinDictionary objectForKey:rosterIdStr] boolValue]) { //自己是管理员，并且对方不是
        canEdit = YES;
    }
    return canEdit;
}

- (NSArray*)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:NSLocalizedString(@"Delete", @"删除") handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                         {
                                             [tableView setEditing:NO animated:YES];
                                             BMXRosterItem* roster = self.memberList [indexPath.row];
                                             [self deleteR:roster];
                                         }];
    
    UITableViewRowAction *blackAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:NSLocalizedString(@"Add_to_blacklist", @"加入黑名单") handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
    {
        [tableView setEditing:NO animated:YES];
        [self blackMember:indexPath.row];
    }];
    // 创建action
    UITableViewRowAction *muteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:NSLocalizedString(@"Ban", @"禁言") handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
    {
        [tableView setEditing:NO animated:YES];
        [self muteMember:indexPath.row];
    }];
    return @[deleteAction ,blackAction, muteAction];
}

- (void) blackMember:(NSInteger) index
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Warning", @"警告") message:NSLocalizedString(@"Confirm_to_blacklist", @"确定加入黑名单？") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", @"确定") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        BMXRosterItem* roster = [self.memberList objectAtIndex:index];
        long long rosterId = roster.rosterId;
        ListOfLongLong *members = [[ListOfLongLong alloc] init];
        [members addWithX:&rosterId];
        [[[BMXClient sharedClient] groupService] blockMembersWithGroup:self.group members:members completion:^(BMXError *error) {
            if(!error) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"KEY_NOTIFICATION_GROUP_MEMBER_UPDATED" object:nil];
                [self getMembers];
            }
        }];
    }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"取消") style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {}];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}
- (void) muteMember:(NSInteger) index
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Warning", @"警告") message:NSLocalizedString(@"Confirm_to_ban", @"确定要禁言吗？") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", @"确定") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        BMXRosterItem* roster = [self.memberList objectAtIndex:index];
        long long rosterId = roster.rosterId;
        ListOfLongLong *members = [[ListOfLongLong alloc] init];
        [members addWithX:&rosterId];
        NSString* muteDurationStr = [alert.textFields objectAtIndex:0].text;
        long long duration = [muteDurationStr longLongValue];
        [[[BMXClient sharedClient] groupService] banMembersWithGroup:self.group members:members duration:duration reason:NSLocalizedString(@"Ban", @"禁言") completion:^(BMXError *error) {
            if (error) {
                MAXLog(@"mute member error, code: %ld", (long)[error errorCode]);
            }
        }];
    }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"取消") style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {  }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = NSLocalizedString(@"enter_the_ban_time", @"请输入禁言时间");
    }];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
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

- (void)setUpNavItem {
    self.navigationItem.title = NSLocalizedString(@"Group_members", @"群成员");
    [self setNavigationBarTitle:NSLocalizedString(@"Group_members", @"群成员") navLeftButtonIcon:@"blackback"];
    
}

- (void)deleteR:(BMXRosterItem *)roster{
    long long rosterId = roster.rosterId;
    ListOfLongLong *members = [[ListOfLongLong alloc] init];
    [members addWithX:&rosterId];

    [[[BMXClient sharedClient] groupService]removeMembersWithGroup:self.group members:members reason:@"" completion:^(BMXError *error) {
        if (!error) {
            [HQCustomToast showDialog:NSLocalizedString(@"Delete_successfully", @"删除成功")];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"KEY_NOTIFICATION_GROUP_MEMBER_UPDATED" object:nil];
            [self getMembers];
        }
    }];
}

// 获取群成员
- (void)getMembers {
    [MAXUtils getMemberIdsWithGroup:self.group completion:^(ListOfLongLong *list) {
        [self getRostersByidArray:list];
    }];
}

// 获取群成员详情
- (void)getRostersByidArray:(ListOfLongLong *)idList {
    [MAXUtils getRostersByidArray:idList completion:^(NSArray *arr) {
         self.memberList = arr;
         [self.tableView reloadData];
    }];
}

-(void) getManageList // 管理员不能被操作.
{
    [[[BMXClient sharedClient] groupService] getAdmins:self.group forceRefresh:YES completion:^(BMXGroupMemberList *adminList, BMXError *error) {
        unsigned long sz = adminList.size;
        for (int i=0; i<sz; i++) {
            BMXGroupMember* member = [adminList get:i];
            NSString* uidStr = [NSString stringWithFormat:@"%lld", member.getMUid];
            if([self isSelf:uidStr]) {
                self->_isAdmin = YES;
            }
            [self->_adlinDictionary setObject:[NSNumber numberWithBool:YES] forKey:uidStr];
        }
        if (adminList != nil && adminList.size > 0) {
            [self->_tableView reloadData];
        }
    }];
}


- (BOOL) isSelf:(NSString*) compareId
{
    IMAcount* acc = [IMAcountInfoStorage loadObject];
    NSString* currentAccId = acc.usedId;
    return [compareId isEqualToString:currentAccId];
}

- (BOOL) isOwner
{
    NSString* ownerStr = [NSString stringWithFormat:@"%lld", self.group.ownerId] ;
    IMAcount* acc = [IMAcountInfoStorage loadObject];
    NSString* currentAccId = acc.usedId;
    return [ownerStr isEqualToString:currentAccId];
}


@end
