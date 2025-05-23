
//
//  MAXTabBarController.m
//  MaxIMDemo
//
//  Created by hyt on 2018/11/8.
//  Copyright © 2018年 hyt. All rights reserved.
//

#import "MAXTabBarController.h"
#import "AppDelegate.h"

#import <floo-ios/floo_proxy.h>

#define TabVC    @"vc"
#define TabTitle @"title"
#define TabImage @"image"
#define TabSelectedImage @""
#define TabBarCount 3

#import "IMAcount.h"
#import "IMAcountInfoStorage.h"
#import "MainViewController.h"

#import "SettingViewController.h"
#import "ContactListViewController.h"
#import "AppIDManager.h"


typedef enum : NSUInteger {
    MAXRecentContactType,
    MAXContactListType,
    MAXSettingType,
} MAXTabBarType;


@interface MAXTabBarController ()<BMXChatServiceProtocol, BMXRTCServiceProtocol, BMXRosterServiceProtocol, BMXUserServiceProtocol, BMXGroupServiceProtocol>

@property (nonatomic, strong) UITabBarItem *item;
@property (nonatomic, strong) NSDictionary *tabbarInfoDic;

@property (nonatomic,assign) BOOL isLoadedProfileSetting;
@property (nonatomic,assign) BOOL isLoadedContact;

@property (nonatomic, strong) UIView *line;

//@property (nonatomic, strong) NSArray *tabbarArray;

@end

@implementation MAXTabBarController

+ (instancetype)instance {
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIViewController *vc = appDelegate.window.rootViewController;
    if ([vc isKindOfClass:[MAXTabBarController class]]) {
        return (MAXTabBarController *)vc;
    }else{
        return nil;
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self configtabBarItem];
    
    [NetWorkingManager netWorkingManagerWithNetworkStatusListening];
    [self p_addObserver];

}

- (void)p_addObserver {
    NSNotificationCenter *notifCenter = [NSNotificationCenter defaultCenter];
    [notifCenter addObserver:self
                    selector:@selector(p_networkStatusDidChanged:)
                        name:connectingIPhoneNetworkNotifation object:nil];
    
    [notifCenter addObserver:self
                    selector:@selector(p_networkStatusDidChanged:)
                        name:connectingInWifiNetworkNotifation
                      object:nil];
    
    [notifCenter addObserver:self
                    selector:@selector(p_networkStatusDidChanged:)
                        name:disConnectionNetworkNotifation
                      object:nil];
}

- (void)p_networkStatusDidChanged:(NSNotification *)notifiaction {
    if ([notifiaction.name isEqualToString:@"disConnectionNetworkNotifation"]) {
        [[BMXClient sharedClient] onNetworkChangedWithType: BMXNetworkType_None reconnect:NO];
        MAXLog(@"无网络");
    }
}


- (void)addIMListener {
    BMXClient *client = [BMXClient sharedClient];
    [[client rosterService] addDelegate:self];
    [[client chatService] addDelegate:self];
    [[client rtcService] addDelegate:self];
    [[client userService] addDelegate:self];
    [[client groupService] addDelegate:self];
}

- (void)removeIMListener {
    BMXClient *client = [BMXClient sharedClient];
    [[client rosterService] removeDelegate:self];
    [[client chatService] removeDelegate:self];
    [[client userService] removeDelegate:self];
    [[client groupService] removeDelegate:self];
}

#pragma mark - grouplistener

/**
 * 多设备同步创建群组
 **/
- (void)groupDidCreated:(BMXGroup *)group {
    MAXLog(@"多设备同步创建群组");

}

- (void)groupInfoDidUpdate:(BMXGroup *)group
            updateInfoType:(BMXGroup_UpdateInfoType)type{

    MAXLog(@"群信息更新了");
}

/**
 * 加入新成员
 **/
- (void)groupMemberJoined:(BMXGroup *)group
                 memberId:(NSInteger)memberId
                  inviter:(NSInteger)inviter{
    MAXLog(@"群：%@有成员加入:%ld", group.name, (long)memberId);
    [HQCustomToast showToastWithInfo:[NSString stringWithFormat:NSLocalizedString(@"Group_member_joined", @"群：%@有成员加入:%ld"), group.name, (long)memberId]];
}

/**
 * 群成员退出
 **/
- (void)groupMemberLeft:(BMXGroup *)group
               memberId:(NSInteger)memberId
                 reason:(NSString *)reason{
    MAXLog(@"群：%@有成员退出:%ld", group.name, (long)memberId);
    [HQCustomToast showToastWithInfo:[NSString stringWithFormat:NSLocalizedString(@"Group_member_quited", @"群：%@有成员退出:%ld"), group.name, (long)memberId]];
}

/**
 * 群列表更新了
 */
- (void)groupListDidUpdate:(NSArray <BMXGroup *>*)groupList {
    MAXLog(@"群列表更新了");

}

- (void)groupOwnerAssigned:(BMXGroup *)group {
    MAXLog(@"群主是我了");

}

/**
 加入了某群
 
 @param group 群
 */
- (void)groupJoined:(BMXGroup *)group {
    MAXLog(@" 加入了某群");

}

/**
 退出了某群
 */
- (void)groupLeft:(BMXGroup *)group reason:(NSString *)reason {
    MAXLog(@"您退出了群：%@，原因:%@", group.name, reason);
    [HQCustomToast showToastWithInfo:[NSString stringWithFormat:NSLocalizedString(@"You_have_quit_the_group", @"您退出了群：%@，原因:%@"), group.name, reason]];
}

/**
 * 收到入群邀请
 **/
- (void)groupDidRecieveInviter:(NSInteger)inviter groupId:(NSInteger)groupId message:(NSString *)message {
    MAXLog(@"收到入群邀请");
}

/**
 * 入群邀请被接受
 **/
- (void)groupInvitationAccepted:(BMXGroup *)group inviteeId:(NSInteger)inviteeId {
    MAXLog(@"入群邀请被接受");

}

/**
 * 入群申请被拒绝
 **/
- (void)groupInvitationDeclined:(BMXGroup *)group
                      inviteeId:(NSInteger)inviteeId
                         reason:(NSString *)reason {
    MAXLog(@"入群申请被拒绝");

    
}
/**
 * 收到入群申请
 **/
- (void)groupDidRecieveApplied:(BMXGroup *)group
                   applicantId:(NSInteger)applicantId
                       message:(NSString *)message {
    
     MAXLog(@"收到入群申请");
}

/**
 * 入群申请被接受
 **/
- (void)groupApplicationAccepted:(BMXGroup *)group
                        approver:(NSInteger)approver {
    MAXLog(@"入群申请被接受");

}

/**
 * 入群申请被拒绝
 **/
- (void)groupApplicationDeclined:(BMXGroup *)group
                        approver:(NSInteger)approver
                          reason:(NSString *)reason {
    MAXLog(@"入群申请被拒绝");
}
#pragma mark - BMXRTCServiceProtocol
- (void)onRTCCallMessageReceiveWithMsg:(BMXMessage*)msg {
    UINavigationController *navigation = (UINavigationController *)[self.childViewControllers firstObject];
    if ([NSStringFromClass([navigation.childViewControllers firstObject].class) isEqualToString:@"MainViewController"] ) {
        MainViewController *mainVC = [navigation.childViewControllers firstObject];
        [mainVC receiveRTCCallMessage:msg];
    }
}

#pragma mark - BMXChatServiceProtocol
/**
 * 收到系统通知消息
 **/
- (void)receivedSystemMessages:(NSArray<BMXMessage*> *)messages {
    MAXLog(@"收到系统通知消息");
}

- (void)receiveReadAllMessages:(NSArray<BMXMessage *> *)messages {
    UINavigationController *navigation = (UINavigationController *)[self.childViewControllers firstObject];
    if ([NSStringFromClass([navigation.childViewControllers firstObject].class) isEqualToString:@"MainViewController"] ) {
        MainViewController *mainVC = [navigation.childViewControllers firstObject];
        [mainVC receiveNewMessage:[messages lastObject]];
    }
    MAXLog(@"已经readall");

}

- (void)receivedRecallMessages:(NSArray<BMXMessage *> *)messages {
    UINavigationController *navigation = (UINavigationController *)[self.childViewControllers firstObject];
    if ([NSStringFromClass([navigation.childViewControllers firstObject].class) isEqualToString:@"MainViewController"] ) {
        
        MainViewController *mainVC = [navigation.childViewControllers firstObject];
        [mainVC receiveNewMessage:[messages lastObject]];
    }
    MAXLog(@"已经收到消息 %@", [messages firstObject]);
}

/**
 * 用户在其他设备上登出
 **/
- (void)userOtherDeviceDidSignOut:(NSInteger)deviceSN {
    MAXLog(@"用户");
}

/**
 * 用户在其他设备上登陆
 **/
- (void)userOtherDeviceDidSignIn:(NSInteger)deviceSN {
    MAXLog(@"用户在其他设备上登陆");

}


- (void)userSignOut:(BMXError *)error userId:(long long)userId {
    MAXLog(@"用户登出");
    if (!error || [error errorCode] == BMXErrorCode_UserAuthFailed){
        [AppIDManager clearAppid];
        AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        [appDelegate reloadAppID:BMXAppID];
        [IMAcountInfoStorage clearObject];
        [appDelegate userLogout];
    }
}


- (void)userInfoDidUpdated:(BMXUserProfile *)userProflie {
    MAXLog(@"用户信息改变");
    [[[BMXClient sharedClient] userService] downloadAvatarWithProfile:userProflie thumbnail:YES callback:^(int progress) {} completion:^(BMXError *error) {
        if (!error){
            MAXLog(@"下载成功");
        }
    }];
}

- (void)rosterInfoDidUpdate:(BMXRosterItem *)roster {
    MAXLog(@"好友信息变更");
    [[[BMXClient sharedClient] rosterService] downloadAvatarWithItem:roster thumbnail:YES callback:^(int progress) {} completion:^(BMXError *error) {
        if (!error){
            MAXLog(@"下载成功");
            // 会话页面刷新UI
            UINavigationController *navigation = (UINavigationController *)[self.childViewControllers firstObject];
            if ([NSStringFromClass([navigation.childViewControllers firstObject].class) isEqualToString:@"MainViewController"] ) {
                MainViewController *mainVC = [navigation.childViewControllers firstObject];
                [mainVC updateConversationWithRosterItem:roster];
            }
        }
    }];
}
/**
 * 收到消息已送达回执
 **/
- (void)receivedDeliverAcks:(NSArray<BMXMessage*> *)messages {
    MAXLog(@"收到消息已送达回执");
}

- (void)receivedReadAcks:(NSArray<BMXMessage *> *)messages {
    MAXLog(@"收到消息已读回执");
    UINavigationController *navigation = (UINavigationController *)[self.childViewControllers firstObject];
    if ([NSStringFromClass([navigation.childViewControllers firstObject].class) isEqualToString:@"MainViewController"] ) {
        
        MainViewController *mainVC = [navigation.childViewControllers firstObject];
        [mainVC receiveNewMessage:[messages lastObject]];
    }
}

- (void)retrieveHistoryMessagesConversation:(BMXConversation *)conversation {
    if (conversation.lastMsg.msgId != 0 ) {
        UINavigationController *navigation = (UINavigationController *)[self.childViewControllers firstObject];
        if ([NSStringFromClass([navigation.childViewControllers firstObject].class) isEqualToString:@"MainViewController"] ) {
            
            MainViewController *mainVC = [navigation.childViewControllers firstObject];
            [mainVC receiveNewMessage:conversation.lastMsg];
        }
    }
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    
    UINavigationController *navVC = self.childViewControllers[item.tag];
    UIViewController *vc = navVC.topViewController;
    if ([NSStringFromClass(vc.class) isEqualToString:@"SettingViewController"]) {
        
        if (self.isLoadedProfileSetting == NO) {
            SettingViewController *settingvc = (SettingViewController *)vc;
            [settingvc settingRefreshIfNeededToast:YES];
            self.isLoadedProfileSetting = YES;
        } else {
            SettingViewController *settingvc = (SettingViewController *)vc;
            [settingvc settingRefreshIfNeededToast:NO];
        }
        
        
      
    } else if ([NSStringFromClass(vc.class) isEqualToString:@"ContactListViewController"]) {
        if (self.isLoadedContact == NO) {
            ContactListViewController *contactListvc = (ContactListViewController *)vc;
            [contactListvc contactRefreshIfNeededToast:YES];
            self.isLoadedContact = YES;
        } else {
            ContactListViewController *contactListvc = (ContactListViewController *)vc;
            [contactListvc contactRefreshIfNeededToast:NO];
        }
        
    }
    MAXLog(@"点击tab");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HideMenu" object:nil];
}

- (void)receivedMessages:(NSArray<BMXMessage*> *)messages {
    UINavigationController *navigation = (UINavigationController *)[self.childViewControllers firstObject];
    if ([NSStringFromClass([navigation.childViewControllers firstObject].class) isEqualToString:@"MainViewController"] ) {
        
        MainViewController *mainVC = [navigation.childViewControllers firstObject];
        
        [mainVC receiveNewMessage:[messages lastObject]];
    }
    MAXLog(@"已经收到消息 %@", [messages firstObject]);
}

- (void)receiveDeleteMessages:(NSArray<BMXMessage*> *)messages{
    UINavigationController *navigation = (UINavigationController *)[self.childViewControllers firstObject];
    if ([NSStringFromClass([navigation.childViewControllers firstObject].class) isEqualToString:@"MainViewController"] ) {
        
        MainViewController *mainVC = [navigation.childViewControllers firstObject];
        
        [mainVC receiveNewMessage:[messages lastObject]];
    }
}

- (void)receivedCommandMessages:(NSArray<BMXMessage *> *)messages {
    MAXLog(@"收到命令消息 %@", [messages firstObject]);

}

- (void)messageStatusChanged:(BMXMessage *)message
                       error:(BMXError *)error {

    
    if (!error) {
        UINavigationController *navigation = (UINavigationController *)[self.childViewControllers firstObject];
        if ([NSStringFromClass([navigation.childViewControllers firstObject].class) isEqualToString:@"MainViewController"] ) {
            
            MainViewController *mainVC = [navigation.childViewControllers firstObject];
            [mainVC sendNewMessage:message];
        }
    }
    UINavigationController *navigation = (UINavigationController *)[self.childViewControllers firstObject];
    if ([NSStringFromClass([navigation.childViewControllers firstObject].class) isEqualToString:@"MainViewController"] ) {
        
        MainViewController *mainVC = [navigation.childViewControllers firstObject];
        [mainVC sendNewMessage:message];
    }
     MAXLog(@"消息发送状态发生变化 %u",message.deliveryStatus);
}

- (void)friendDidRecivedAppliedSponsorId:(long long)sponsorId recipientId:(long long)recipientId message:(NSString *)message {
    MAXLog(@"已经收到申请，发起人%lld, 接收人%lld", sponsorId, recipientId);
}

- (void)friendDidApplicationAcceptedFromSponsorId:(long long)sponsorId recipientId:(long long)recipientId {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshContactList" object:nil];
    MAXLog(@"好友已经同意请求  ，发起人%lld, 接收人%lld", sponsorId, recipientId);
}

- (void)friendDidApplicationDeclinedFromSponsorId:(long long)sponsorId recipientId:(long long)recipientId reson:(NSString *)reason {
    MAXLog(@"拒绝");
}

- (void)friendAddedtoBlackListSponsorId:(long long)sponsorId recipientId:(long long)recipientId {
    MAXLog(@"已添加黑名单");
}

- (void)friendRemovedSponsorId:(long long)sponsorId recipientId:(long long)recipientId {
    MAXLog(@"对方删除好友");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshContactList" object:nil];
}

- (void)friendRemovedFromBlackListSponsorId:(long long)sponsorId recipientId:(long long)recipientId {
    MAXLog(@"移除黑名单");
}


- (void)configtabBarItem {
    NSMutableArray *vcArray = [[NSMutableArray alloc] init];
    [self.tabbarArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSLog(@"%@", self.tabbarArray);
        NSDictionary * item =[self vcTabBarType:[obj integerValue]];
        NSString *vcName = item[TabVC];
        NSString *title  = item[TabTitle];
        NSString *imageName = item[TabImage];
        NSString *imageSelected = item[TabSelectedImage];
        Class clazz = NSClassFromString(vcName);
        
        //因为系统默认是将我们选中的图片渲染为蓝色的,所以在这里我们可以将选中的图片设置为初始值, 使其不被渲染就可以;
        UIImage * homeSelectImge = [UIImage imageNamed:imageSelected];
        homeSelectImge = [homeSelectImge imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
        attrs[NSFontAttributeName] = [UIFont systemFontOfSize:10];
        attrs[NSForegroundColorAttributeName] =  [UIColor colorWithRed:155/255.0 green:155/255.0 blue:169/255.0 alpha:1/1.0];
        
        // 选中
        NSMutableDictionary *attrSelected = [NSMutableDictionary dictionary];
        attrSelected[NSFontAttributeName] = [UIFont systemFontOfSize:10];
        attrSelected[NSForegroundColorAttributeName] = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1/1.0];
        
        [[UITabBarItem appearance] setTitleTextAttributes:attrs forState:UIControlStateNormal];
        [[UITabBarItem appearance] setTitleTextAttributes:attrSelected forState:UIControlStateSelected];
        
        
        UIViewController *vc = [[clazz alloc] initWithNibName:nil bundle:nil];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        nav.navigationBar.hidden = YES;
        nav.tabBarItem = [[UITabBarItem alloc] initWithTitle:title
                                                       image:[UIImage imageNamed:imageName]
                                               selectedImage:homeSelectImge];
        nav.tabBarItem.tag = idx;

        [vcArray addObject:nav];
//        [handleArray addObject:handler];
    }];
    self.viewControllers = [NSArray arrayWithArray:vcArray];
    if (@available(iOS 15.0, *)) {
        self.tabBar.scrollEdgeAppearance = self.tabBar.standardAppearance;
    }
//    self.navigationHandlers = [NSArray arrayWithArray:handleArray];
}

- (NSDictionary *)vcTabBarType:(MAXTabBarType)type{
    if (_tabbarInfoDic == nil) {
        _tabbarInfoDic = @{ @(MAXRecentContactType) : @{
                                    TabVC           : @"MainViewController",
                                    TabTitle        : NSLocalizedString(@"Chats", @"对话"),
                                    TabImage        : @"recent",
                                    TabSelectedImage: @"recent_h",
                                    },
                            @(MAXContactListType)   : @{
                                    TabVC           : @"ContactListViewController",
                                    TabTitle        : NSLocalizedString(@"Address_book", @"通讯录"),
                                    TabImage        : @"contact",
                                    TabSelectedImage: @"contact_h",
                                    },
                            
                            @(MAXSettingType)       : @{
                                    TabVC           : @"SettingViewController",
                                    TabTitle        : NSLocalizedString(@"Set", @"设置"),
                                    TabImage        : @"tabsetting_n",
                                    TabSelectedImage: @"tabsetting_s",
                                    }
                            };
    }
    return _tabbarInfoDic[@(type)];
}

- (NSArray*)tabbarArray{
    NSMutableArray *items = [[NSMutableArray alloc] init];
    for (NSInteger tabbar = 0; tabbar < TabBarCount; tabbar++) {
        [items addObject:@(tabbar)];
    }
    return items;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UIView *)line {
    if (!_line) {
        _line = [[UIView alloc] init];
        
    }
    return _line;
}

@end

