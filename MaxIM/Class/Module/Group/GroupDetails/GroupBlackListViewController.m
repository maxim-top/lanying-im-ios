//
//  ----------------------------------------------------------------------
//   File    :  GroupBlackListViewController.m
//   Author  : shaohui.yang shaohui@bmxlabs.com
//   Purpose :
//   Created : 2018/12/29 by shaohui.yang shaohui@bmxlabs.com
//
//  ----------------------------------------------------------------------
//
//                    Copyright (C) 2018-2019   MaxIM.Top
//
// You may obtain a copy of the licence at http://www.maxim.top/LICENCE-MAXIM.md
//
//  ----------------------------------------------------------------------
    

#import "GroupBlackListViewController.h"
#import "GorupLittleCell.h"
#import <floo-ios/floo_proxy.h>
#import "MAXUtils.h"
#import "UIViewController+CustomNavigationBar.h"

@interface GroupBlackListViewController ()<UITabBarDelegate, UITableViewDataSource>
{
    NSMutableDictionary* _selectedIdDictionary;
}

@property (nonatomic ,strong) NSArray* blackList;

@property (nonatomic, strong) UITableView* tableView;
@end

@implementation GroupBlackListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.blackList = [NSArray array];
    _selectedIdDictionary = [NSMutableDictionary dictionary];
    
    [self setUpNavItem];
    [self initViews];
    [self getBlackList];
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
    return self.blackList.count;
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
    BMXRosterItem* roster = [self.blackList objectAtIndex:indexPath.row];
    NSString* uname = (roster.nickname && ![@"" isEqualToString:roster.nickname]) ? roster.nickname : roster.username;
    NSString* rosterIdStr = [NSString stringWithFormat:@"%lld", roster.rosterId];
    BOOL isSel = [[_selectedIdDictionary objectForKey:rosterIdStr] boolValue] ;
    [cell setAvatarStr:roster.avatarUrl RosterName:uname Selected:isSel];
    [cell setDlownAvatar:roster Selected:isSel];
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BMXRosterItem* roster = [self.blackList objectAtIndex:indexPath.row];
    NSString* rosterIdStr = [NSString stringWithFormat:@"%lld", roster.rosterId];
    BOOL isSel = [[_selectedIdDictionary objectForKey:rosterIdStr] boolValue];
    [_selectedIdDictionary setObject:[NSNumber numberWithBool:!isSel] forKey:rosterIdStr];
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
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
    ListOfLongLong* xids = [[ListOfLongLong alloc] init];
    for (NSString* uid in _selectedIdDictionary) {
        BOOL issel = [[_selectedIdDictionary objectForKey:uid] boolValue];
        if (issel) {
            long long val = [uid longLongValue];
            [xids addWithX:&val];
        }
    }
    if (xids.size <=0) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Warning", @"警告") message:NSLocalizedString(@"You_have_no_members_selected", @"您没有选中成员") preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", @"确定") style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }else {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Warning", @"警告") message:NSLocalizedString(@"Confirm_to_unblacklist", @"确定要解除黑名单吗？") preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", @"确定") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self removeBlackList:xids];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"取消") style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}


-(void) removeBlackList: (ListOfLongLong*) uids
{
    [[[BMXClient sharedClient] groupService] unblockMembersWithGroup:self.group members:uids completion:^(BMXError *error) {
        if(!error) {
            [self getBlackList];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"KEY_NOTIFICATION_GROUP_MEMBER_UPDATED" object:nil];
            // TODO 优化， 直接从列表中删除
        }else {
            MAXLog(@"request error, code: %ld", (long)[error errorCode]);
        }
    }];
}

- (void)setUpNavItem {
    [self setNavigationBarTitle: NSLocalizedString(@"Group_blacklist", @"群黑名单") navLeftButtonIcon:@"blackback" navRightButtonTitle:NSLocalizedString(@"Unbind", @"解除")];
    [self.navRightButton addTarget:self action:@selector(touchedRightBar) forControlEvents:UIControlEventTouchUpInside];
}


- (void)getBlackList {
    [[[BMXClient sharedClient] groupService] getBlockList:self.group forceRefresh:YES completion:^(BMXGroupMemberList *blockList, BMXError *error) {
        unsigned long sz = blockList.size;
        MAXLog(@"%ld", sz);
        ListOfLongLong* list = [[ListOfLongLong alloc] init];
        for (int i=0; i<sz; i++) {
            BMXGroupMember* amember = [blockList get:i];
            long long val = amember.getMUid;
            [list addWithX: &val];
        }

        [self getRostersByidArray:list];
    }];
}

// 获取群成员详情
- (void)getRostersByidArray:(ListOfLongLong *)idList {
    [MAXUtils getRostersByidArray:idList completion:^(NSArray *arr) {
        self.blackList = arr;
        [self.tableView reloadData];
    }];
}


@end
