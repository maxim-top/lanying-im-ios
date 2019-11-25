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

#import "MAXLoginViewController.h"
#import "IMAcountInfoStorage.h"
#import <floo-ios/BMXClient.h>

#import "IMAcount.h"
#import "IMAcountInfoStorage.h"

#import <floo-ios/BMXClient.h>
#import <floo-ios/BMXConversation.h>

#import "MAXGlobalTool.h"

#import <floo-ios/BMXConversation.h>
#import "RecentConversaionTableViewCell.h"
#import <floo-ios/BMXMessageObject.h>

#import "BMXSearchView.h"
#import "SearchContentViewController.h"
#import "UIView+BMXframe.h"
#import <floo-ios/BMXClient.h>

#import "UIViewController+CustomNavigationBar.h"
#import "ScanViewController.h"
#import "SystemNotificationViewController.h"
#import "MaxEmptyTipView.h"

@interface MainViewController ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, ChatVCDelegate, BMXChatServiceProtocol>

@property (nonatomic, strong) NSMutableArray<BMXConversation *> *conversatonList;
@property (nonatomic, strong) NSMutableArray *profileArray;
@property (nonatomic, strong) UITableView *tableview;
@property (nonatomic, assign) bool isLogin;
@property (nonatomic, strong) BMXSearchView *searchView;
@property (nonatomic, strong) UIButton *searchbigButton;
@property (nonatomic, strong) UILabel *headerLabel;
@property (nonatomic, assign) BOOL conversationFinish;
@property (nonatomic, strong) MaxEmptyTipView *tipView;



@end

@implementation MainViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setUpNavItem];
//    [self setupSearchView];
    
    [[[BMXClient sharedClient] chatService] addChatListener:self];
    
    [NetWorkingManager netWorkingManagerWithNetworkStatusListening];
    [self p_addObserver];

//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getAllConversations) name:@"loginSuccess" object:nil];
    
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
        UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MAXScreenW, 44)];
        header.backgroundColor = [UIColor colorWithRed:253.0/255.0 green:236.0/255.0 blue:237.0/255.0 alpha:1];
        UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(20, 12, 20, 20)];
        imageview.image = [UIImage imageNamed:@"button_retry_comment"];
        [header addSubview:imageview];
        self.headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, MAXScreenW -  80, 44)];
        self.headerLabel.text = @"当前网络不可用，请检查你的网络设置";
        self.headerLabel.font = [UIFont systemFontOfSize:13];
        [header addSubview:self.headerLabel];
        self.tableview.tableHeaderView = header;
        
    } else if ([notifiaction.name isEqualToString:@"connectingIPhoneNetworkNotifation"]) {
        self.tableview.tableHeaderView = nil;
        MAXLog(@"蜂窝");
        
    } else if ([notifiaction.name isEqualToString:@"connectingInWifiNetworkNotifation"]) {
        //        [HQCustomToast showDialog:@"已连接WiFi，正在WiFi下播放"];
        //        self.internetStatus = ReachableViaWiFi;
         self.tableview.tableHeaderView = nil;
        MAXLog(@"WIFI");
    }
}

//- (void)setupSearchView {
//    self.searchView = [BMXSearchView searchView];
//    self.searchView.searchTF.placeholder = @"  请输入要搜索的内容";
//    self.searchView.searchTF.delegate = self;
//    self.searchView.searchTF.returnKeyType = UIReturnKeySearch;
//
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//    [button addTarget:self action:@selector(pushTosearhView) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:button];
//    [self.view addSubview:self.searchView];
//    button.frame = self.searchView.frame;
//    [self.view addSubview:button];
//}

- (void)pushTosearhViewController {
    SearchContentViewController *vc = [[SearchContentViewController alloc]init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:NO];
}

- (void)getAllConversations{

    dispatch_async(dispatch_get_main_queue(), ^{
        [HQCustomToast showWating];
    });
    
    [[[BMXClient sharedClient] chatService] getAllConversationsWithCompletion:^(NSArray *conversations) {
        
        MAXLog(@"%ld", conversations.count);
        if (conversations.count == 0) {
             //展示空白页
            [self.view insertSubview:self.tipView aboveSubview:self.tableview];
            [HQCustomToast hideWating];
        }else {
            [self.tipView removeFromSuperview];
            [self getProfiletWithConversations:conversations];
        }
    } ];

    
}

- (void)getProfiletWithConversations:(NSArray *)conversations {
    [self getProfileWithConversatonList:[self sortConversationsByLastMessageTime:[NSMutableArray arrayWithArray:conversations]]];
}

- (void)getProfileWithConversatonList:(NSMutableArray *)conversatonList {
    NSMutableArray *tempProfileArray = [NSMutableArray array];
       NSLog(@"===开始获取资料");
    dispatch_queue_t queue = dispatch_queue_create("getProfile",DISPATCH_QUEUE_SERIAL);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        for (BMXConversation *conversation in conversatonList) {
            dispatch_async(queue, ^{
                
                if (conversation.type == BMXConversationSingle) {
                    if (conversation.conversationId == 0) {
                        dispatch_semaphore_signal(semaphore);
                        [tempProfileArray addObject:[self getSystemProfile]];
                    } else {
                        [[[BMXClient sharedClient] rosterService] searchByRosterId:conversation.conversationId forceRefresh:NO completion:^(BMXRoster *roster, BMXError *error) {
                            dispatch_semaphore_signal(semaphore);
                            if (!error) {
                                [tempProfileArray addObject:roster];
                            }else {
                                // 获取不到资料时，新建一个对象占位
                                [tempProfileArray addObject:@"无法获取资料"];
                            }
                        }];
                    }
                   
                     dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                    
                } else {
                    [[[BMXClient sharedClient] groupService] getGroupInfoByGroupId:conversation.conversationId forceRefresh:NO completion:^(BMXGroup *group, BMXError *error) {
                        dispatch_semaphore_signal(semaphore);
                        if (!error) {
                            [tempProfileArray addObject:group];
                        }else {
                             // 获取不到资料时，新建一个对象占位
                            [tempProfileArray addObject:@"无法获取资料"];
                        }
                    }];
                     dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                }
            });
        }
    
    dispatch_async(queue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            self.conversatonList = conversatonList;
            self.profileArray = [NSMutableArray arrayWithArray:[tempProfileArray copy]];
            [self.tableview reloadData];
            [HQCustomToast hideWating];
        });
    });
}

- (NSDictionary *)getSystemProfile {
    NSDictionary *configDic = [NSDictionary dictionaryWithDictionary:[self readLocalFileWithName:@"SystemRosterProfile"]];
    MAXLog(@"%@", configDic);
    NSDictionary *dic = configDic[@"profile"];
    return dic;
    
}

// 读取本地JSON文件
- (NSDictionary *)readLocalFileWithName:(NSString *)name {
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"json"];
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    return [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
}


- (NSMutableArray *)sortConversationsByLastMessageTime:(NSMutableArray *)conversations {
    [conversations sortUsingComparator:^NSComparisonResult(BMXConversation *obj1, BMXConversation *obj2) {
        //此处的规则含义为：若前一元素比后一元素小，则返回降序（即后一元素在前，为从大到小排列）
        if (obj1.lastMessage == nil) {
            return NSOrderedDescending;
        }
        
        if (obj2.lastMessage == nil) {
            return NSOrderedAscending;
        }
//           NSLog(@"===排序");
        
        if (obj1.lastMessage.serverTimestamp < obj2.lastMessage.serverTimestamp) {
            return NSOrderedDescending;
        }  else {
            return NSOrderedAscending;
        }
        
    }];
    NSLog(@"===排序完成");
    return conversations;
}

- (void)receiveNewMessage:(BMXMessageObject *)message {
    long long conversationId = message.conversationId;
    BOOL hasConversation = NO;
    NSArray *temp = [self.conversatonList copy];
    for (BMXConversation *conversation in temp) {
        if (conversationId == conversation.conversationId) {
            hasConversation  = YES;
            [self getProfiletWithConversations:temp];
            break;
        }
    }
    if (!hasConversation) {
        BMXConversationType type;
        if (message.messageType == BMXMessageTypeSingle) {
            type = BMXConversationSingle;
        } else {
            type = BMXConversationGroup;
        }
        BMXConversation *conversation = [[[BMXClient sharedClient] chatService] openConversation:conversationId type:type createIfNotExist:YES];
        [self.conversatonList insertObject:conversation atIndex:0];
        [self getProfiletWithConversations:self.conversatonList];
        
        if (self.conversatonList.count > 0) {
            [self.tipView removeFromSuperview];
        }
    }
}

- (void)sendNewMessage:(BMXMessageObject *)message {
    
    long long conversationId = message.conversationId;
    BOOL hasConversation = NO;
    NSArray *temp = [self.conversatonList copy];
    for (BMXConversation *conversation in temp) {
        
        if (conversationId == conversation.conversationId) {
            hasConversation  = YES;
            [self getProfiletWithConversations:self.conversatonList];
        }
    }
    if (!hasConversation) {
        
        BMXConversationType type;
        if (message.messageType == BMXMessageTypeSingle) {
            type = BMXConversationSingle;
        } else {
            type = BMXConversationGroup;
        }
        BMXConversation *conversation = [[[BMXClient sharedClient] chatService] openConversation:conversationId type:type createIfNotExist:YES];
        [self.conversatonList insertObject:conversation atIndex:0];
        [self getProfiletWithConversations:self.conversatonList];
    }
    
    if (self.conversatonList.count > 0) {
        [self.tipView removeFromSuperview];
    }
    
}

- (void)loadAllConversationDidFinished {
    MAXLog(@"all");
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
//    MAXLog(@"%@",conversation.lastMessage.content);

    RecentConversaionTableViewCell *cell = [RecentConversaionTableViewCell cellWithTableview:tableView];
    
    
    if ([NSStringFromClass([self.profileArray[indexPath.row] class]) isEqualToString:@"BMXRoster"]) {
        BMXRoster *roster = self.profileArray[indexPath.row];
        if (roster.rosterId == conversation.conversationId) {
            
            cell.titleLabel.text = [roster.nickName length] ? roster.nickName : roster.userName;
            cell.avatarImageView.image = [UIImage imageNamed:@"contact_placeholder"];
            UIImage *image = [UIImage imageWithContentsOfFile:roster.avatarThumbnailPath];
            if (!image) {
                [[[BMXClient sharedClient] rosterService] downloadAvatarWithRoster:roster progress:^(int progress, BMXError *error) {
                    
                }  completion:^(BMXRoster *roster, BMXError *error) {
                    if (!error) {
                        UIImage *image = [UIImage imageWithContentsOfFile:roster.avatarThumbnailPath];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            cell.avatarImageView.image = image;
                        });
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
    } else if ([NSStringFromClass([self.profileArray[indexPath.row] class]) isEqualToString:@"BMXGroup"]) {
        
        BMXGroup *group = self.profileArray[indexPath.row];
        if (group.groupId == conversation.conversationId) {
            
            cell.titleLabel.text = group.name != nil ? group.name : @"暂无名字";
            cell.avatarImageView.image = [UIImage imageNamed:@"group_placeHo"];
            
            if (group.avatarThumbnailPath > 0 && [[NSFileManager defaultManager] fileExistsAtPath:group.avatarThumbnailPath]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    cell.avatarImageView.image = [UIImage imageWithContentsOfFile:group.avatarThumbnailPath];
                });
//                MAXLog(@"group:%@", group.avatarThumbnailPath);

            }else {
                [[[BMXClient sharedClient] groupService] downloadAvatarWithGroup:group progress:^(int progress, BMXError *error) {
                } completion:^(BMXGroup *resultGroup, BMXError *error) {
//                    MAXLog(@"groupR:%@", resultGroup.avatarThumbnailPath);

                    if (error == nil) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            UIImage *image = [UIImage imageWithContentsOfFile:resultGroup.avatarThumbnailPath];
                            cell.avatarImageView.image = image;
                            
                        });
                    }
                }];
            }
            

        }else {
            
            cell.titleLabel.text = [NSString stringWithFormat:@"%lld", conversation.conversationId];
            cell.avatarImageView.image = [UIImage imageNamed:@"group_placeHo"];
            
        }
    }  else if ([self.profileArray[indexPath.row] isKindOfClass:[NSDictionary class]]) {
        NSDictionary *profile = self.profileArray[indexPath.row];
        cell.titleLabel.text = [NSString stringWithFormat:@"%@", profile[@"userName"]];
        cell.avatarImageView.image = [UIImage imageNamed:@"systemAvater"];
        
    } else {
        cell.titleLabel.text = [NSString stringWithFormat:@"%lld", conversation.conversationId];
        cell.avatarImageView.image = [UIImage imageNamed:@"group_placeHo"];
    }
    
    if (conversation.lastMessage.contentType == BMXContentTypeText) {
        NSString *str;
        if ([conversation.editMessage length]) {
            str = [NSString stringWithFormat:@"[草稿] %@", conversation.editMessage];
        } else {
            str = conversation.lastMessage.content;
        }
        
        cell.subtitleLabel.text = str;
    } else if (conversation.lastMessage.contentType == BMXContentTypeImage) {
        cell.subtitleLabel.text = @"[图片]";
    } else if (conversation.lastMessage.contentType == BMXContentTypeFile) {
        cell.subtitleLabel.text = @"[文件]";
    } else if (conversation.lastMessage.contentType == BMXContentTypeVoice) {
        cell.subtitleLabel.text = @"[语音]";
    } else if (conversation.lastMessage.contentType == BMXContentTypeLocation) {
        cell.subtitleLabel.text = @"[位置]";
    } else if (conversation.lastMessage.contentType == BMXContentTypeVideo) {
        cell.subtitleLabel.text = @"[视频]";
    }
    
    if (conversation.lastMessage.serverTimestamp > 0) {
        cell.timeLabel.hidden = NO;
        cell.timeLabel.text = [self compareCurrentTime:[[NSDate date] timeIntervalSince1970] comepareDate:conversation.lastMessage.serverTimestamp * 0.001];;
    } else {
        cell.timeLabel.hidden = YES;
    }
    
    if (conversation.type == BMXConversationGroup) {
        BMXGroup *group = self.profileArray[indexPath.row];
        if ([NSStringFromClass(group.class) isEqualToString:@"BMXGroup"]) {
            if (group.msgMuteMode == BMXGroupMsgMuteModeMuteNotification) {
                if ([conversation unreadNumber] > 0) {
                    cell.dotLabel.hidden = YES;
                    cell.dotView.hidden = NO;
                } else {
                    cell.dotView.hidden = YES;
                    cell.dotLabel.hidden = YES;
                }
                cell.dotLabel.text  = @"";
            } else if (group.msgMuteMode == BMXGroupMsgMuteModeNone){
                cell.dotLabel.hidden = [conversation unreadNumber] == 0;
                cell.dotView.hidden = YES;
                cell.dotLabel.text  = [NSString stringWithFormat:@"%ld",(long)[conversation unreadNumber]];
            } else {
                cell.dotView.hidden = YES;
                cell.dotLabel.hidden = YES;
            }
        }
    } else {
        BMXRoster *roster = self.profileArray[indexPath.row];
        if ([NSStringFromClass(roster.class) isEqualToString:@"BMXRoster"]) {
            
            if (roster.isMuteNotification == YES) {
                if ([conversation unreadNumber] > 0) {
                    cell.dotLabel.hidden = YES;
                    cell.dotView.hidden = NO;
                } else {
                    cell.dotView.hidden = YES;
                    cell.dotLabel.hidden = YES;
                }
                cell.dotLabel.text  = @"";
            } else {
                cell.dotLabel.hidden = [conversation unreadNumber] == 0;
                cell.dotLabel.text  = [NSString stringWithFormat:@"%ld",(long)[conversation unreadNumber]];
            }
        }else {
            cell.dotLabel.hidden = YES;
            cell.dotView.hidden = YES;
            cell.dotLabel.text  = @"";
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
    return @"删除";
}

- (void)removeconversation:(BMXConversation *)conversation {
    [[[BMXClient sharedClient]chatService] deleteConversationByConversationId:conversation.conversationId synchronize:YES];
    [self.profileArray removeObjectAtIndex:[self.conversatonList indexOfObject:conversation]];
    [self.conversatonList removeObject:conversation];
    [self.tableview reloadData];
}

- (void)conversationDidDeletedConversationId:(NSInteger)conversationId error:(BMXError *)error {
    MAXLog(@"会话已被删除");
}

- (void)chatVCDidSelectReturnButton {
    
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    LHChatVC *chatVC;
    if ([NSStringFromClass([self.profileArray[indexPath.row] class]) isEqualToString:@"BMXRoster"]) {
        BMXRoster *roster = self.profileArray[indexPath.row];
        chatVC = [[LHChatVC alloc] initWithRoster:roster messageType:BMXMessageTypeSingle];
        BMXConversation *conversation = self.conversatonList[indexPath.row];
        if (conversation.unreadNumber > 0) {
            [conversation setAllMessagesReadCompletion:^(BMXError * _Nonnull error) {
            }];
            RecentConversaionTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.dotLabel.hidden = YES;
        }
        
        
        chatVC.delegate = self;
        [chatVC setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:chatVC animated:YES];
    } else if ([NSStringFromClass([self.profileArray[indexPath.row] class]) isEqualToString:@"BMXGroup"]) {

        BMXGroup *group = self.profileArray[indexPath.row];
        chatVC = [[LHChatVC alloc] initWithGroupChat:(BMXGroup *)group messageType:BMXMessageTypeGroup];
        
        BMXConversation *conversation = self.conversatonList[indexPath.row];
        if (conversation.unreadNumber > 0) {
            
            if (conversation.lastMessage) {
                [[[BMXClient sharedClient] chatService] readAllMessage:conversation.lastMessage];
            }
            [[[BMXClient sharedClient] chatService] readAllMessage:conversation.lastMessage];
            RecentConversaionTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.dotLabel.hidden = YES;
        }
        
        chatVC.delegate = self;
        [chatVC setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:chatVC animated:YES];
    } else if ([self.profileArray[indexPath.row] isKindOfClass:[NSDictionary class]]) {
        BMXConversation *conversation = self.conversatonList[indexPath.row];
        SystemNotificationViewController *vc = [[SystemNotificationViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        vc.conversation = conversation;
        [self.navigationController pushViewController:vc animated: YES];

        
    } else {
        [HQCustomToast showDialog:@"无法获取会话资料" time:1.0f];
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
    [self setMainNavigationBarTitle:@"美信拓扑"];
    
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

- (NSMutableArray *)profileArray {
    if (_profileArray == nil) {
        _profileArray = [NSMutableArray array];
    }
    return _profileArray;
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
        result = [NSString stringWithFormat:@"刚刚"];
    }else if((temp = timeInterval/60) < 60){
        result = [NSString stringWithFormat:@"%ld分钟前",temp];
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
        _tipView = [[MaxEmptyTipView alloc] initWithFrame:CGRectMake(0, navh + 1 , MAXScreenW, MAXScreenH - navh - 37)];
    }
    return _tipView;
}

@end
