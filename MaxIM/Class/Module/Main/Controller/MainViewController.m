//
//  MainVCTableViewController.m
//  LHChatUI
//
//  Created by hyt on 2016/12/22.
//  Copyright © 2016年 hyt. All rights reserved.
//

#import "MainViewController.h"
#import "LHChatVC.h"
#import "NSString+Extention.h"

#import "IMAcountInfoStorage.h"

#import "IMAcount.h"
#import "IMAcountInfoStorage.h"


#import "MAXGlobalTool.h"

#import "RecentConversaionTableViewCell.h"

#import "BMXSearchView.h"
#import "SearchContentViewController.h"
#import "UIView+BMXframe.h"

#import "UIViewController+CustomNavigationBar.h"
#import "ScanViewController.h"
#import "SystemNotificationViewController.h"
#import "MaxEmptyTipView.h"
#import "UIControl+Category.h"
#import <floo-ios/floo_proxy.h>
#import "CallViewController.h"
#import <floo-rtc-ios/RTCEngineManager.h>
#import "LHTools.h"
#import "SchemURIStorage.h"

@interface MainViewController ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, ChatVCDelegate, BMXChatServiceProtocol,BMXRTCServiceProtocol>

@property (nonatomic, strong) NSMutableArray<BMXConversation *> *conversatonList;
@property (nonatomic, strong) NSMutableDictionary *indexOfConversationId;
@property (nonatomic, strong) NSCache *rosters;
@property (nonatomic, strong) UITableView *tableview;
@property (nonatomic, assign) bool isLogin;
@property (nonatomic, assign) long long lastTimestamp;
@property (nonatomic, strong) BMXSearchView *searchView;
@property (nonatomic, strong) UIButton *searchbigButton;
@property (nonatomic, strong) UILabel *headerLabel;
@property (nonatomic, strong) MaxEmptyTipView *tipView;
@property (nonatomic, strong) IMAcount *account;
@property (nonatomic, strong) NSLock *profileLock;
@property (nonatomic, strong) NSMutableSet *hungUpCalls;
@property (nonatomic, strong) NSTimer *timer; //会话列表更新计时器

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _profileLock = [[NSLock alloc] init];
    _hungUpCalls = [[NSMutableSet alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setUpNavItem];
    
    [[[BMXClient sharedClient] chatService] addChatListener:self];
    [[[BMXClient sharedClient] rtcService] addDelegate:self];

    [NetWorkingManager netWorkingManagerWithNetworkStatusListening];
    [self p_addObserver];
    
    [self showUnReadNumber:[[[BMXClient sharedClient] chatService] getAllConversationsUnreadCount]];
    //
    self.account = [IMAcountInfoStorage loadObject];
    NSString *url = [SchemURIStorage loadObject];
    if(url.length > 0){
        AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        NSString *package = @"https://package.maximtop.com/";
        NSString *lanying = @"lanying:";
        NSString *path;
        if ([url hasPrefix:package]) {
            path = [url substringFromIndex:package.length];
        } else if ([url hasPrefix:lanying]) {
            path = [url substringFromIndex:lanying.length];
        }
        [appDelegate processExternalLinkWithPath: path];
        [SchemURIStorage clearObject];
    }
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
        long long now = [[NSDate date] timeIntervalSince1970];
        if (now - self.lastTimestamp < 2 || self.conversatonList.count == 0) {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self getAllConversations];
            });
        }
    }];
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
    [notifCenter addObserver:self
                    selector:@selector(RefreshConversation:)
                        name:@"RefreshConversation"
                      object:nil];
}


- (void)showUnReadNumber:(int)num {
    if (num == 0) {
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
        [self.tabBarController.tabBar.items[0] setBadgeValue:nil];
    }else if (num > 99) {
         [[UIApplication sharedApplication] setApplicationIconBadgeNumber:99];
        [self.tabBarController.tabBar.items[0] setBadgeValue:@"99+"];
    } else {
         [[UIApplication sharedApplication] setApplicationIconBadgeNumber:num];
        [self.tabBarController.tabBar.items[0] setBadgeValue:[NSString stringWithFormat:@"%d",num]];
    }
}

- (void)RefreshConversation:(NSNotification *)notify {
    BMXConversation *conversation = notify.object;
    for (int i=0; i<self.conversatonList.count; i++) {
        BMXConversation *c = [self.conversatonList objectAtIndex:i];
        if(c.conversationId == conversation.conversationId){
            NSIndexPath *ip = [NSIndexPath indexPathForRow:i inSection:0];
            [self.tableview reloadRowsAtIndexPaths:@[ip] withRowAnimation:(UITableViewRowAnimation)UITableViewRowAnimationNone];
        }
    }
}

- (void)p_networkStatusDidChanged:(NSNotification *)notifiaction {
    
    if ([notifiaction.name isEqualToString:@"disConnectionNetworkNotifation"]) {
        UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MAXScreenW, 44)];
        header.backgroundColor = [UIColor colorWithRed:253.0/255.0 green:236.0/255.0 blue:237.0/255.0 alpha:1];
        UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(20, 12, 20, 20)];
        imageview.image = [UIImage imageNamed:@"button_retry_comment"];
        [header addSubview:imageview];
        self.headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, MAXScreenW -  80, 44)];
        self.headerLabel.text = NSLocalizedString(@"network_is_not_available", @"当前网络不可用，请检查你的网络设置");
        self.headerLabel.font = [UIFont systemFontOfSize:13];
        [header addSubview:self.headerLabel];
        self.tableview.tableHeaderView = header;
        
    } else if ([notifiaction.name isEqualToString:@"connectingIPhoneNetworkNotifation"]) {
        self.tableview.tableHeaderView = nil;
        MAXLog(@"蜂窝");
        
    } else if ([notifiaction.name isEqualToString:@"connectingInWifiNetworkNotifation"]) {
         self.tableview.tableHeaderView = nil;
        MAXLog(@"WIFI");
    }
    
}

- (void)pushTosearhViewController {
    SearchContentViewController *vc = [[SearchContentViewController alloc]init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:NO];
}

- (void)getAllConversations{
    [[[BMXClient sharedClient] chatService] getAllConversationsWithCompletion:^(BMXConversationList *res) {
        NSMutableArray *conversations = [NSMutableArray array];
        for (int i=0; i<res.size; i++){
            [conversations addObject:[res get: i]];
        }
        if (conversations.count == 0) {
             //展示空白页
            [self.view insertSubview:self.tipView aboveSubview:self.tableview];
        }else {
            [self.tipView removeFromSuperview];
            [self getProfiletWithConversations:conversations];
        }

    }];
}

- (void)updateConversationWithRosterItem:(BMXRosterItem *)roster{
    for (int i=0; i<self.conversatonList.count; i++) {
        BMXConversation *c = [self.conversatonList objectAtIndex:i];
        if(c.conversationId == roster.rosterId){
            NSIndexPath *ip = [NSIndexPath indexPathForRow:i inSection:0];
            [self.tableview reloadRowsAtIndexPaths:@[ip] withRowAnimation:(UITableViewRowAnimation)UITableViewRowAnimationNone];
        }
    }
}

- (void)getProfiletWithConversations:(NSArray *)conversations {
    
    if (conversations.count == 0) {
        return;
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self getProfileWithConversatonList:[self sortConversationsByLastMessageTime:conversations]];
    });
}

- (void)getProfileWithConversatonList:(NSMutableArray *)conversatonList {
    [_profileLock lock];
    for (int i=0; i< conversatonList.count; i++) {
        BMXConversation *c = [conversatonList objectAtIndex:i];
        NSNumber *index = [NSNumber numberWithInt:i];
        [self.indexOfConversationId setObject:index forKey:@(c.conversationId)];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.conversatonList = conversatonList;
        [self.tableview reloadData];
    });

    [_profileLock unlock];
}

- (NSDictionary *)getSystemProfile {
    NSDictionary *configDic = [NSDictionary dictionaryWithDictionary:[self readLocalFileWithName:@"SystemRosterProfile"]];
    NSDictionary *dic = configDic[@"profile"];
    return dic;
    
}

// 读取本地JSON文件
- (NSDictionary *)readLocalFileWithName:(NSString *)name {
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"json"];
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    return [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
}


- (NSMutableArray *)sortConversationsByLastMessageTime:(NSArray *)conversations {
    
    NSArray *sort =  [conversations sortedArrayUsingComparator:^NSComparisonResult(id obj1,   id obj2) {
        //此处的规则含义为：若前一元素比后一元素小，则返回降序（即后一元素在前，为从大到小排列）
        BMXConversation *conversation1 = obj1;
        BMXConversation *conversation2 = obj2;
        if (conversation1.lastMsg == nil) {
            return NSOrderedDescending;
        }
        
        if (conversation2.lastMsg == nil) {
            return NSOrderedAscending;
        }
        //           NSLog(@"===排序");
        if (conversation1.lastMsg.serverTimestamp < conversation2.lastMsg.serverTimestamp) {
            return NSOrderedDescending;
        }  else {
            return NSOrderedAscending;
        }
        
    }];
    NSLog(@"===排序完成");
    return [NSMutableArray arrayWithArray:sort];
}

- (void)receiveNewMessage:(BMXMessage *)message {
    long long conversationId = message.conversationId;
    BOOL hasConversation = NO;
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    [temp addObjectsFromArray:self.conversatonList];
    for (BMXConversation *conversation in temp) {
        if (conversationId == conversation.conversationId) {
            hasConversation  = YES;
            break;
        }
    }
    if (!hasConversation) {
        BMXConversation_Type type;
        if (message.type == BMXMessage_MessageType_Single) {
            type = BMXConversation_Type_Single;
        } else {
            type = BMXConversation_Type_Group;
        }
        BMXConversation *conversation = [[[BMXClient sharedClient] chatService] openConversationWithConversationId:conversationId type:type createIfNotExist:YES];
        [self.conversatonList insertObject:conversation atIndex:0];
    }
    self.lastTimestamp = [[NSDate date] timeIntervalSince1970];
    if (self.conversatonList.count > 0) {
        [self.tipView removeFromSuperview];
    }
}

#pragma mark - BMXRTCServiceProtocol
- (void)onRTCHangupMessageReceiveWithMsg:(BMXMessage*)msg {
    [_hungUpCalls addObject:msg.config.getRTCCallId];
}

- (void)onRTCRecordMessageReceiveWithMsg:(BMXMessage*)message {
    if(message == nil){
        return;
    }
    if (message.fromId == [self.account.usedId longLongValue] ||
        (![message.content isEqualToString:@"canceled"] &&
         ![message.content isEqualToString:@"timeout"] &&
         ![message.content isEqualToString:@"busy"]
         )) {
        [[[BMXClient sharedClient] chatService] ackMessageWithMsg:message];
    }
}

- (void)receiveRTCCallMessage:(BMXMessage *)message{
    long long roomId = message.config.getRTCRoomId;
    if (self.account == nil){
        self.account = [IMAcountInfoStorage loadObject];
    }
    long long myId = [self.account.usedId longLongValue];
    MAXLog(@"myId:%lld", myId);
    long long peerId = message.config.getRTCInitiator;
    if (myId == peerId){
        return;
    }
    NSString *pin = message.config.getRTCPin;
    NSString *callId = message.config.getRTCCallId;
    BOOL hasVideo = message.config.getRTCCallType == 1;
    
    if ([[RTCEngineManager engineWithType:kMaxEngine] isOnCall]) {
        [self replyBusyWithCallId:callId myId:myId peerId:peerId];
        return;
    }

    [[[BMXClient sharedClient] rosterService] searchWithRosterId:peerId forceRefresh:NO completion:^(BMXRosterItem *bmxRosterItem, BMXError *error) {
        if (!error) {
            if ([self->_hungUpCalls containsObject:callId]) {
                [self->_hungUpCalls removeObject:callId];
                return;
            }

            CallViewController *videoCallViewController =
                [[CallViewController alloc] initForRoom:roomId
                                                         callId:callId
                                                           myId:myId
                                                         peerId:peerId
                                                      messageId:message.msgId
                                                            pin:pin
                                                       isCaller:NO
                                                       hasVideo:hasVideo
                                                    currentRoster:bmxRosterItem];
            videoCallViewController.modalTransitionStyle =  UIModalTransitionStyleCrossDissolve;
            videoCallViewController.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:videoCallViewController
                               animated:NO
                             completion:nil];
        }
    }];
}

- (void)replyBusyWithCallId:(NSString*)callId myId:(long long)myId peerId:(long long) peerId{
    // send rtc message
    BMXMessageConfig *config = [BMXMessageConfig createMessageConfigWithMentionAll: NO];
    [config setRTCHangupInfo:callId peerDrop:NO];
    NSString *content = @"busy"; //Caller canceled
    BMXMessage *msg = [BMXMessage createRTCMessageWithFrom:myId to:peerId type:BMXMessage_MessageType_Single conversationId:peerId content:content];
    [config setPushMessageLocKey:@"callee_busy"];

    msg.config = config;
    [[[BMXClient sharedClient] rtcService] sendRTCMessageWithMsg:msg completion:^(BMXError *aError) {
    }];
}

- (void)sendNewMessage:(BMXMessage *)message {
    
    long long conversationId = message.conversationId;
    BOOL hasConversation = NO;
    NSArray *temp = [self.conversatonList copy];
    for (BMXConversation *conversation in temp) {
        
        if (conversationId == conversation.conversationId) {
            hasConversation  = YES;
        }
    }
    if (!hasConversation) {
        
        BMXConversation_Type type;
        if (message.type == BMXMessage_MessageType_Single) {
            type = BMXConversation_Type_Single;
        } else {
            type = BMXConversation_Type_Group;
        }
        BMXConversation *conversation = [[[BMXClient sharedClient] chatService] openConversationWithConversationId:conversationId type:type createIfNotExist:YES];
    }
    if (self.conversatonList.count > 0) {
        [self.tipView removeFromSuperview];
    }
    
}

- (void)loadAllConversationDidFinished {
    MAXLog(@"loadAllConversationDidFinished");
    [self getAllConversations];
}


#pragma mark - UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 68.f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.conversatonList.count > 0 ? self.conversatonList.count : 0;
}

- (BOOL)isAtMeWithJson:(NSString *)json message:(BMXMessageObject *)message{
    IMAcount *im =  [IMAcountInfoStorage loadObject];

    NSDictionary *dic = [NSString dictionaryWithJsonString:json];
    if (dic == nil) {
        return NO;
    }
    NSArray *array = [NSArray arrayWithArray:dic[@"mentionList"]];
    for (NSString * idStr in array) {
        if ([idStr isEqualToString:im.usedId]) {
            return  YES;
        } else {
            return NO;
        }
    }
    return NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BMXConversation *conversation = self.conversatonList[indexPath.row];

    RecentConversaionTableViewCell *cell = [RecentConversaionTableViewCell cellWithTableview:tableView];
    
    id row;
    @try {
        row = [self.rosters objectForKey:@(conversation.conversationId)];
    } @catch (NSException *exception) {
        MAXLog(@"indexPath.row :%ld exception:%@",(long)indexPath.row, exception.description);
    }
    if (row == nil){
        if (conversation.type == BMXConversation_Type_Single || conversation.type == BMXConversation_Type_System) {
            if (conversation.conversationId == 0) {
                [self.rosters setObject: [self getSystemProfile] forKey:@(0)];
            } else {
                [[[BMXClient sharedClient] rosterService] searchWithRosterId:conversation.conversationId forceRefresh:NO completion:^(BMXRosterItem *bmxRosterItem, BMXError *error) {
                    if (!error) {
                        [self.rosters setObject:bmxRosterItem forKey:@(bmxRosterItem.rosterId)];
                        NSNumber *row = [self.indexOfConversationId objectForKey:@(conversation.conversationId)];
                        NSIndexPath *ip = [NSIndexPath indexPathForRow:[row integerValue] inSection:0];
                        [self.tableview reloadRowsAtIndexPaths:@[ip] withRowAnimation:(UITableViewRowAnimation)UITableViewRowAnimationNone];
                    }
                }];
            }
        } else {
            [[[BMXClient sharedClient] groupService] searchWithGroupId:conversation.conversationId forceRefresh:NO completion:^(BMXGroup *res, BMXError *error) {
                if (!error) {
                    [self.rosters setObject:res forKey:@(res.groupId)];
                    NSNumber *row = [self.indexOfConversationId objectForKey:@(conversation.conversationId)];
                    NSIndexPath *ip = [NSIndexPath indexPathForRow:[row integerValue] inSection:0];
                    [self.tableview reloadRowsAtIndexPaths:@[ip] withRowAnimation:(UITableViewRowAnimation)UITableViewRowAnimationNone];
                }
            }];
        }
        return cell;
    }
    if ([NSStringFromClass([row class]) isEqualToString:@"BMXRosterItem"]) {
        BMXRosterItem *roster = nil;
        @try{
            roster = row;
        }@catch(NSException *exception) {
            MAXLog(@"indexPath.row :%ld exception:%@",(long)indexPath.row, exception.description);
        }
        if (roster && roster.rosterId == conversation.conversationId) {
            
            cell.titleLabel.text = [roster.nickname length] ? roster.nickname : roster.username;
            UIImage *image = [UIImage imageWithContentsOfFile:roster.avatarThumbnailPath];
            if (!image) {
                cell.avatarImageView.image = [UIImage imageNamed:@"contact_placeholder"];
                [[[BMXClient sharedClient] rosterService] downloadAvatarWithItem:roster thumbnail:YES callback:^(int progress) {} completion:^(BMXError *error) {
                    if (!error){
                        UIImage *image = [UIImage imageWithContentsOfFile:roster.avatarThumbnailPath];
                        cell.avatarImageView.image = image;
                    }
                }];
            }else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    cell.avatarImageView.image = image;
                });
            }
            
        } else {
            cell.titleLabel.text = [NSString stringWithFormat:@"%lld", conversation.conversationId];
            cell.avatarImageView.image = [UIImage imageNamed:@"contact_placeholder"];
        }
    } else if ([NSStringFromClass([row class]) isEqualToString:@"BMXGroup"]) {
        
        BMXGroup *group = row;
        if (group.groupId == conversation.conversationId) {
            
            cell.titleLabel.text = group.name != nil ? group.name : NSLocalizedString(@"No_name_for_now", @"暂无名字");
            cell.avatarImageView.image = [UIImage imageNamed:@"group_placeHo"];
            
            if (group.avatarThumbnailPath > 0 && [[NSFileManager defaultManager] fileExistsAtPath:group.avatarThumbnailPath]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    cell.avatarImageView.image = [UIImage imageWithContentsOfFile:group.avatarThumbnailPath];
                });
//                MAXLog(@"group:%@", group.avatarThumbnailPath);

            }else {
                [[[BMXClient sharedClient] groupService]downloadAvatarWithGroup:group thumbnail:YES callback:^(int progress) {} completion:^(BMXError *error) {
                    if(!error){
                        dispatch_async(dispatch_get_main_queue(), ^{
                            UIImage *image = [UIImage imageWithContentsOfFile:group.avatarThumbnailPath];
                            cell.avatarImageView.image = image;
                        });
                    }
                }];
            }
        }else {
            
            cell.titleLabel.text = [NSString stringWithFormat:@"%lld", conversation.conversationId];
            cell.avatarImageView.image = [UIImage imageNamed:@"group_placeHo"];
            
        }
    }  else if ([row isKindOfClass:[NSDictionary class]]) {
        NSDictionary *profile = row;
        cell.titleLabel.text = [NSString stringWithFormat:@"%@", profile[@"userName"]];
        cell.avatarImageView.image = [UIImage imageNamed:@"systemAvater"];
        
    }
    
    cell.subtitleLabel.text = @"";
    if (conversation.lastMsg.contentType == BMXMessage_ContentType_Text || (conversation.lastMsg.contentType == BMXMessage_ContentType_RTC&&[conversation.editMessage length]>0)) {
        NSString *str;
        if ([conversation.editMessage length]) {
            str = [NSString stringWithFormat:@"[草稿] %@", conversation.editMessage];
        } else {
            str = conversation.lastMsg.content;
        }
        
        cell.subtitleLabel.text = str;
    } else if (conversation.lastMsg.contentType == BMXMessage_ContentType_Image) {
        cell.subtitleLabel.text = @"[图片]";
    } else if (conversation.lastMsg.contentType == BMXMessage_ContentType_File) {
        cell.subtitleLabel.text = @"[文件]";
    } else if (conversation.lastMsg.contentType == BMXMessage_ContentType_Voice) {
        cell.subtitleLabel.text = @"[语音]";
    } else if (conversation.lastMsg.contentType == BMXMessage_ContentType_Location) {
        cell.subtitleLabel.text = @"[位置]";
    } else if (conversation.lastMsg.contentType == BMXMessage_ContentType_Video) {
        cell.subtitleLabel.text = @"[视频]";
    } else if (conversation.lastMsg.contentType == BMXMessage_ContentType_RTC) {
        BMXMessage *message = conversation.lastMsg;
        if ([message.config.getRTCAction isEqualToString: @"record"]) {
            cell.subtitleLabel.text = @"[通话]";
            BOOL isFrom = message.fromId == [self.account.usedId longLongValue] ;
            if ([message.content isEqualToString:@"rejected"]) {
                if (!isFrom) {
                    cell.subtitleLabel.text = NSLocalizedString(@"call_rejected", @"通话已拒绝");
                }else{
                    cell.subtitleLabel.text = NSLocalizedString(@"call_rejected_by_callee", @"通话已被对方拒绝");
                }
            } else if ([message.content isEqualToString:@"canceled"]) {
                if (isFrom) {
                    cell.subtitleLabel.text = NSLocalizedString(@"call_canceled", @"通话已取消");
                }else{
                    cell.subtitleLabel.text = NSLocalizedString(@"call_canceled_by_caller", @"通话已被对方取消");
                }
            } else if ([message.content isEqualToString:@"timeout"]) {
                if (isFrom) {
                    cell.subtitleLabel.text = NSLocalizedString(@"callee_not_responding", @"对方未应答");
                }else{
                    cell.subtitleLabel.text = NSLocalizedString(@"call_not_responding", @"未应答");
                }
            } else if ([message.content isEqualToString:@"busy"]) {
                if (!isFrom) {
                    cell.subtitleLabel.text = NSLocalizedString(@"call_busy", @"忙线未接听");
                }else{
                    cell.subtitleLabel.text = NSLocalizedString(@"callee_busy", @"对方忙");
                }
            } else{
                int sec = [message.content intValue]/1000;
                NSString *format = message.config.isPeerDrop?
                NSLocalizedString(@"call_ended", @"通话中断：%02d:%02d"):
                NSLocalizedString(@"call_duration", @"通话时长：%02d:%02d");
                cell.subtitleLabel.text = [NSString stringWithFormat:format, sec/60, sec%60];
            }
        }
    }
    
    if (conversation.lastMsg.serverTimestamp > 0) {
        cell.timeLabel.hidden = NO;
        NSString *date = [NSString stringWithFormat:@"%lld", conversation.lastMsg.serverTimestamp];
        cell.timeLabel.text = [LHTools dayStringOnConversationListWithDate:date];
    } else {
        cell.timeLabel.hidden = YES;
    }
    NSString * t = [NSString stringWithFormat:@"%ld",(long)[conversation unreadNumber]];
        cell.dotView.hidden = YES;
        cell.dotLabel.hidden = [conversation unreadNumber] <= 0;
        cell.dotLabel.text  = t;
            
        if (conversation.type == BMXConversation_Type_Group) {
            BMXGroup *group = row;
            if ([NSStringFromClass(group.class) isEqualToString:@"BMXGroup"]) {
                if (group.msgMuteMode == BMXGroup_MsgMuteMode_MuteNotification) {
                    cell.dotLabel.hidden = YES;
                    if ([conversation unreadNumber] > 0) {
                        cell.dotView.hidden = NO;
                    }
                }
            }
        } else if (conversation.type == BMXConversation_Type_Single){
            BMXRosterItem *roster = row;
            if ([NSStringFromClass(roster.class) isEqualToString:@"BMXRosterItem"]) {
                if (roster.isMuteNotification == YES) {
                    cell.dotLabel.hidden = YES;
                    if ([conversation unreadNumber] > 0) {
                        cell.dotView.hidden = NO;
                    }
                }
            }
        }
        return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        BMXConversation *conversation = self.conversatonList[indexPath.row];
        [self removeconversation:conversation];
        MAXLog(@"删除动作");
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return NSLocalizedString(@"Delete", @"删除");
}

- (void)removeconversation:(BMXConversation *)conversation {
    [[[BMXClient sharedClient] chatService] deleteConversationWithConversationId:conversation.conversationId];
    [self.conversatonList removeObject:conversation];
    [self.tableview reloadData];
}

- (void)conversationDidDeletedConversationId:(NSInteger)conversationId error:(BMXError *)error {
    MAXLog(@"会话已被删除");
}

- (void)chatVCDidSelectReturnButton {
    
}
- (void)conversationTotalCountChanged:(NSInteger)unreadCount {
    
    [self showUnReadNumber:(int)unreadCount];
}
#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    BMXConversation *conversation = self.conversatonList[indexPath.row];
    LHChatVC *chatVC;
    id row;
    @try {
        row = [self.rosters objectForKey:@(conversation.conversationId)];
    } @catch (NSException *exception) {
        MAXLog(@"indexPath.row :%ld exception:%@",(long)indexPath.row, exception.description);
    }
    if (!row){
        return;
    }

    if ([NSStringFromClass([row class]) isEqualToString:@"BMXRosterItem"]) {
        BMXRosterItem *roster = row;
        chatVC = [[LHChatVC alloc] initWithRoster:roster messageType:BMXMessage_MessageType_Single];
        BMXConversation *conversation = self.conversatonList[indexPath.row];
        if (conversation.unreadNumber > 0) {
//            [conversation setAllMessagesReadCompletion:^(BMXError * _Nonnull error) {
//            }];
            [conversation setAllMessagesRead];
            RecentConversaionTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.dotLabel.hidden = YES;
        }
        
        
        chatVC.delegate = self;
        [chatVC setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:chatVC animated:YES];
    } else if ([NSStringFromClass([row class]) isEqualToString:@"BMXGroup"]) {

        BMXGroup *group = row;
        chatVC = [[LHChatVC alloc] initWithGroupChat:(BMXGroup *)group messageType:BMXMessage_MessageType_Group];
        
        BMXConversation *conversation = self.conversatonList[indexPath.row];
        if (conversation.unreadNumber > 0) {
            
            if (conversation.lastMsg) {
                [[[BMXClient sharedClient] chatService] readAllMessageWithMsg:conversation.lastMsg];
            }
            RecentConversaionTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.dotLabel.hidden = YES;
        }
        
        chatVC.delegate = self;
        [chatVC setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:chatVC animated:YES];
    } else if ([row isKindOfClass:[NSDictionary class]]) {
        BMXConversation *conversation = self.conversatonList[indexPath.row];
        if (conversation.unreadNumber > 0) {
            
            if (conversation.lastMsg) {
                [[[BMXClient sharedClient] chatService] readAllMessageWithMsg:conversation.lastMsg];
            }
            RecentConversaionTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.dotLabel.hidden = YES;
        }
        
        SystemNotificationViewController *vc = [[SystemNotificationViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        vc.conversation = conversation;
        [self.navigationController pushViewController:vc animated: YES];

        
    } else {
        [HQCustomToast showDialog:NSLocalizedString(@"Unable_to_access_conversation_profile", @"无法获取会话资料") time:1.0f];
        BMXConversation *conversation = self.conversatonList[indexPath.row];
        BMXMessage_MessageType messageType = BMXMessage_MessageType_Single;
        if (conversation.type == BMXConversation_Type_Group) {
            messageType = BMXMessage_MessageType_Group;
        }
        chatVC = [[LHChatVC alloc] initWithConversationId:conversation.conversationId messageType:messageType];
        if (conversation.unreadNumber > 0) {
            [conversation setAllMessagesRead];
            RecentConversaionTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.dotLabel.hidden = YES;
        }
        
        
        chatVC.delegate = self;
        [chatVC setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:chatVC animated:YES];
    }
}

- (void)clickScanButton:(UIButton *)button {
    ScanViewController *vc = [[ScanViewController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated: YES];
}

- (void)clickSearchButton:(UIButton *)button {
    [self pushTosearhViewController];
}

- (UITableView *)tableview {
    if (!_tableview) {
        _tableview = [[UITableView alloc] initWithFrame:self.view.bounds
                                                  style:UITableViewStylePlain];
        
        CGFloat navh = kNavBarHeight;
        if (MAXIsFullScreen) {
            navh  = kNavBarHeight + 24;
        }
        _tableview.frame = CGRectMake(0, navh , MAXScreenW, MAXScreenH - navh - 36);
        _tableview.delegate = self;
        _tableview.dataSource = self;
        _tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:_tableview];
    }
    return _tableview;
}

- (void)setUpNavItem{
    [self setMainNavigationBarTitle:NSLocalizedString(@"Maximtop", @"蓝莺IM")];
    
    UIImage *scanImage = [UIImage imageNamed:@"scanbutton"];
    UIButton *scanButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.navigationBar addSubview:scanButton];
    [scanButton setImage:scanImage forState:UIControlStateNormal];
    scanButton.frame = CGRectMake(MAXScreenW - 10 - 30, NavHeight - 5 -30, 30, 30);
    [scanButton addTarget:self action:@selector(clickScanButton:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImage *searchImage = [UIImage imageNamed:@"search"];
    UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.navigationBar addSubview:searchButton];
    [searchButton setImage:searchImage forState:UIControlStateNormal];
    searchButton.frame = CGRectMake(MAXScreenW - 10 - 30 - 5 -30, NavHeight - 5 -30, 30, 30);
    [searchButton addTarget:self action:@selector(clickSearchButton:) forControlEvents:UIControlEventTouchUpInside];

    
}

- (NSArray<BMXConversation *> *)conversatonList {
    if (_conversatonList == nil) {
        _conversatonList = [NSMutableArray array];
    }
    return _conversatonList;
}

- (NSMutableDictionary *) indexOfConversationId{
    if (_indexOfConversationId == nil) {
        _indexOfConversationId = [NSMutableDictionary dictionary];
    }
    return _indexOfConversationId;
}

- (NSCache *)rosters{
    if (!_rosters) {
        _rosters = [[NSCache alloc] init];
        _rosters.totalCostLimit = 100000;
        _rosters.delegate = self;
      }
      return _rosters;
}

- (NSString *)compareCurrentTime:(NSTimeInterval)currentDate
                    comepareDate:(NSTimeInterval)comepareDate{
    
    NSTimeInterval  timeInterval = currentDate - comepareDate;
    if (timeInterval < 0) {
        timeInterval = -timeInterval;
    }
    long temp = 0;
    NSString *result;
    if (timeInterval < 60) {
        result = [NSString stringWithFormat:NSLocalizedString(@"Just_now", @"刚刚")];
    }else if((temp = timeInterval/60) < 60){
        result = [NSString stringWithFormat:NSLocalizedString(@"nminutes_ago", @"%ld分钟前"),temp];
    }else if((temp = temp/60) < 24){
        
        NSDate *messageDate = [NSDate dateWithTimeIntervalSince1970:comepareDate];
        NSDateFormatter * df = [[NSDateFormatter alloc]init];
        [df setDateFormat:@"hh:mm aa"];
        [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:8*3600]];
        result = [df stringFromDate:messageDate];;
    }else {
        NSDate *messageDate = [NSDate dateWithTimeIntervalSince1970:comepareDate];
        NSDateFormatter * df = [[NSDateFormatter alloc]init];
        [df setDateFormat:@"MM-dd hh:mm"];
        [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:8*3600]];
        result = [df stringFromDate:messageDate];;
    }
    return  result;
}

- (MaxEmptyTipView *)tipView {
    
    if (!_tipView) {
        
        CGFloat navh = kNavBarHeight;
        if (MAXIsFullScreen) {
            navh  = kNavBarHeight + 24;
        }
        _tipView = [[MaxEmptyTipView alloc] initWithFrame:CGRectMake(0, navh + 1 , MAXScreenW, MAXScreenH - navh - 37) type:MaxEmptyTipTypeCommonBlank];
    }
    return _tipView;
}

- (void)dealloc {
    if (_timer){
        [_timer invalidate];
        _timer  = nil;
    }
}

@end
