//
//  ----------------------------------------------------------------------
//   File    :  GroupDetail.m
//   Author  : shaohui.yang shaohui@bmxlabs.com
//   Purpose :
//   Created : 2018/12/24 by shaohui.yang shaohui@bmxlabs.com
//
//  ----------------------------------------------------------------------
//
//                    Copyright (C) 2018-2019   MaxIM.Top
//
// You may obtain a copy of the licence at http://www.maxim.top/LICENCE-MAXIM.md
//
//  ----------------------------------------------------------------------
    

#import "GroupManageViewController.h"
#import "GroupChangeNameViewController.h"
#import "GroupAdminListCiewController.h"
#import "GroupMemberViewController.h"
#import "GroupPublicViewController.h"
#import "GroupExtViewController.h"
#import "GroupFileViewController.h"
#import <floo-ios/BMXGroupMember.h>
#import <floo-ios/BMXUserProfile.h>
#import "GroupCommonCell.h"
#import "IMAcount.h"
#import "IMAcountInfoStorage.h"

#import "CodeImageViewController.h"
#import "GroupCollectionView.h"
#import "SearchContentViewController.h"

#import <floo-ios/BMXConversation.h>

@interface GdetailSettingCell : UITableViewCell
{
    UILabel* detailLabel;
}
-(void) cellContent:(NSString*) title withDetail:(NSString*) detail;
@end

@implementation GdetailSettingCell

-(instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.textLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16];
    self.textLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1/1.0];
    return self;
}

-(void) cellContent:(NSString*) title withDetail:(NSString*) detail {
    self.textLabel.text = title;
    if(detail != nil && ![detail isEqualToString:@""]) {
        self.detailTextLabel.text = detail;
        self.accessoryType = UITableViewCellAccessoryNone;
    }else {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
}

@end


#import "GroupDetailViewController.h"
#import <floo-ios/BMXClient.h>
#import <floo-ios/BMXGroup.h>
#import "GroupAddMemberController.h"
#import "UIViewController+CustomNavigationBar.h"


@interface GroupDetailViewController ()<UITableViewDelegate, UITableViewDataSource, GroupManagerProtocol>
{
    NSMutableArray* _settingDict;
    BOOL _isAdmin;
}
@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) GroupCollectionView* collectionView;
@property (nonatomic, strong) UIButton* leaveBtn;
@property (nonatomic, strong) NSArray* memberList;

@end

@implementation GroupDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setNavigationBarTitle:self.group.name navLeftButtonIcon:@"blackback"];
    
    self.memberList = [NSArray array];
    _isAdmin = NO;
    _settingDict = @[
                     @{@"title":NSLocalizedString(@"Group_ID", @"群ID"), @"detail":@"11122233"},
                     @{@"title":NSLocalizedString(@"My_nickname_in_group", @"我在群里的昵称"), @"detail":@"11122233"},
                     @{@"title":NSLocalizedString(@"Group_QR_Code", @"群二维码"), @"detail":@""},
                     @{@"title":NSLocalizedString(@"Search_chat_history", @"搜索聊天记录"), @"detail":@""},
                     @{@"title":NSLocalizedString(@"Group_management", @"群管理"), @"detail":@""},
                     @{@"title":NSLocalizedString(@"Modify_group_name", @"修改群名称"), @"detail":@""},
                     @{@"title":NSLocalizedString(@"Admin_list", @"管理员列表"), @"detail":@""},
                     @{@"title":NSLocalizedString(@"Group_announcement", @"群公告"), @"detail":@""},
                     @{@"title":NSLocalizedString(@"Group_extension_info", @"群扩展信息"), @"detail":@""},
                     @{@"title":NSLocalizedString(@"List_of_group_shared_list", @"群共享列表"), @"detail":@""},
                     ];
    [self.view addSubview:self.tableView];
    [self registeNotifications];
    [self getMembers];
    [self addLeaveBtn];
    [self getAdminList];
    [self get];
}

#pragma mark - group manager


- (void)get {
    [[[BMXClient sharedClient ] groupService] getSharedFilesListByGroup:self.group forceRefresh:YES
                                                             completion:^(NSArray<BMXGroupSharedFile *> *sharedFileList, BMXError *error) {
        MAXLog(@"%lu", (unsigned long)sharedFileList.count);
    }];
}
// 离开群
- (void)leaveGroup {
    [[[BMXClient sharedClient] groupService] leaveGroup:self.group completion:^(BMXError *error) {
        if (!error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"KGroupListModified" object:nil];
            NSInteger currentIndex = [[self.navigationController viewControllers] indexOfObject:self];
            [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:currentIndex-2] animated:YES];
        }
    }];
}

// 解散群
- (void) destroyGroup {
    [[[BMXClient sharedClient] groupService] destroyGroup:self.group completion:^(BMXError *error) {
        if (!error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"KGroupListModified" object:nil];
            NSInteger currentIndex = [[self.navigationController viewControllers] indexOfObject:self];
            [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:currentIndex-2] animated:YES];
        }
    }];
}

// 获取群详情
- (void)getGroupDetailInfo {
    [[[BMXClient sharedClient] groupService] loadGroupInfo:self.group completion:^(BMXGroup *group, BMXError *error) {
        if(!error) {
            self.group = group;
            [self.tableView reloadData];
        }
    }];
}

// 获取群成员
- (void)getMembers {
    [[[BMXClient sharedClient] groupService] getMembers:self.group forceRefresh:YES completion:^(NSArray<BMXGroupMember *> *groupList, BMXError *error) {
        MAXLog(@"%lu", (unsigned long)groupList.count);
        NSMutableArray* array = [NSMutableArray array];
        for (BMXGroupMember* amember in groupList) {
            NSString* uidStr = [NSString stringWithFormat:@"%ld", (long)amember.uid];
            [array addObject:uidStr];
        }
        [self getRostersByidArray:array];
    }];
}

// 获取群成员详情
- (void)getRostersByidArray:(NSArray *)idArray {
    [[[BMXClient sharedClient] rosterService] searchRostersByRosterIdList:idArray forceRefresh:NO completion:^(NSArray<BMXRoster *> *rosterList, BMXError *error) {
        MAXLog(@"%ld", rosterList.count);
        self.memberList = [NSArray arrayWithArray: rosterList];
        [self.collectionView fillRosterList:rosterList limit2line:YES];
        [self.tableView reloadData];
    }];
}


// 添加成员
- (void)addMembersWithmembersId:(NSArray*)membersId message:(NSString *)message {
    [[[BMXClient sharedClient] groupService] addMembersToGroup:self.group memberIdlist:membersId message:message completion:^(BMXError *error) {
        if (!error) {
            MAXLog(@"添加成功");
        }
    }];
}


// 删除群成员
- (void)removeMembersWithMembersId:(NSArray*)membersId message:(NSString *)message {
    [[[BMXClient sharedClient] groupService] removeMembersWithGroup:self.group memberlist:membersId reason:message completion:^(BMXError *error) {
        if (!error) {
            MAXLog(@"添加成功");
        }
    }];
}

// 添加管理员
- (void)addAdminsId:(NSArray*)adminsId message:(NSString *)message {
    [[[BMXClient sharedClient] groupService] addAdmins:self.group admins:adminsId message:message completion:^(BMXError *error) {
        if (!error) {
            MAXLog(@"添加管理员成功");
        }
    }];
}

#pragma mark == tableview delegate
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0 ) {
        return 1;
    }
    if([self isOwner]) {
        return 8;
    }else if(_isAdmin) {
        return  7;
    }
    return 4;
    
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 42;
}
-(CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}
-(UIView*) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] init];
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    NSInteger section = indexPath.section;
    if(section == 0) {
        if(self.memberList.count == 0){
            return 0 ;
        }
        return [GroupCollectionView calcHeightWithArrcount:self.memberList.count limt:YES];
    }
    return 51;
}

-(UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section == 0) {
        return [self sectionHeaderViewWithTitle:NSLocalizedString(@"Group_members", @"群成员") moreClic:@selector(touchedMoreMembers)];
    }else{
        return [self sectionHeaderViewWithTitle:NSLocalizedString(@"Group_settings", @"群设置") moreClic:nil];
    }
//    return [self sectionHeaderViewWithTitle:NSLocalizedString(@"Group_members", @"群成员") moreClic:nil];
}
-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    if(section == 0) {
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"collectioncell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"collectioncell"];
            [cell.contentView addSubview:self.collectionView];
        }
        return cell;
    }else {
        GroupCommonCell* cell = [tableView dequeueReusableCellWithIdentifier:@"GroupCommonCell"];
        if(cell == nil) {
            cell = [[GroupCommonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GroupCommonCell"];
        }
        if(row == 0) {
            [cell setMainText:NSLocalizedString(@"Group_ID", @"群ID") detailText:[NSString stringWithFormat:@"%lld", self.group.groupId] switcherFlag:NO switcherTarget:nil switcherSelector:nil];
        }else if(row == 1) {
            [cell setMainText:NSLocalizedString(@"My_nickname_in_group", @"我在群里的昵称") detailText:self.group.myNickName switcherFlag:NO switcherTarget:nil switcherSelector:nil];
            [cell showAccesor:YES];
        }else if(row == 2) {
            [cell setMainText:NSLocalizedString(@"QR_Code", @"二维码") detailText:@"" switcherFlag:NO switcherTarget:nil switcherSelector:nil];
            [cell showAccesor:YES];
        }else if(row == 3) {
            [cell setMainText:NSLocalizedString(@"Search_chat_history", @"搜索聊天记录") detailText:@"" switcherFlag:NO switcherTarget:nil switcherSelector:nil];
            [cell showAccesor:YES];
        } else if(row == 4) {
            [cell setMainText:NSLocalizedString(@"Group_announcement", @"群公告") detailText:@"" switcherFlag:NO switcherTarget:nil switcherSelector:nil];
            [cell showAccesor:YES];
        }else if(row == 5) {
            [cell setMainText:NSLocalizedString(@"Modify_group_name", @"修改群名称") detailText:@"" switcherFlag:NO switcherTarget:nil switcherSelector:nil];
            [cell showAccesor:YES];
        } else if(row == 6) {
            [cell setMainText:NSLocalizedString(@"Group_management", @"群管理") detailText:@"" switcherFlag:NO switcherTarget:nil switcherSelector:nil];
            [cell showAccesor:YES];
        } else if(row == 7) {
            [cell setMainText:NSLocalizedString(@"Admin_list", @"管理员列表") detailText:@"" switcherFlag:NO switcherTarget:nil switcherSelector:nil];
            [cell showAccesor:YES];
            [cell showSepLine:NO];
        }
        return cell;
    }
}

/**
 @{@"title":NSLocalizedString(@"Admin_list", @"管理员列表"), @"detail":@""},
 @{@"title":NSLocalizedString(@"Group_announcement", @"群公告"), @"detail":@""},
 @{@"title":NSLocalizedString(@"Group_extension_info", @"群扩展信息"), @"detail":@""},
 @{@"title":NSLocalizedString(@"List_of_group_shared_list", @"群共享列表"), @"detail":@""},
 **/

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    NSArray* arr = @[@"CodeImageViewController",
                     @"SearchContentViewController",
                     @"GroupPublicViewController",
                     @"GroupChangeNameViewController",
                     @"GroupManageViewController",
                     @"GroupAdminListCiewController",
                     @"GroupExtViewController",
                     @"GroupFileViewController"];
    if (row == 1) {
        [self showalert];
        return;
    }
    
    if(section == 1 && row > 1) {
        NSString* className = [arr objectAtIndex:row-2];
        if ([className isEqualToString: @"SearchContentViewController"]) {
            SearchContentViewController *vc = [[SearchContentViewController alloc] initWithSearchContentType:BMXContentTypeText conversation:self.conversation];
            vc.isConversation = YES;
            [self.navigationController pushViewController:vc animated:YES];
            return;
        }
        
        if ([className isEqualToString: @"CodeImageViewController"]) {
            
            MAXLog(@"%u", self.group.inviteMode);
            if (self.group.inviteMode == BMXGroupInviteModeOpen ) {
                CodeImageViewController * vc = [[CodeImageViewController alloc] initWithGroup:self.group];
                [self.navigationController pushViewController:vc animated:YES];
                return;
            }else {
                [HQCustomToast showDialog:NSLocalizedString(@"contact_Admin_to_enable_QR_Code", @"请联系管理员开通二维码")];
                return;
            }
        }
        UIViewController* ctrl = [[NSClassFromString(className) alloc] initWithGroup:self.group] ;
        ctrl.hidesBottomBarWhenPushed = YES;
        if ([className isEqualToString:@"GroupManageViewController"]) {
            GroupManageViewController *vc = (GroupManageViewController *)ctrl;
            vc.delegate = self;
        }
        [self.navigationController pushViewController:ctrl animated:YES];
    }
}


- (void)showalert {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"My_nickname_in_group", @"我在群里的昵称")
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", @"确定") style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
                                                         //响应事件
                                                         //得到文本信息
                                                         for(UITextField *text in alert.textFields){
                                                             MAXLog(@"text = %@", text.text);
                                                             [[[BMXClient sharedClient] groupService] setMyNicknameWithGroup:self.group nickName:text.text completion:^(BMXError *error) {
                                                                 [HQCustomToast showDialog:NSLocalizedString(@"Set_successfully", @"设置成功")];
                                                                 [self.tableView reloadData];
                                                             }];
                                                         }
                                                     }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"取消") style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {
                                                             //响应事件
                                                             MAXLog(@"action = %@", alert.textFields);
                                                         }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = NSLocalizedString(@"enter_nickname", @"请输入昵称");
    }];
    
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}


- (void)updateGroup:(BMXGroup *)group {
    
    self.group = group;
}

#pragma mark  == touch fuctions
-(void) touchedMoreMembers {
    GroupMemberViewController* ctrl = [[GroupMemberViewController alloc] initWithGroup: self.group];
    [ctrl hidesBottomBarWhenPushed];
    [self.navigationController pushViewController: ctrl animated:YES];
}

-(void)touchedLeaveGroup {
    
    BOOL isowner = [self isOwner];
    NSString* title = isowner ? NSLocalizedString(@"Dismiss_group", @"解散群") : NSLocalizedString(@"Quit_group", @"离开群");
    NSString* message = isowner ? NSLocalizedString(@"Confirm_to_dismiss_the_group", @"确定解散群？") : NSLocalizedString(@"Confirm_to_quit_the_group", @"确定离开群？");
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", @"确定") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (isowner) { // dismiss group
            [self destroyGroup];
        }else {
            [self leaveGroup];
        }
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"取消") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        //
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void) addLeaveBtn
{
    CGFloat buttonHeight = MAXIsFullScreen ? 54 + 32 : 54;
    UIView* bottom = [[UIView alloc] initWithFrame:CGRectMake(0, MAXScreenH-buttonHeight, MAXScreenW, buttonHeight)];
    UIView* sline = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MAXScreenW, 0.5)];
    sline.backgroundColor = [UIColor lh_colorWithHexString:@"dfdfdf"];
    [bottom addSubview:sline];
    [bottom addSubview:self.leaveBtn];
    NSString* btnTitle = [self isOwner] ? NSLocalizedString(@"Dismiss_group", @"解散群") : NSLocalizedString(@"Delete_and_quit", @"删除并退出");
    [self.leaveBtn setTitle:btnTitle forState:UIControlStateNormal];
    [self.view addSubview:bottom];
}

#pragma mark - lazy
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NavHeight, MAXScreenW, MAXScreenH - NavHeight -TabBarHeight) style:UITableViewStyleGrouped];
        _tableView.backgroundColor = [UIColor lh_colorWithHex:0xffffff];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}

- (UIButton*)leaveBtn
{
    if(_leaveBtn == nil) {
        _leaveBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        //        [_leaveBtn setTitle:NSLocalizedString(@"Delete_and_quit", @"删除并退出") forState:UIControlStateNormal];
        [_leaveBtn setFrame:CGRectMake(15, 5, MAXScreenW-30, 44)];
        _leaveBtn.layer.masksToBounds = YES;
        _leaveBtn.layer.cornerRadius = 3.0f;
        [_leaveBtn setTintColor:[UIColor lh_colorWithHexString:@"#FF475A"]];
        [_leaveBtn setBackgroundColor:[UIColor whiteColor]];
        [_leaveBtn addTarget:self action:@selector(touchedLeaveGroup) forControlEvents:UIControlEventTouchUpInside];
    }
    return _leaveBtn;
}

-(GroupCollectionView*) collectionView
{
    if(!_collectionView) {
        _collectionView = [[GroupCollectionView alloc] initWithFrame:CGRectMake(0, 0, MAXScreenW, 200)];
        _collectionView.gmCollectionDelegate = self;
    }
    return _collectionView;
}


#pragma mark -- delegate of collection view
-(void) groupMemberCellTouchedRoster:(BMXRoster*) roster
{
    MAXLog(@"you touched ... %@", roster.userName);
}
-(void) groupMemberCellTouchedAdd
{
    GroupAddMemberController* ctrl = [[GroupAddMemberController alloc] initWithGroup:self.group];
    [ctrl hidesBottomBarWhenPushed];
    [self.navigationController pushViewController:ctrl animated:YES];
}


#pragma mark == public functions ...
-(UIView*) sectionHeaderViewWithTitle: (NSString*) title moreClic:(nullable SEL) selector
{
    UIView* sv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MAXScreenW, 42)];
    sv.backgroundColor = [UIColor lh_colorWithHex:0xeeeeee];
    if(selector != nil) {
        UIImageView* simg = [[UIImageView alloc] initWithFrame:CGRectMake(MAXScreenW-64, 0, 44, 42)];
        simg.image = [UIImage imageNamed:@"group_more"];
        simg.contentMode = UIViewContentModeRight;
        [sv addSubview:simg];
        UITapGestureRecognizer* stap = [[UITapGestureRecognizer alloc] initWithTarget:self action:selector];
        sv.userInteractionEnabled = YES;
        [sv addGestureRecognizer:stap];
    }
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, MAXScreenW-100, 22)];
    label.text = title;
    label.font = [UIFont fontWithName:@"PingFangSC-Medium" size:16];
    label.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1/1.0];
    [sv addSubview:label];
    return sv;
}

#pragma mark - notifications
-(void) registeNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifyGroupMemberUpdate) name:@"KEY_NOTIFICATION_GROUP_MEMBER_UPDATED" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifyGroupInfoUpdate) name:@"KEY_NOTIFICATION_GROUP_INFO_UPDATED" object:nil];
}

-(void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) onNotifyGroupMemberUpdate
{
    [self getMembers];
}
-(void) onNotifyGroupInfoUpdate
{
    [self getGroupDetailInfo];
}

- (BOOL) isOwner
{
    NSString* ownerStr = [NSString stringWithFormat:@"%ld", self.group.ownerId] ;
    IMAcount* acc = [IMAcountInfoStorage loadObject];
    NSString* currentAccId = acc.usedId;
    return [ownerStr isEqualToString:currentAccId];
}

-(void) getAdminList
{
    [[[BMXClient sharedClient] groupService] getAdmins:self.group forceRefresh:YES completion:^(NSArray<BMXGroupMember *> *groupMembers, BMXError *error) {
        IMAcount* acc = [IMAcountInfoStorage loadObject];
        NSString* currentStr = acc.usedId;
        for (BMXGroupMember* member in groupMembers) {
            NSString* guidStr = [NSString stringWithFormat:@"%ld", member.uid];
            if([self isSelf:guidStr]) {
                _isAdmin = YES;
            }
        }
        if (_isAdmin) {
            [self.tableView reloadData];
        }
    }];
}

@end
