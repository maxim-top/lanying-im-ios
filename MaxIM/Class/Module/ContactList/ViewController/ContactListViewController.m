//
//  ContactListViewController.m
//  MaxIM
//
//  Created by hyt on 2018/11/17.
//  Copyright © 2018年 hyt. All rights reserved.
//

#import "ContactListViewController.h"
#import "RosterSearchViewController.h"
#import "RosterDetailViewController.h"
#import "ImageTitleBasicTableViewCell.h"
#import "LHChatVC.h"
#import "GroupListViewController.h"
#import "UIViewController+CustomNavigationBar.h"
#import <floo-ios/floo_proxy.h>

#import "GroupListTableViewAdapter.h"
#import "GroupCreateViewController.h"
#import "GroupApplyViewController.h"
#import "GroupInviteViewController.h"
#import "SupportStaffApi.h"
#import "MenuView.h"
#import "UIControl+Category.h"
#import "ScanViewController.h"
#import "GroupCreateViewController.h"
#import "MenuViewManager.h"
#import "MaxEmptyTipView.h"
#import "AppIDManager.h"
#import "SupportsStorage.h"

@interface ContactListViewController ()<UITableViewDelegate,
                                        UITableViewDataSource,
                                        BMXRosterServiceProtocol,
                                        MenuViewDeleagte>

@property (nonatomic, strong) UITableView *rosterListTableView;
@property (nonatomic, strong) UITableView *groupListTableView;
@property (nonatomic, strong) UITableView *supportListTableView;

@property (nonatomic, strong) NSArray<BMXGroup *> *groupArray;
@property (nonatomic, strong) NSArray *groupTableviewCellArray;

@property (nonatomic, strong) NSArray *rosterArray;
@property (nonatomic, strong) NSArray *rosterIdArray;
@property (nonatomic, strong) NSArray *actionArray;
@property (nonatomic, strong) NSArray *keyArray;

@property (nonatomic,assign) NSInteger tag;
@property (nonatomic, strong) UIView *selectView;
@property (nonatomic, strong) UIView *navSepLine;

@property (nonatomic, strong) NSArray *supportArray;
@property (nonatomic, strong) MenuViewManager *menuViewManager;

@property (nonatomic, strong) MaxEmptyTipView *tipView;

@end

@implementation ContactListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpNavItem];
    [self selectView];
    [self rosterListTableView];
    [self actionArray];
    [self.rosterListTableView reloadData];
    
    
    [self configSupportData];
    
    [[[BMXClient sharedClient] rosterService] addRosterListener:self];
    
    [self setNotifications];

}

- (void)hideMenu {
    [self.menuViewManager hide];
}

- (void)configSupportData {
    if ([self isShowSupportData]) {
        [self getSupportData];
    } else {
        
    }
}

- (BOOL)isShowSupportData {
    if ([[[[BMXClient sharedClient] getSDKConfig] getAppID] isEqualToString:BMXAppID]) {
        return YES;
    }
    return NO;
}

- (void)getSupportListProfileWithArray:(NSArray *)arr{
    ListOfLongLong * idList = [[ListOfLongLong alloc] init];
    for (NSDictionary *dic in arr) {
        NSString *str = [NSString stringWithFormat:@"%@", dic[@"user_id"]];
        long long rosterId = [str longLongValue];
        [idList addWithX: &rosterId];
    }
    [self getSupportListProfileWithList: idList];
}

- (void)getSupportData {
    SupportStaffApi *api  = [[SupportStaffApi alloc] init];
    [api startWithSuccessBlock:^(ApiResult * _Nullable result) {
        if (result.isOK) {
            [SupportsStorage saveObject:result.resultData];
            NSArray *arr = result.resultData;
            [self getSupportListProfileWithArray:arr];
        } else {
            MAXLog(@"getSupportData failed.");
        }
    } failureBlock:^(NSError * _Nullable error) {
        NSArray *arr = [SupportsStorage loadObject];
        [self getSupportListProfileWithArray:arr];
        [HQCustomToast showNetworkError];
    }];
}

- (void)getSupportListProfileWithList:(ListOfLongLong *)idList {
    [[[BMXClient sharedClient] rosterService] searchWithRosterIdList:idList forceRefresh:NO completion:^(BMXRosterItemList *list, BMXError *error) {
        if (!error) {
            NSMutableArray *arr = [[NSMutableArray alloc] init];
            unsigned long sz = list.size;
            MAXLog(@"%lu", sz);
            for (int i=0; i<sz; i++) {
                [arr addObject:[list get:i]];
            }
            self.supportArray = [NSArray arrayWithArray:arr];
        }
    }];
}

- (void)contactRefreshIfNeededToast:(BOOL)isNeed {
    [self getAllRosterWithToast:isNeed];
}

// 获取好友列表
- (void)getAllRosterWithToast:(BOOL)isNeed {
    if (isNeed == YES) {
        [HQCustomToast showWating];
    }
    [[[BMXClient sharedClient] rosterService] get:NO completion:^(ListOfLongLong *list, BMXError *error) {
        if (!error) {
            MAXLog(@"%ld", list.size);
            [self searchRostersByidArray:list forceRefresh:NO];
        }
    }];
}

#pragma mark - Manager
// 同意好友申请
- (void)acceptApplication:(NSInteger)rosterId {
    [[[BMXClient sharedClient] rosterService] acceptWithRosterId:rosterId completion:^(BMXError *error) {
        MAXLog(@"%@", [error description]);
    }];
}

// 获取好友列表
- (void)getAllRoster:(BOOL)forceRefresh {
    [HQCustomToast showWating];
    [[[BMXClient sharedClient] rosterService] get:forceRefresh completion:^(ListOfLongLong *list, BMXError *error) {
        if (!error) {
            MAXLog(@"%ld", list.size);
            [self searchRostersByidArray:list forceRefresh: forceRefresh];
        }else{
            [HQCustomToast hideWating];
        }
    }];
}

// 批量搜索用户
- (void)searchRostersByidArray:(ListOfLongLong *)idList forceRefresh:(BOOL)forceRefresh {
    [[[BMXClient sharedClient] rosterService] searchWithRosterIdList:idList forceRefresh:forceRefresh completion:^(BMXRosterItemList *list, BMXError *error) {
        [HQCustomToast hideWating];
        if (!error) {
            NSMutableArray *arr = [[NSMutableArray alloc] init];
            unsigned long sz = list.size;
            MAXLog(@"%lu", sz);
            for (int i=0; i<sz; i++) {
                BMXRosterItem *item = [list get:i];
                if(item.relation == BMXRosterItem_RosterRelation_Friend){
                    [arr addObject:item];
                }
            }
            
            self.rosterArray = [NSArray arrayWithArray:arr];
            [self.rosterListTableView reloadData];
        }
    }];
}

// 删除好友
-  (void)removeRoster:(NSInteger)rosterId {
    MAXLog(@"删除好友");
    [[[BMXClient sharedClient] rosterService] removeWithRosterId:rosterId completion:^(BMXError *error) {
        [self getAllRoster: YES];
    }];
}

// 拒绝加好友申请
- (void)declineRosterById:(NSInteger)roster reason:(NSString *)reason {
    [[[BMXClient sharedClient] rosterService] declineWithRosterId:roster reason:reason completion:^(BMXError *error) {
        
    }];
}

#pragma mark - listener
// 用户B同意用户A的加好友请求后，用户A会收到这个回调
- (void)friendAddedByUser:(long long)userId {
     MAXLog(@"对方%lld同意好友的请求", userId);
}

// 用户B申请加A为好友后，用户A会收到这个回调
- (void)friendDidRecivedAppliedFromUser:(long long)userId message:(NSString *)message {
    MAXLog(@"收到%lld添加好友的请求", userId);
}

// 用户B拒绝用户A的加好友请求后，用户A会收到这个回调
- (void)friendDidApplicationDeclinedFromUser:(long long)userId reson:(NSString *)reason {
    
}

//  用户B删除与用户A的好友关系后，用户A会收到这个回调
- (void)friendRemovedByUser:(long long)userId {
    
}

//  用户B同意用户A的加好友请求后，用户A会收到这个回调
- (void)friendDidApplicationAcceptedFromUser:(long long)userId {
    
}

- (void)addFriend {
    RosterSearchViewController *vc = [[RosterSearchViewController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [vc setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)jumpToScanVC {
    ScanViewController *vc = [[ScanViewController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated: YES];
}

- (void)jumpToCreateGroup {
    GroupCreateViewController* ctrl = [[GroupCreateViewController alloc] init];
    ctrl.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:ctrl animated:YES];
}

- (void)addToBlackList:(NSInteger)userId {
    [[[BMXClient sharedClient] rosterService] blockWithRosterId:userId
                                              completion:^(BMXError *error) {
                                                  if (!error) {
                                                      MAXLog(@"添加成功");
                                                      [self getAllRoster: YES];
                                                  } else {
                                                      [HQCustomToast showDialog:[NSString stringWithFormat:@"%@", [error description]] time:2];
                                                  }
                                              }];
}

- (void)clickAddButton:(UIButton *)button {
    [self.menuViewManager show];
    self.menuViewManager.view.delegate = self;
}

#pragma mark - delegate

- (void)menuViewDidSelectbutton:(UIButton *)button {
    if ([button.orderTags isEqualToString:NSLocalizedString(@"Add_friend", @"添加好友")]) {
        [self addFriend];
    } else if ([button.orderTags isEqualToString:NSLocalizedString(@"Create_group", @"创建群组")]) {
        [self jumpToCreateGroup];
    } else {
        [self jumpToScanVC];
    }
}

#pragma mark - TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.tag == 0 || self.tag == 1) {
        return 2;
    } else {
        return 1;
    }
    
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.tag == 0) {
        if (section == 0) {
            return self.actionArray.count;
        } else {
            return self.rosterArray.count ? self.rosterArray.count : 0;
        }
    } else if (self.tag == 1){
        if (section == 0) {
            return self.groupTableviewCellArray.count;
        } else {
            return self.groupArray.count ? self.groupArray.count : 0;
        }
    } else {
        return self.supportArray.count ? self.supportArray.count : 0;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 63.f;
    } else {
        return 60.f;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     ImageTitleBasicTableViewCell *cell = [ImageTitleBasicTableViewCell ImageTitleBasicTableViewCellWith:tableView];
    if (self.tag == 0) { // 好友列表
        if (indexPath.section == 0) {
            NSString *titleStr = [NSString stringWithFormat:@"%@", self.actionArray[indexPath.row]];
            [cell refreshByTitle:titleStr];
        } else {
            BMXRosterItem *roster = self.rosterArray[indexPath.row];
            [cell refresh:roster];
        }
    } else if (self.tag == 1) { // 群组列表
        if (indexPath.section == 0) {
            NSString *titleStr = [NSString stringWithFormat:@"%@", self.groupTableviewCellArray[indexPath.row]];
            [cell refreshByTitle:titleStr];
            if ([titleStr isEqualToString:NSLocalizedString(@"Group_application_list", @"群申请列表")] || [titleStr isEqualToString: NSLocalizedString(@"System_message_of_group_chat", @"群聊系统消息")]) {
                cell.avatarImg.image = [UIImage imageNamed: [NSString stringWithFormat:@"group_application"]];
            }
        } else {
            if (indexPath.row < self.groupArray.count) {
                BMXGroup *group = self.groupArray[indexPath.row];
                [cell refreshByGroup:group];
            }
        }
    } else {
        BMXRosterItem *roster = self.supportArray[indexPath.row];
        [cell refreshSupportRoster:roster];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (self.tag == 0) {
        if (indexPath.section == 0) {
            NSString *string = self.actionArray[indexPath.row];
            if ([string isEqualToString:NSLocalizedString(@"Friend_request_and_notification", @"好友申请与通知")]) {
                RosterDetailViewController *vc = [[RosterDetailViewController alloc] init];
                vc.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:vc animated:YES];
            }
        } else {
            BMXRosterItem *roster = self.rosterArray[indexPath.row];
            LHChatVC *vc = [[LHChatVC alloc] initWithRoster:roster messageType:BMXMessage_MessageType_Single];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }
    } else if (self.tag == 1) {
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
//                GroupCreateViewController* ctrl = [[GroupCreateViewController alloc] init];
//                ctrl.hidesBottomBarWhenPushed = YES;
//
//                [ctrl hidesBottomBarWhenPushed];
//                [self.navigationController pushViewController:ctrl animated:YES];
//            } else if(indexPath.row == 1) {
//                GroupApplyViewController *vc = [[GroupApplyViewController alloc] init];
//                vc.hidesBottomBarWhenPushed = YES;
//                [self.navigationController pushViewController:vc animated:YES];
//
//            } else {
                GroupInviteViewController *VC = [[GroupInviteViewController alloc] init];
                VC.hidesBottomBarWhenPushed = YES;

                [self.navigationController pushViewController:VC animated:YES];
            }
            
        } else {
            BMXGroup *group = self.groupArray[indexPath.row];
            
            LHChatVC *vc = [[LHChatVC alloc] initWithGroupChat:group messageType:BMXMessage_MessageType_Group];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }
    } else {
        BMXRosterItem *roster = self.supportArray[indexPath.row];
        LHChatVC *vc = [[LHChatVC alloc] initWithRoster:roster messageType:BMXMessage_MessageType_Single];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 || self.tag != 0) {
        return NO;
    }
    return YES;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 添加一个删除按钮
    UITableViewRowAction *deleteRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:NSLocalizedString(@"Delete", @"删除")handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        MAXLog(@"点击了删除");
        BMXRosterItem *roster = self.rosterArray[indexPath.row];
        [self removeRoster:roster.rosterId];
        MAXLog(@"删除动作");
        
       
    }];
    // 删除一个置顶按钮
    UITableViewRowAction *topRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:NSLocalizedString(@"Add_to_blacklist", @"加入黑名单")handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        MAXLog(@"点击了点入黑名单");
        BMXRosterItem *roster = self.rosterArray[indexPath.row];

        [self addToBlackList:roster.rosterId];
    }];
    topRowAction.backgroundColor = [UIColor blueColor];
    
    return @[deleteRowAction, topRowAction];
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return NSLocalizedString(@"Delete", @"删除");
}

-(void)indexDidChangeForSegmentedControl:(UISegmentedControl *)sender {
    
    [self.tipView removeFromSuperview];
    
    [self.menuViewManager hide];
    NSInteger selecIndex = sender.selectedSegmentIndex;
    switch(selecIndex){
        case 0:
        {
            sender.selectedSegmentIndex=0;
            self.tag = 0;
            
            [self.groupListTableView setHidden:YES];
            [self.rosterListTableView setHidden:NO];
            [self.supportListTableView setHidden:YES];

            [self selectViewAnimationWithTag:self.tag];
            [self getAllRoster: YES];

            break;
        }
            
        case 1:
        {
            sender.selectedSegmentIndex = 1;
            self.tag = 1;

            [self.groupListTableView setHidden:NO];
            [self.rosterListTableView setHidden:YES];
            [self.supportListTableView setHidden:YES];

            
            [self getGroupTableViewDatasource];
            
            [self selectViewAnimationWithTag:self.tag];
            break;
        }
        case 2: {
            sender.selectedSegmentIndex = 2;
            self.tag = 2;
            [self.groupListTableView setHidden:YES];
            [self.rosterListTableView setHidden:YES];
            [self.supportListTableView setHidden:NO];
            
            [self selectViewAnimationWithTag:self.tag];
            
            
            [self getSupportData];
            [self.supportListTableView reloadData];

            
            if (![self isShowSupportData]) {
                [self.view insertSubview:self.tipView aboveSubview:self.supportListTableView];
            } else {
                [self.tipView removeFromSuperview];
            }
            
            break;
            
        }
        default:
            break;
    }
}

- (void)getGroupTableViewDatasource {
    self.groupTableviewCellArray = [GroupListTableViewAdapter tableViewCellArray];
    
    [HQCustomToast showWating];
    [GroupListTableViewAdapter getGroupListcompletion:^(NSArray<BMXGroup *> * _Nonnull group, NSString * _Nonnull errmsg) {
        [HQCustomToast hideWating];
        if (![errmsg length]) {
            self.groupArray = group;
        } else {
            [HQCustomToast showDialog:errmsg];
        }
        [self.groupListTableView reloadData];
    }];
}

- (void)selectViewAnimationWithTag:(NSInteger)tag {
    if (tag == 0) {
        [UIView animateWithDuration:0.2 animations:^{
            self.selectView.x = 17;
        }];
    } else if(tag == 1) {
        [UIView animateWithDuration:0.2 animations:^{
            self.selectView.x = 17 + 82 ;
        }];
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            self.selectView.x = 17 + 158;
        }];
    }
}

- (NSArray *)actionArray {
    return @[NSLocalizedString(@"Friend_request_and_notification", @"好友申请与通知")];
}

- (UITableView *)rosterListTableView {
    if (!_rosterListTableView) {
        _rosterListTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NavHeight, MAXScreenW, MAXScreenH
                                                                    - NavHeight- 64) style:UITableViewStylePlain];
        _rosterListTableView.bounces = NO;
        _rosterListTableView.delegate = self;
        _rosterListTableView.dataSource = self;
        _rosterListTableView.separatorStyle = UITableViewCellSeparatorStyleNone;

        UIView *view =  [[UIView alloc] init];
        _rosterListTableView.tableHeaderView = view;
        view.backgroundColor  = BMXCOLOR_HEX(0xf8f8f8);
        _rosterListTableView.tableHeaderView.height = 10;
        [_rosterListTableView registerClass:[ImageTitleBasicTableViewCell class] forCellReuseIdentifier:@"ImageTitleBasicTableViewCell"];
        [self.view addSubview:_rosterListTableView];
    }
    return _rosterListTableView;
}

- (UITableView *)groupListTableView {
    if (!_groupListTableView) {
        _groupListTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NavHeight, MAXScreenW, MAXScreenH
                                                                             - NavHeight- 64) style:UITableViewStylePlain];
        _groupListTableView.bounces = NO;
        _groupListTableView.delegate = self;
        _groupListTableView.dataSource = self;
        
        _groupListTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        UIView *view =  [[UIView alloc] init];
        _groupListTableView.tableHeaderView = view;
        view.backgroundColor  = BMXCOLOR_HEX(0xf8f8f8);
        _groupListTableView.tableHeaderView.height = 10;
        
        [_groupListTableView registerClass:[ImageTitleBasicTableViewCell class] forCellReuseIdentifier:@"ImageTitleBasicTableViewCell"];
        [self.view addSubview:_groupListTableView];
    }
    return _groupListTableView;
}

- (UITableView *)supportListTableView {
    if (!_supportListTableView) {
        _supportListTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NavHeight, MAXScreenW, MAXScreenH
                                                                            - NavHeight- 64) style:UITableViewStylePlain];
        _supportListTableView.bounces = NO;
        _supportListTableView.delegate = self;
        _supportListTableView.dataSource = self;
        _supportListTableView.separatorStyle = UITableViewCellSeparatorStyleNone;

        UIView *view =  [[UIView alloc] init];
        _supportListTableView.tableHeaderView = view;
        view.backgroundColor  = BMXCOLOR_HEX(0xf8f8f8);
        _supportListTableView.tableHeaderView.height = 10;
        
        [_supportListTableView registerClass:[ImageTitleBasicTableViewCell class] forCellReuseIdentifier:@"ImageTitleBasicTableViewCell"];
        [self.view addSubview:_supportListTableView];
    }
    return _supportListTableView;
    
}

- (UIView *)selectView {
    if (!_selectView) {
        _selectView = [[UIView alloc] init];
        _selectView.frame = CGRectMake(5, NavHeight - 2 , 70, 2);
        _selectView.backgroundColor = BMXCOLOR_HEX(0x009FE8);
        _selectView.layer.cornerRadius = 2;
        _selectView.layer.masksToBounds = YES;
        [self.view addSubview:_selectView];
    }
    return _selectView;
}

- (NSArray *)rosterArray {
    if (!_rosterArray) {
        _rosterArray = [NSArray array];
    }
    return _rosterArray;
}

- (NSArray *)supportArray {
    if (!_supportArray) {
        _supportArray = [NSArray array];
    }
    return _supportArray;
}

- (NSArray *)groupTableviewCellArray {
    if (!_groupTableviewCellArray) {
        _groupTableviewCellArray = [NSArray array];
    }
    return _groupTableviewCellArray;
}

- (NSArray<BMXGroup *> *)groupArray {
    if (!_groupArray) {
        _groupArray = [NSArray array];
    }
    return _groupArray;
}

+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)setUpNavItem{
    UIView *navigationBar = [[UIView alloc]  initWithFrame:CGRectMake(0, 0, MAXScreenW, NavHeight)];
    [self.view addSubview:navigationBar];
    self.navigationBar = navigationBar;
    
    NSArray * items = [NSArray arrayWithObjects:NSLocalizedString(@"Friend", @"好友"), NSLocalizedString(@"Group", @"群组"), NSLocalizedString(@"Support", @"支持"), nil];
    UISegmentedControl *control = [[UISegmentedControl alloc] initWithItems: items];
    for (int i=0; i< items.count-1; i++){
        [control setWidth:80.0 forSegmentAtIndex:i];
    }
    [control setWidth:90.0 forSegmentAtIndex:items.count-1];

//                                   initWithFrame:CGRectMake(16, 10, 32 * 3, 30)];
//    
    [control setBackgroundImage:[self imageWithColor:[UIColor clearColor]] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [control setBackgroundImage:[self imageWithColor:[UIColor clearColor]] forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    
    UIImage *_dividerImage= [self imageWithColor:[UIColor clearColor]];
            [control setDividerImage:_dividerImage forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
  
  
    control.frame = CGRectMake(5, MAXIsFullScreen ? 28 + 26 :  28 ,( 260/3.0 )*3.0, 25);
    control.tintColor = [UIColor whiteColor];
    
    [control setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"PingFangSC-Medium" size:T5_30PX], NSForegroundColorAttributeName:[UIColor blackColor]} forState:UIControlStateNormal];
    [control setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"PingFangSC-Medium" size:T5_30PX], NSForegroundColorAttributeName:[UIColor blackColor]} forState:UIControlStateSelected];
    control.layer.borderColor = [UIColor whiteColor].CGColor;
    control.selectedSegmentIndex = 0;
    [control addTarget:self action:@selector(indexDidChangeForSegmentedControl:) forControlEvents:UIControlEventValueChanged];
    [navigationBar addSubview:control];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(clickAddButton:) forControlEvents:UIControlEventTouchUpInside];
    [button setImage:[UIImage imageNamed:@"common_add"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"common_add"] forState:UIControlStateHighlighted];

    button.frame = CGRectMake(MAXScreenW - 10 - 30, MAXIsFullScreen ? 28 + 26 :  28 , 30,25);
    [navigationBar addSubview:button];
    
    CGRect frame = CGRectMake(0, self.navigationBar.height - 0.5, self.navigationBar.width, 0.25);
    UIImageView *bottomSepImageView = [[UIImageView alloc] initWithFrame:frame];
    [navigationBar addSubview:bottomSepImageView];
    bottomSepImageView.backgroundColor = kColorC4_5;
    bottomSepImageView.clipsToBounds = NO;
    bottomSepImageView.layer.shadowOffset = CGSizeMake(0,-0.5);
    bottomSepImageView.layer.shadowRadius = 5;
    bottomSepImageView.layer.shadowOpacity = 0.5;
}

- (MenuViewManager *)menuViewManager {
    if (!_menuViewManager) {
        _menuViewManager = [MenuViewManager sharedMenuViewManager];

    }
    return _menuViewManager;
}

- (MaxEmptyTipView *)tipView {
    if (!_tipView) {
        
        CGFloat navh = kNavBarHeight;
        if (MAXIsFullScreen) {
            navh  = kNavBarHeight + 24;
        }
        _tipView = [[MaxEmptyTipView alloc] initWithFrame:CGRectMake(0, navh + 1 , MAXScreenW, MAXScreenH - navh - 37) type:MaxEmptyTipTypeContactSupport];
    }
    return _tipView;
}


#pragma mark == delegate of create group
- (void) setNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onGrouplistChange) name:@"KGroupListModified" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getAllRoster:) name:@"RefreshContactList" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideMenu) name:@"HideMenu" object:nil];
}

- (void)onGrouplistChange {
    
    if (self.tag == 1) {
        MAXLog(@"1");
         [self getGroupTableViewDatasource];
    }
}

@end
