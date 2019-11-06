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
#import "BMXClient.h"
#import "BMXGroupMember.h"
#import "BMXRoster.h"
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
    BMXRoster* roster = [self.blackList objectAtIndex:indexPath.row];
    NSString* uname = (roster.nickName && ![@"" isEqualToString:roster.nickName]) ? roster.nickName : roster.userName;
    NSString* rosterIdStr = [NSString stringWithFormat:@"%lld", roster.rosterId];
    BOOL isSel = [[_selectedIdDictionary objectForKey:rosterIdStr] boolValue] ;
    [cell setAvatarStr:roster.avatarUrl RosterName:uname Selected:isSel];
    [cell setDlownAvatar:roster Selected:isSel];
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BMXRoster* roster = [self.blackList objectAtIndex:indexPath.row];
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
    NSMutableArray* xids = [NSMutableArray array];
    for (NSString* uid in _selectedIdDictionary) {
        BOOL issel = [[_selectedIdDictionary objectForKey:uid] boolValue];
        if (issel) {
            [xids addObject:uid];
        }
    }
    if (xids.count <=0) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"警告" message:@"您没有选中成员" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }else {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"警告" message:@"确定要解除黑名单吗？" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self removeBlackList:xids];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}


-(void) removeBlackList: (NSArray*) uids
{
    [[[BMXClient sharedClient] groupService] unblockMember:self.group members:uids completion:^(BMXError *error) {
        if(!error) {
            [self getBlackList];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"KEY_NOTIFICATION_GROUP_MEMBER_UPDATED" object:nil];
            // TODO 优化， 直接从列表中删除
        }else {
            MAXLog(@"request error, code: %d", error.errorCode);
        }
    }];
}

- (void)setUpNavItem {
    [self setNavigationBarTitle: @"群黑名单" navLeftButtonIcon:@"blackback" navRightButtonTitle:@"解除"];
    [self.navRightButton addTarget:self action:@selector(touchedRightBar) forControlEvents:UIControlEventTouchUpInside];
}


- (void)getBlackList {
    [[[BMXClient sharedClient] groupService] getBlockListByGroup:self.group forceRefresh:YES completion:^(NSArray<BMXGroupMember *> *blockList, BMXError *error) {
        MAXLog(@"%ld", blockList.count);
        NSMutableArray* array = [NSMutableArray array];
        for (BMXGroupMember* amember in blockList) {
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
        self.blackList = [NSArray arrayWithArray: rosterList];
        [self.tableView reloadData];
    }];
}


@end
