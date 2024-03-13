//
//  LHChatVC.m
//  LHChatUI
//
//  Created by hyt on 2016/12/22.
//  Copyright © 2016年 hyt. All rights reserved.
//

#import "LHChatVC.h"
#import "NSString+Extention.h"
#import "LHChatBarView.h"
#import "LHContentModel.h"
#import "LHMessageModel.h"
#import "LHIMDBManager.h"
#import "LHTools.h"

#import "KeyboardEmojiTextView.h"
#import "LHChatViewCell.h"
#import "LHChatTimeCell.h"
#import "SDImageCache.h"
#import "LHPhotoPreviewController.h"
#import "XSBrowserAnimateDelegate.h"

#import "BMXRecoderTools.h"
#import "BMXVoiceHud.h"

#import <floo-ios/floo_proxy.h>

#import "IMAcount.h"
#import "IMAcountInfoStorage.h"

#import "GroupDetailViewController.h"
#import "ChatRosterProfileViewController.h"
#import "TransterViewController.h"

#import "UIButton+Extention.h"
#import "MJRefresh.h"

#import "GroupCreateViewController.h"
#import "GroupOwnerTransterViewController.h"
#import "GroupAlreadyReadListViewController.h"

#import "BubbleViewAlertView.h"
#import "YYLabel.h"
#import "NSAttributedString+YYText.h"
#import "LocationManger.h"
#import "VideoView.h"
#import "VideoManager.h"
#import "ICAVPlayer.h"
#import <AVFoundation/AVFoundation.h>

#import <CoreLocation/CoreLocation.h>
#import "UIViewController+CustomNavigationBar.h"
#import "CallViewController.h"
#import <SafariServices/SFSafariViewController.h>
#import "TextLayoutCache.h"

NSString *const kTableViewOffset = @"contentOffset";
NSString *const kTableViewFrame = @"frame";
NSUInteger const kMaxWaitTimes = 200;
@interface LHChatVC () <UITableViewDelegate,
UITableViewDataSource,
XSBrowserDelegate,
BMXChatServiceProtocol,
BMXRTCServiceProtocol,
ChatBarProtocol,
GroupCreateViewControllerDelegate,
GroupOwnerTransterViewControllerDelegate,
TransterContactProtocol,
BMXRecoderToolsProtocol,
UIDocumentInteractionControllerDelegate,
CLLocationManagerDelegate>
{
    NSArray *_imageKeys;
    
    UIMenuItem * _copyMenuItem;
    UIMenuItem * _forwardMenuItem;
    UIMenuItem * _recallMenuItem;
    UIMenuItem * _unreadMenuItem;
    UIMenuItem * _deleteMenuItem;

    NSIndexPath *_longIndexPath;
    
}

@property (nonatomic, strong) BMXRosterItem *currentRoster;
@property (nonatomic, strong) BMXGroup *currentGroup;
@property (nonatomic,assign)  BMXMessage_MessageType messageType;


@property (strong, nonatomic) UITableView *tableView;
@property (nonatomic, strong) LHChatBarView *chatBarView;
// 满足刷新
@property (nonatomic, assign, getter=isMeetRefresh) BOOL meetRefresh;
// 正在刷新
@property (nonatomic, assign, getter=isHeaderRefreshing) BOOL headerRefreshing;

@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, strong) NSMutableArray *recallMessages;
@property (atomic, strong) NSMutableSet *deliveringMsgClientIds;

@property (nonatomic, strong) NSCache *rowHeight;

// 消息时间
@property (nonatomic, strong) NSString *lastTime;
@property (nonatomic, assign) CGFloat tableViewOffSetY;
@property (nonatomic, assign) NSInteger imageIndex;

@property (nonatomic, strong) XSBrowserAnimateDelegate *browserAnimateDelegate;

@property (nonatomic, strong) IMAcount *account;

// 录音
@property (nonatomic, strong) BMXVoiceHud *voiceHud;
@property (nonatomic, strong) UILabel *voiceTip;
@property (nonatomic, strong) NSTimer *timer; //记录录音的动画

@property (nonatomic, assign) long long conversationId;
@property (nonatomic, strong) UIImage *selfImage;
@property (nonatomic, strong) UIImage *deImage;

@property (nonatomic, strong) BMXConversation *conversation;

@property (nonatomic,assign) BOOL groupAt;

@property (nonatomic, strong) NSArray *atArray;

@property (nonatomic, strong) LHMessageModel *currentMessage;

@property (nonatomic, copy) NSString *recordName;

@property (nonatomic, strong)  UIDocumentInteractionController *documentIntertactionController;

@property (nonatomic,copy) NSString *editContent;

@property (nonatomic, strong) NSString *voicePath;
@property (nonatomic, strong) NSIndexPath *curVoiceIndexPath;

@property (nonatomic, strong) CLLocationManager *locationManager;//设置manager
@property (nonatomic, strong) NSString *currentCity;

@property (nonatomic,assign) BOOL needAutoScrollToBottom;//自动滚屏到最新消息

@property (nonatomic, strong) VideoView *videoView;

@property (nonatomic, strong) LHMessageModel *typeWriterDbMessageModel; //当前使用打字机动画的消息
@property (nonatomic, copy) NSString *typeWriterMessageText; //打字机动画消息全部文本
@property (nonatomic, strong) NSIndexPath *typeWriterIndex; //打字机动画消息索引
@property (nonatomic,assign) BOOL needTypeToEnd;//将当前打字机动画结束（新消息到达时）
@property (nonatomic, strong) NSLock *typeWriterLock; //打字机锁，控制相关变量的读写
@property (nonatomic, strong) NSLock *messageHandleLock; //消息处理锁
@property (nonatomic,assign) NSUInteger waitingTimes;//等待后续消息片断计次


@end

@implementation LHChatVC

- (instancetype)initWithRoster:(BMXRosterItem *)roster
                   messageType:(BMXMessage_MessageType)messageType {
    if (self = [super init]) {
        self.currentRoster = roster;
        self.messageType = messageType;
        MAXLog(@"单聊：roster%lld",self.currentRoster.rosterId );
    }
    return self;
}

- (instancetype)initWithConversationId:(long long)conversationId
                   messageType:(BMXMessage_MessageType)messageType {
    if (self = [super init]) {
        self.conversationId = conversationId;
        self.messageType = messageType;
        MAXLog(@"单聊：conversationId:%lld",self.conversationId );
    }
    return self;
}

- (instancetype)initWithGroupChat:(BMXGroup *)group
                      messageType:(BMXMessage_MessageType)messageType {
    if (self = [super init]) {
        self.currentGroup = group;
        self.messageType = messageType;
        MAXLog(@"群聊：group%lld",self.currentGroup.groupId );
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[BMXRecoderTools shareManager] stopPlayRecorder:@""];
}

#pragma mark - 初始化
- (void)viewDidLoad {
    [super viewDidLoad];
    _needAutoScrollToBottom = true;
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.account = [IMAcountInfoStorage loadObject];
    [self  getMyProfile];
    
    [self setUpNavItem];
    [self setupSubview];
    
    [self loadMessages];
    

    
    dispatch_queue_t queue = dispatch_queue_create("chatServiceDelegate",DISPATCH_QUEUE_SERIAL);
    [[[BMXClient sharedClient] chatService] addDelegate:self delegateQueue:queue];
    [[[BMXClient sharedClient] rtcService] addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    [self p_configNotification];
    [self p_configEditMessage];
    
    _typeWriterLock = [NSLock new];
    _messageHandleLock = [NSLock new];
    
}

- (void)p_configNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beginEdit) name:@"ChatTextFieldBegin" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endEdit) name:@"ChatTextFieldEnd" object:nil];
}

- (void)p_configEditMessage {
    if ([self.conversation.editMessage length] > 0) {
        self.chatBarView.textView.text = self.conversation.editMessage;
    }
}

//监听状态,处理typing状态
- (void)endEdit {
    MAXLog(@"结束编辑");
    if (self.messageType == BMXMessage_MessageType_Group) {
        return;
    }
    [self sendTypingMessage:@{@"input_status":@"nothing"}];
}

- (void)sendTypingMessage:(NSDictionary *)configdic {
    BMXMessage * msg = [BMXMessage createMessageWithFrom:[self.account.usedId longLongValue]  to:self.currentRoster.rosterId type:BMXMessage_MessageType_Single conversationId:self.currentRoster.rosterId content:@""];
    msg.extension = [NSString jsonStringWithDictionary:configdic];
    msg.deliveryQos = BMXMessage_DeliveryQos_AtMostOnce;
    [[[BMXClient sharedClient] chatService] sendMessageWithMsg:msg completion:^(BMXError *aError) {
    }];
}

- (void)beginEdit {
    MAXLog(@"正在编辑");
    if (self.messageType == BMXMessage_MessageType_Group) {
        return;
    }
    [self sendTypingMessage:@{@"input_status":@"typing"}];
}

- (void)getMyProfile {
    [[[BMXClient sharedClient] userService] getProfile:NO completion:^(BMXUserProfile *profile, BMXError *error) {
        if (!error) {
            [self getSelfAvatar:profile];
        }
    }];
}

- (void)getSelfAvatar:(BMXUserProfile *)profile {
    UIImage *avarat = [UIImage imageWithContentsOfFile:profile.avatarThumbnailPath];
    if (avarat) {
        self.selfImage  = avarat;
    }else {
        [[[BMXClient sharedClient] userService] downloadAvatarWithProfile:profile thumbnail:YES callback:^(int progress) {} completion:^(BMXError *error) {
            if (!error) {
                UIImage *image = [UIImage imageWithContentsOfFile:profile.avatarThumbnailPath];
                self.selfImage  = image;
            }
        }];
    }
}

- (void)setupSubview {
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.chatBarView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self.chatBarView action:@selector(hideKeyboard)];
    [self.tableView addGestureRecognizer:tapGesture];
    
    __weak LHChatVC *weakSelf = self;
    self.tableView.mj_header = [MJRefreshStateHeader headerWithRefreshingBlock:^{
        [weakSelf getHistoryMessage];
    }];
}

#pragma mark - public
//刷新并滑动到底部
- (void)scrollToBottomAnimated:(BOOL)animated refresh:(BOOL)refresh {
    // 表格滑动到底部
    NSInteger s = [self.tableView numberOfSections];  //有多少组
    if (s<1) return;  //无数据时不执行 要不会crash
    NSInteger r = [self.tableView numberOfRowsInSection:s-1]; //最后一组有多少行
    if (r<1) return;
    NSIndexPath *ip = [NSIndexPath indexPathForRow:r-1 inSection:s-1];  //取最后一行数据
    [self.tableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:animated]; //滚动到最后一行
}

#pragma mark - private
- (void)dealWithidTyping:(BOOL)istyping {
    MAXLog(@"对方正在输入%d", istyping);
    if (istyping == YES) {
        self.title = NSLocalizedString(@"Typing", @"对方正在输入...");
    } else {
        self.title = [self.currentRoster.nickname length] ? self.currentRoster.nickname : self.currentRoster.username;
    }
    [self setNavigationBarTitle:self.title navLeftButtonIcon:@"blackback" navRightButtonIcon:@"chatNavMore"];
    [self.navRightButton addTarget:self action:@selector(clickMoreButton) forControlEvents:UIControlEventTouchUpInside];
}

- (void)p_dropDownLoadDataWithScrollView:(UIScrollView *)scrollView {
    if ([scrollView isMemberOfClass:[UITableView class]]) {
        if (!self.isHeaderRefreshing) return;
        
        LHMessageModel *model = self.messages.firstObject;
        self.tableViewOffSetY = (self.tableView.contentSize.height - self.tableView.contentOffset.y);
        [self loadMessageWithId:model.id];
        [self.tableView reloadData];
        [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentSize.height - self.tableViewOffSetY)];
        self.headerRefreshing = NO;
    }
}

- (BOOL)isHaveExtion:(BMXMessage *)model {
    if ([model.extension length]) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)isInTyping:(BMXMessage *)message {
    NSString *extionJson = message.extension;
    NSDictionary *dic = [NSString dictionaryWithJsonString:extionJson];
    if ([dic[@"input_status"] isEqualToString:@"typing"] &&
        message.fromId == self.currentRoster.rosterId) {
        return YES;
    } else if ([dic[@"input_status"] isEqualToString:@"nothing"] ){
        return NO;
    } else {
        return NO;
    }
}

- (BOOL)isTypingMessage:(NSString *)extionJson {
    NSDictionary *dic = [NSString dictionaryWithJsonString:extionJson];
    return [dic objectForKey:@"input_status"] != nil;
}

- (void)loadMessages {
    BMXConversation *conversation;
    if (self.messageType == BMXConversation_Type_Group) {
        self.conversationId =  self.conversationId ?self.conversationId : (NSInteger)self.currentGroup.groupId;
        BMXConversation *groupConversation = [[[BMXClient sharedClient] chatService] openConversationWithConversationId:self.conversationId type:BMXConversation_Type_Group createIfNotExist:YES];
        conversation = groupConversation;
    } else {
        self.conversationId = self.conversationId ? self.conversationId: (NSInteger)self.currentRoster.rosterId;
        BMXConversation *singleConversation = [[[BMXClient sharedClient] chatService] openConversationWithConversationId:self.conversationId type:BMXConversation_Type_Single createIfNotExist:YES];
        conversation = singleConversation;
        
        UIImage *image = [UIImage imageWithContentsOfFile:self.currentRoster.avatarThumbnailPath];
        if (!image && self.currentRoster) {
            BMXErrorCode error = [[[BMXClient sharedClient] rosterService]downloadAvatarWithItem:self.currentRoster thumbnail:YES callback:^(int progress) {}];
            if (!error) {
                UIImage *image = [UIImage imageWithContentsOfFile:self.currentRoster.avatarThumbnailPath];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.deImage = image;
                });
            }
        }else {
            self.deImage = image;
        }
        
    }
    self.conversation = conversation;
    [conversation loadMessagesWithRefMsgId:0 size:10 completion:^(BMXMessageList *messageList, BMXError *error) {
        if (!error) {
            NSMutableArray *messageListms = [[NSMutableArray alloc] init];
            for (int i=0; i<messageList.size; i++){
                BMXMessage *msg = [messageList get:i];
                if (msg.contentType != BMXMessage_ContentType_RTC ||
                    [msg.config.getRTCAction isEqualToString: @"record"]) {
                    [messageListms addObject: msg];
                }
            }

            NSArray *sortedMessages =  [messageListms sortedArrayUsingComparator:^NSComparisonResult(BMXMessage *message1, BMXMessage *message2) {
                return message1.serverTimestamp < message2.serverTimestamp;
            }];
            
            [sortedMessages enumerateObjectsUsingBlock:^(BMXMessage *message, NSUInteger idx, BOOL * stop) {
                
                LHMessageModel *messageModel = [self changeUIModelWithBMXMessage:message atIndex:0];
                
                if (self.messageType == BMXMessage_MessageType_Single) {
                    [self ackMessagebyModel:messageModel];
                } else {
                    if (self.currentGroup.enableReadAck == YES) {
                        [self ackMessagebyModel:messageModel];
                    }
                }
                
                NSString *time = [LHTools dayStringWithDate:messageModel.date];
                if (![self.lastTime isEqualToString:time]) {
                    [self.dataSource insertObject:time atIndex:0];
                    self.lastTime = time;
                }
            }];
            
            [self.tableView reloadData];
            [self scrollToBottomAnimated:NO refresh:NO];
        }
    }];
}

// 挂断消息在界面展示时需要伪装成以呼叫发起者身份发出
- (BOOL)isSenderOfMessageModel: (LHMessageModel *)messageModel{
    BMXMessage *message = messageModel.messageObjc;
    NSString *fromidStr = [NSString stringWithFormat:@"%lld", message.fromId];
    //非呼叫挂断类的消息，发送者为from
    BOOL res = [fromidStr isEqualToString:self.account.usedId];
    if ([message.config.getRTCAction isEqualToString: @"hangup"]) {
        res = message.config.getRTCInitiator == [self.account.usedId longLongValue];
    }
    return res;
}

- (LHMessageModel *)changeUIModelWithBMXMessage:(BMXMessage *)message atIndex:(NSUInteger)index{
    NSString *date =  [NSString stringWithFormat:@"%lld", message.serverTimestamp];
    LHMessageModel *dbMessageModel = [[LHIMDBManager shareManager] searchModel:[LHMessageModel class] keyValues:@{@"date" : date, @"status" : @(MessageDeliveryState_Delivered)}];
    dbMessageModel.messageObjc = message;
    NSString *fromidStr = [NSString stringWithFormat:@"%lld", message.fromId];
    BOOL isFrom = [fromidStr isEqualToString:self.account.usedId];
    dbMessageModel.isSender = [self isSenderOfMessageModel:dbMessageModel];
    dbMessageModel.date = date;
    dbMessageModel.id = date;
    switch ( message.deliveryStatus) {
        case BMXMessage_DeliveryStatus_New:
            dbMessageModel.status = MessageDeliveryState_Pending;
            break;
        case BMXMessage_DeliveryStatus_Delivering:
            dbMessageModel.status = MessageDeliveryState_Delivering;
            break;
        case BMXMessage_DeliveryStatus_Deliveried:
            dbMessageModel.status = MessageDeliveryState_Delivered;
            break;
        case BMXMessage_DeliveryStatus_Failed:
            dbMessageModel.status = MessageDeliveryState_Failure;
            break;
        case BMXMessage_DeliveryStatus_Recalled:
            dbMessageModel.status = MessageDeliveryState_Pending;
            break;
            
        default:
            break;
    }
    
    if (message.contentType == BMXMessage_ContentType_Text) {
        dbMessageModel.content = message.content;
        dbMessageModel.type = MessageBodyType_Text;
        if (index == 0) {
            [self.dataSource insertObject:dbMessageModel atIndex:index];
            [self.messages insertObject:dbMessageModel atIndex:index];
        }else{
            [self.dataSource addObject:dbMessageModel];
            [self.messages addObject:dbMessageModel];
        }
    } else if (message.contentType == BMXMessage_ContentType_RTC) {
        if ([message.config.getRTCAction isEqualToString: @"record"]) {
            dbMessageModel.content = message.content;
            dbMessageModel.type = MessageBodyType_Text;
            if ([message.content isEqualToString:@"rejected"]) {
                if (!isFrom) {
                    dbMessageModel.content = NSLocalizedString(@"call_rejected", @"通话已拒绝");
                }else{
                    dbMessageModel.content = NSLocalizedString(@"call_rejected_by_callee", @"通话已被对方拒绝");
                }
            } else if ([message.content isEqualToString:@"canceled"]) {
                if (isFrom) {
                    dbMessageModel.content = NSLocalizedString(@"call_canceled", @"通话已取消");
                }else{
                    dbMessageModel.content = NSLocalizedString(@"call_canceled_by_caller", @"通话已被对方取消");
                }
            } else if ([message.content isEqualToString:@"timeout"]) {
                if (isFrom) {
                    dbMessageModel.content = NSLocalizedString(@"callee_not_responding", @"对方未应答");
                }else{
                    dbMessageModel.content = NSLocalizedString(@"call_not_responding", @"未应答");
                }
            } else if ([message.content isEqualToString:@"busy"]) {
                if (!isFrom) {
                    dbMessageModel.content = NSLocalizedString(@"call_busy", @"忙线未接听");
                }else{
                    dbMessageModel.content = NSLocalizedString(@"callee_busy", @"对方忙");
                }
            } else{
                int sec = [dbMessageModel.content intValue]/1000;
                NSString *format = dbMessageModel.messageObjc.config.isPeerDrop?
                NSLocalizedString(@"call_ended", @"通话中断：%02d:%02d"):
                NSLocalizedString(@"call_duration", @"通话时长：%02d:%02d");
                dbMessageModel.content = [NSString stringWithFormat:format, sec/60, sec%60];
            }
            if (index == 0) {
                [self.dataSource insertObject:dbMessageModel atIndex:index];
                [self.messages insertObject:dbMessageModel atIndex:index];
            }else{
                [self.dataSource addObject:dbMessageModel];
                [self.messages addObject:dbMessageModel];
            }
        }
    } else if (message.contentType == BMXMessage_ContentType_Image) {
        dbMessageModel.type = MessageBodyType_Image;
        BMXImageAttachment *imageAtt = [BMXImageAttachment dynamicCastWithAttachment:message.attachment];
        dbMessageModel.width = imageAtt.size.getMWidth;
        dbMessageModel.height = imageAtt.size.getMHeight;
        dbMessageModel.imageRemoteURL = imageAtt.thumbnailPath;
        if (index == 0) {
            [self.dataSource insertObject:dbMessageModel atIndex:index];
            [self.messages insertObject:dbMessageModel atIndex:index];
        }else{
            [self.dataSource addObject:dbMessageModel];
            [self.messages addObject:dbMessageModel];
        }

        if (![[NSFileManager defaultManager] fileExistsAtPath:dbMessageModel.imageRemoteURL]) {
            [[[BMXClient sharedClient] chatService] downloadThumbnailWithMsg:message strategy:BMXChatService_ThumbnailStrategy_ThirdpartyServerCreate completion:^(BMXError *aError) {
            }];
        }else {
            
        }
        
    } else if (message.contentType == BMXMessage_ContentType_Voice) {
        dbMessageModel.type = MessageBodyType_Voice;
        BMXVoiceAttachment *voiceAtt = [BMXVoiceAttachment dynamicCastWithAttachment:message.attachment];
        
        dbMessageModel.vociePath = voiceAtt.path;
        dbMessageModel.content = [NSString stringWithFormat:@"  %d s",voiceAtt.duration];
        if (index == 0) {
            [self.dataSource insertObject:dbMessageModel atIndex:index];
            [self.messages insertObject:dbMessageModel atIndex:index];
        }else{
            [self.dataSource addObject:dbMessageModel];
            [self.messages addObject:dbMessageModel];
        }

        if (![[NSFileManager defaultManager] fileExistsAtPath:dbMessageModel.vociePath]) {
            [[[BMXClient sharedClient] chatService] downloadAttachmentWithMsg:message completion:^(BMXError *aError) {
            }];
        }
        
    }else if (message.contentType == BMXMessage_ContentType_Location) {
        BMXLocationAttachment *locationAttach = [BMXLocationAttachment dynamicCastWithAttachment: message.attachment];
        dbMessageModel.content = [NSString stringWithFormat:NSLocalizedString(@"Current_location", @"当前位置：%@"),locationAttach.address];
        dbMessageModel.status = MessageDeliveryState_Delivered;
        dbMessageModel.type = MessageBodyType_Location;
        if (index == 0) {
            [self.dataSource insertObject:dbMessageModel atIndex:index];
            [self.messages insertObject:dbMessageModel atIndex:index];
        }else{
            [self.dataSource addObject:dbMessageModel];
            [self.messages addObject:dbMessageModel];
        }
    } else if (message.contentType == BMXMessage_ContentType_File) {
        BMXFileAttachment *fileAtt = [BMXFileAttachment dynamicCastWithAttachment: message.attachment];
        dbMessageModel.content = fileAtt.displayName ? fileAtt.displayName : @"file";
        dbMessageModel.type = MessageBodyType_File;
        if (![[NSFileManager defaultManager] fileExistsAtPath:fileAtt.path]) {
            [[[BMXClient sharedClient] chatService] downloadAttachmentWithMsg:message completion:^(BMXError *aError) {
            }];
        }
        if (index == 0) {
            [self.dataSource insertObject:dbMessageModel atIndex:index];
            [self.messages insertObject:dbMessageModel atIndex:index];
        }else{
            [self.dataSource addObject:dbMessageModel];
            [self.messages addObject:dbMessageModel];
        }
    } else if (message.contentType == BMXMessage_ContentType_Video) {
        BMXVideoAttachment *videoAtt = [BMXVideoAttachment dynamicCastWithAttachment: message.attachment];
        dbMessageModel.content = videoAtt.displayName ? videoAtt.displayName : @"video";
        dbMessageModel.type = MessageBodyType_Video;
        
        dbMessageModel.width = videoAtt.size.getMWidth;
        dbMessageModel.height = videoAtt.size.getMHeight;
        dbMessageModel.imageRemoteURL = videoAtt.thumbnailPath;
        dbMessageModel.videoPath = videoAtt.path;

        if (![[NSFileManager defaultManager] fileExistsAtPath:dbMessageModel.imageRemoteURL]) {
            [[[BMXClient sharedClient] chatService] downloadThumbnailWithMsg:message strategy:BMXChatService_ThumbnailStrategy_ThirdpartyServerCreate completion:^(BMXError *aError) {
            }];
            
        }else {
//            MAXLog(@"存在");
        }
        
        if (index == 0) {
            [self.dataSource insertObject:dbMessageModel atIndex:index];
            [self.messages insertObject:dbMessageModel atIndex:index];
        }else{
            [self.dataSource addObject:dbMessageModel];
            [self.messages addObject:dbMessageModel];
        }
    }
    return dbMessageModel;
}

- (void)loadMessageWithId:(NSString *)Id {
    NSArray *messages = [[LHIMDBManager shareManager] searchModelArr:[LHMessageModel class] byKey:Id];
    self.meetRefresh = messages.count == kMessageCount;
    [messages enumerateObjectsUsingBlock:^(LHMessageModel *messageModel, NSUInteger idx, BOOL * stop) {
        messageModel.date = [NSString stringWithFormat:@"%f",messageModel.messageObjc.serverTimestamp * 0.001];
        NSString *time = [LHTools dayStringWithDate:messageModel.date];
        
        if (![self.lastTime isEqualToString:time]) {
            [self.dataSource insertObject:time atIndex:0];
            self.lastTime = time;
        }
    }];
    
    NSUInteger index = self.lastTime ? [self.dataSource indexOfObject:self.lastTime] : 0;
    if (index) {
        [self.dataSource removeObjectAtIndex:index];
        [self.dataSource insertObject:self.lastTime atIndex:0];
    }
}

- (NSIndexPath *)insertNewMessageOrTime:(id)NewMessage {
    __block NSIndexPath *index;
    if ([NSThread isMainThread]) {
        index = [self insertNewMessageOrTimeImpl:NewMessage];
    }else{
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        dispatch_async(dispatch_get_main_queue(), ^{
            index = [self insertNewMessageOrTimeImpl:NewMessage];
            dispatch_semaphore_signal(semaphore);
        });
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }
    return index;
}

- (NSIndexPath *)insertNewMessageOrTimeImpl:(id)NewMessage {
    NSIndexPath *index = [NSIndexPath indexPathForRow:self.dataSource.count inSection:0];
    [self.dataSource addObject:NewMessage];
    if([NewMessage class] != [NSString class]){
        [self.messages addObject:NewMessage];
    }
    [self.tableView insertRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationNone];
    return index;
}

- (void)sendMessage:(LHContentModel *)content {
    if (content.words && content.words.length) {
        // 文字类型
        [self p_configsendMessage:content.words type:MessageBodyType_Text duartion:0];
    }
    if (!content.photos && !content.photos.photos.count) return;
    // 图片类型
    [content.photos.photos enumerateObjectsUsingBlock:^(UIImage *image, NSUInteger idx, BOOL * stop) {
        [self p_configsendMessage:image type:MessageBodyType_Image duartion:0];
    }];
}

#pragma mark - 事件监听
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:kTableViewFrame]) {
        UITableView *tableView = (UITableView *)object;
        CGRect newValue = [change[NSKeyValueChangeNewKey] CGRectValue];
        CGRect oldValue = [change[NSKeyValueChangeOldKey] CGRectValue];
        if (newValue.size.height != oldValue.size.height &&
            tableView.contentSize.height > newValue.size.height) {
            [tableView setContentOffset:CGPointMake(0, tableView.contentSize.height - newValue.size.height) animated:NO];
        }
        return;
    }
    
    CGPoint newValue = [change[NSKeyValueChangeNewKey] CGPointValue];
    if (!self.headerRefreshing) self.headerRefreshing = newValue.y < 40 && self.isMeetRefresh;
}

- (void)showWebViewWithUrl: (NSString*)target {
    @try{
        NSURL *url = [NSURL URLWithString:target];
        SFSafariViewController *safariViewController = [[SFSafariViewController alloc] initWithURL:url];
        safariViewController.delegate = self;
        [self presentViewController:safariViewController animated:YES completion:nil];
    }@catch (NSException *exception) {
        MAXLog(@"%@",exception.description);
    }
}

#pragma mark  cell事件处理
- (void)routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo {
    LHMessageModel *model = [userInfo objectForKey:kMessageKey];

    if ([eventName isEqualToString:kRouterEventLongPressName]) {
        [self chatBubbleLongPressed:model ges:[userInfo objectForKey:@"ges"]];
    } else if ([eventName isEqualToString:kRouterEventImageBubbleTapEventName]) {
        //点击图片
        [self chatImageCellBubblePressed:model];
    }else if ([eventName isEqualToString:kRouterEventVoiceBubbleTapEventName]) {
        [self chatVoiceCellBubblePressed:model lable:[userInfo objectForKey:@"audio"]];
    }else if([eventName isEqualToString:kRouterEventFileBubbleTapEventName]){
        [self chatFileCellBubblePressed:model];
    }else if ([eventName isEqualToString:GXRouterEventVideoRecordExit]) {
        [self resignFirstResponder];
    } else if ([eventName isEqualToString:GXRouterEventVideoRecordFinish]) {
        NSString *videoPath = userInfo[VideoPathKey];
        [self p_configVideoMessageWithpath:videoPath];
        [self.videoView removeFromSuperview]; // 移除video视图
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[VideoManager shareManager] exit];  // 防止内存泄露
        });
        MAXLog(@"发送小视频");
    } else if ([eventName isEqualToString:kRouterEventVideoBubbleTapEventName]) {
        MAXLog(@"点击播放小视频");
        [self chatVideoCellBubblePressed:model];
    } else if ([eventName isEqualToString:kRouterEventChatReadStatusLabelTapEventName]) {
        MAXLog(@"跳转已读列表");
        GroupAlreadyReadListViewController *vc = [[GroupAlreadyReadListViewController alloc] initWithMessage:model.messageObjc group:self.currentGroup];
        [self.navigationController pushViewController:vc animated:YES];
    } else if ([eventName isEqualToString:kRouterEventTextURLTapEventName]) {
        MAXLog(@"点击文本中超链接");
        NSString *url = userInfo[@"url"];
        [self showWebViewWithUrl:url];
    }
}

- (void)p_configVideoMessageWithpath:(NSString *)path {
    
    MAXLog(@"%@", path);
    int dur =  [[VideoManager shareManager] getVideoTimeByUrlString:path];
    UIImage *image = [[VideoManager shareManager] getVideoPreViewImage:[NSURL fileURLWithPath:path]];
    NSData *thumbNailData = UIImageJPEGRepresentation(image,1.0f);//第二个参数为压缩倍数
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSDictionary *dic = @{@"videodata" : data,
                          @"thumbnaildata" : thumbNailData,
                          @"thumbImage":image};

    [self p_configsendMessage:dic type:MessageBodyType_Video duartion:dur];
}

-(void)clickMoreButton {


    switch (self.messageType) {
        case BMXMessage_MessageType_Group:
            if(self.currentGroup != nil) {
                if (self.currentGroup.groupStatus
                    == BMXGroup_GroupStatus_Normal) {
                    GroupDetailViewController* ctrl = [[GroupDetailViewController alloc] initWithGroup:self.currentGroup];
                    ctrl.conversation = self.conversation;
                    [self.navigationController pushViewController:ctrl animated:YES];
                } else {
                    [HQCustomToast showDialog:NSLocalizedString(@"This_group_has_been_dismissed", @"该群已解散")];
                }
            }
            break;
        case BMXMessage_MessageType_Single:
            if(self.currentRoster != nil) {
                ChatRosterProfileViewController* vc = [[ChatRosterProfileViewController alloc] initWithRoster:self.currentRoster];
                [self.navigationController pushViewController:vc animated:YES];


//                [self testCommon];
            }
            break;
        default:
            break;
    }
}


//#pragma warning - test
//- (void)testCommon {
//
//    BMXMessageObject *commondmessage = [[BMXMessageObject alloc] initWithBMXCommandMessageText:@"commond" fromId:[self.account.usedId longLongValue ] toId:self.currentRoster.rosterId type:BMXMessageTypeSingle conversationId:self.currentRoster.rosterId];
//
//    [[[BMXClient sharedClient] chatService] sendMessage:commondmessage];
//
//}

#pragma mark - Event
- (void)returnButtonClick {
    MAXLog(@"点击了返回");
    [self.navigationController popViewControllerAnimated:YES];
    //    weakSelf.editContent = content.words;
    
    if (self.chatBarView.textView.text && [self.chatBarView.textView.text  length]) {
        self.conversation.editMessage = self.chatBarView.textView.text;
    } else {
        self.conversation.editMessage = @"";
    }
    if (self.delegate &&  [self.delegate respondsToSelector:@selector(chatVCDidSelectReturnButton)]) {
        [self.delegate chatVCDidSelectReturnButton];
    }
}

#pragma mark - Event BubbleItem
// 复制
- (void)copyMessage {
    UIPasteboard *pasteboard  = [UIPasteboard generalPasteboard];
    pasteboard.string         = self.currentMessage.messageObjc.content;
    [[UIMenuController sharedMenuController] setMenuItems:@[]];
}

// 转发
- (void)forwardMessage{
    //响应事件
    TransterViewController *vc = [[TransterViewController alloc] init];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
    [[UIMenuController sharedMenuController] setMenuItems:@[]];
}

// 撤回
- (void)recallMessage {
    [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
    [[[BMXClient sharedClient] chatService] recallMessageWithMsg: self.currentMessage.messageObjc completion:^(BMXError *aError) {
        [self.recallMessages addObject:self.currentMessage];
        self.currentMessage = nil;
        [[UIMenuController sharedMenuController] setMenuItems:@[]];
    }];
}

// 设置未读
- (void)setUnread {
    [[[BMXClient sharedClient] chatService] readCancelWithMsg: self.currentMessage.messageObjc completion:^(BMXError *aError) {
        [[UIMenuController sharedMenuController] setMenuItems:@[]];
    }];
}

// 删除消息
- (void)deleteMessage {
    [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
    [[[BMXClient sharedClient] chatService] removeMessageWithMsg:self.currentMessage.messageObjc synchronize:YES completion:^(BMXError *aError) {
        [[UIMenuController sharedMenuController] setMenuItems:@[]];

        if(self.currentMessage.messageObjc) {
            NSInteger index = -1;
            if ([self.dataSource containsObject:self.currentMessage]) {
                index = [self.dataSource indexOfObject:self.currentMessage];
                [self.dataSource removeObject:self.currentMessage];
            }
            if ([self.messages containsObject:self.currentMessage]) {
                [self.messages removeObject:self.currentMessage];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
            MAXLog(@"删除");
        }
        
        self.currentMessage = nil;
    }];
}

#pragma mark - Delegate BMXRecoderToolsProtocol
- (void)audioPlayerDidFinishPlaying {
    if (self.curVoiceIndexPath) {
        LHChatViewCell *cell = [self.tableView cellForRowAtIndexPath:self.curVoiceIndexPath];
        LHChatAudioBubbleView *bubbleView =  (LHChatAudioBubbleView *)cell.bubbleView;
        [bubbleView.voiceIcon stopAnimating];
        self.curVoiceIndexPath = nil;
    }
}

#pragma mark - Delegate LocationDelegate
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [HQCustomToast hideWating];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Alert", @"提示") message:NSLocalizedString(@"location_service_need_to_turn_it_on", @"您还未开启定位服务，是否需要开启？") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"取消") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    UIAlertAction *queren = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", @"确定") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSURL *setingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication]openURL:setingsURL];
    }];
    [alert addAction:cancel];
    [alert addAction:queren];
    [self.navigationController presentViewController:alert animated:YES completion:nil];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    [HQCustomToast hideWating];
    [self.locationManager stopUpdatingLocation];//停止定位
    //地理反编码
    CLLocation *currentLocation = [locations lastObject];
    CLGeocoder *geoCoder = [[CLGeocoder alloc]init];
    
    CLLocation *newLocation = locations[0];
    CLLocationCoordinate2D oldCoordinate = newLocation.coordinate;
    MAXLog(@"旧的经度：%f,旧的纬度：%f",oldCoordinate.longitude,oldCoordinate.latitude);
    
    NSString *longt = [NSString stringWithFormat:@"%f", oldCoordinate.longitude];
    NSString *lait = [NSString stringWithFormat:@"%f", oldCoordinate.latitude];
    
    //当系统设置为其他语言时，可利用此方法获得中文地理名称
    NSMutableArray
    *userDefaultLanguages = [[NSUserDefaults standardUserDefaults]objectForKey:@"AppleLanguages"];
    // 强制 成 简体中文
    [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObjects:@"zh-hans", nil]forKey:@"AppleLanguages"];
    [geoCoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (placemarks.count > 0) {
            CLPlacemark *placeMark = placemarks[0];
            NSString *city = placeMark.locality;
            if (!city) {
                self.currentCity = NSLocalizedString(@"Failed_to_locate_click_to_retry", @"⟳定位获取失败,点击重试");
            } else {
                self.currentCity = placeMark.locality ;//获取当前城市
                
            }
            
            NSString *addr = [NSString stringWithFormat:@"%@%@%@", placeMark.subLocality,placeMark.thoroughfare,placeMark.name];
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Confirm_to_send", @"确定发送？") message:addr preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"取消") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            }];
            UIAlertAction *queren = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", @"确定") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                           [self p_configsendMessage:@{@"latitude" : lait, @"longitude" :longt, @"address" : addr } type:MessageBodyType_Location duartion:0];

            }];
            [alert addAction:cancel];
            [alert addAction:queren];
            [self.navigationController presentViewController:alert animated:YES completion:nil];
            
            
            
            
            
        } else if (error == nil && placemarks.count == 0 ) {
        } else if (error) {
            self.currentCity = NSLocalizedString(@"Failed_to_locate_click_to_retry", @"⟳定位获取失败,点击重试");
            [HQCustomToast showDialog:self.currentCity];
        }
        // 还原Device 的语言
        [[NSUserDefaults
          standardUserDefaults] setObject:userDefaultLanguages
         forKey:@"AppleLanguages"];
    }];
}



#pragma mark - Delegate TransterMessageVC
- (void)transterSlectedRoster:(BMXRosterItem *)roster {
    [self groupOwnerTransterVCdidSelect:roster];
}

- (void)transterSlectedGroup:(BMXGroup *)group {
    BMXMessage *m = [BMXMessage createForwardMessageWithMsg:self.currentMessage.messageObjc from:[self.account.usedId longLongValue] to:group.groupId type:BMXMessage_MessageType_Group conversationId:group.groupId];
    [[[BMXClient sharedClient] chatService] forwardMessageWithMsg:m completion:^(BMXError *aError) {
    }];
}

- (void)groupOwnerTransterVCdidSelect:(id)toModel {
    BMXRosterItem *roster = toModel;
    BMXMessage *m = [BMXMessage createForwardMessageWithMsg:self.currentMessage.messageObjc from:[self.account.usedId longLongValue] to:roster.rosterId type:BMXMessage_MessageType_Single conversationId:roster.rosterId];
//    m.enableGroupAck = YES;
    [[[BMXClient sharedClient] chatService] forwardMessageWithMsg:m completion:^(BMXError *aError) {
    }];
}

// video的bubble被点击
- (void)chatVideoCellBubblePressed:(LHMessageModel *)model {
    BOOL isNull = [model.videoPath isKindOfClass:[NSNull class]];
    BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:model.videoPath];
    if (model.videoPath && !isNull && exist) {
        [self videoPlay:model.videoPath];
    } else {
        [[[BMXClient sharedClient] chatService] downloadAttachmentWithMsg:model.messageObjc completion:^(BMXError *aError) {
        }];
    }
}

- (void)videoPlay:(NSString *)path {
    ICAVPlayer *player = [[ICAVPlayer alloc] initWithPlayerURL:[NSURL fileURLWithPath:path isDirectory:YES]];
    UIWindow *keyWindow = [UIApplication sharedApplication].delegate.window;
    [player presentFromVideoView:self.view toContainer:keyWindow animated:YES completion:nil];
}

// 图片的bubble被点击
- (void)chatImageCellBubblePressed:(LHMessageModel *)model{
    LHPhotoPreviewController *photoPreview= [[LHPhotoPreviewController alloc]init];
    photoPreview.models = @[model];
    self.browserAnimateDelegate.delegate = self;
    self.browserAnimateDelegate.index = 0;
    self.browserAnimateDelegate.im = YES;
    photoPreview.transitioningDelegate = self.browserAnimateDelegate;
    photoPreview.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:photoPreview animated:YES completion:nil];
    
}

// 语音cell被点击
- (void)chatVoiceCellBubblePressed:(LHMessageModel *)model lable:(NSString *)label {
    if (self.curVoiceIndexPath) {
        LHChatViewCell *cell = [self.tableView cellForRowAtIndexPath:self.curVoiceIndexPath];
        LHChatAudioBubbleView *bubbleView =  (LHChatAudioBubbleView *)cell.bubbleView;
        [bubbleView.voiceIcon stopAnimating];
    }
    [[BMXRecoderTools shareManager] addRecoderDelegate:self];
    [[BMXRecoderTools shareManager] startPlayRecorder:model.vociePath];
    
    LHChatViewCell *cell = [self.tableView cellForRowAtIndexPath:model.indexPath];
    LHChatAudioBubbleView *bubbleView =  (LHChatAudioBubbleView *)cell.bubbleView;
    [bubbleView.voiceIcon startAnimating];
    self.curVoiceIndexPath = model.indexPath;
    
}

- (void)chatFileCellBubblePressed:(LHMessageModel *)model {
    NSLog(@"查看文件");
    BMXFileAttachment *fileAtt = [BMXFileAttachment dynamicCastWithAttachment: model.messageObjc.attachment];
    
    if (fileAtt.path) {
        self.documentIntertactionController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:fileAtt.path]];
        self.documentIntertactionController.delegate = self;
        [self p_presentUIDocument];
    }
}

- (void)p_presentUIDocument{
    [self.documentIntertactionController presentPreviewAnimated:YES];
}

- (void)chatBubbleLongPressedfachu:(LHMessageModel *)message {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Action", @"操作") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* action1 = [UIAlertAction actionWithTitle:NSLocalizedString(@"Forward", @"转发") style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action) {
                                                        //响应事件
                                                        TransterViewController *vc = [[TransterViewController alloc] init];
                                                        vc.delegate = self;
                                                        [self.navigationController pushViewController:vc animated:YES];
                                                        
                                                        self.currentMessage = message;
                                                        //
                                                        
                                                    }];
    UIAlertAction* action2 = [UIAlertAction actionWithTitle:NSLocalizedString(@"Set_to_unread", @"设置为未读") style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action) {
                                                        if (message.messageObjc) {
                                                            //
                                                            [[[BMXClient sharedClient] chatService] readCancelWithMsg:message.messageObjc completion:^(BMXError *aError) {
                                                            }];
                                                        }
                                                        
                                                    }];
    
    [alert addAction:action1];
    [alert addAction:action2];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"取消") style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
    
   

}

//#warning -test
//- (void)test:(BMXMessageObject *)msg {
//    [self.conversation updateMessageExtension:msg completion:^(BMXError * _Nonnull error) {
//        if (!error) {
//            MAXLog(@"更新成功");
//        }
//
//    }];
//}


- (void)chatBubbleLongPressed:(LHMessageModel *)message
                          ges:(UILongPressGestureRecognizer*)ges {
    
    
//    message.messageObjc.extensionJson = @"rehh";
//    [self test:message.messageObjc];
    
    NSString *date = [NSString stringWithFormat:@"%@",  message.date];
    __block LHChatViewCell *messagecell;
    NSArray *cells = [self.tableView visibleCells];
    [cells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[LHChatViewCell class]]) {
            LHChatViewCell *cell = (LHChatViewCell *)obj;
            if ([cell.messageModel.date isEqualToString:date]) {
                messagecell = cell;
                *stop = YES;
            }
        }
    }];
    if (messagecell) {
        CGPoint location       = [ges locationInView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
        _longIndexPath         = indexPath;
        [messagecell becomeFirstResponder];
        [self p_showMenuViewController:messagecell.bubbleView andIndexPath:indexPath message:message];
    }
    
}

- (void)p_showMenuViewController:(UIView *)showInView
                    andIndexPath:(NSIndexPath *)indexPath
                         message:(LHMessageModel *)messageModel {
    self.currentMessage = messageModel;
    
    if (messageModel.type == MessageBodyType_Text) {
        if (_copyMenuItem == nil) {
            _copyMenuItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Copy", @"复制") action:@selector(copyMessage)];
        }
    }
    
    if (_forwardMenuItem == nil) {
        _forwardMenuItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Forward", @"转发") action:@selector(forwardMessage)];
    }
    
    
    if (_deleteMenuItem == nil) {
        _deleteMenuItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Delete", @"删除") action:@selector(deleteMessage)];
    }
    
    if (messageModel.isSender) {
        
        if (_recallMenuItem == nil) {
            _recallMenuItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Recall", @"撤回") action:@selector(recallMessage)];
        }
        
        if (messageModel.type == MessageBodyType_Text) {
            [[UIMenuController sharedMenuController] setMenuItems:@[_copyMenuItem,_forwardMenuItem,_recallMenuItem,_deleteMenuItem]];
            
        } else {
            [[UIMenuController sharedMenuController] setMenuItems:@[_forwardMenuItem,_recallMenuItem,_deleteMenuItem]];
            
        }
        [[UIMenuController sharedMenuController] menuItems];
        
    } else {
        if (_unreadMenuItem == nil) {
            _unreadMenuItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Set_unread", @"设置未读") action:@selector(setUnread)];
        }
        if (messageModel.type == MessageBodyType_Text) {
            [[UIMenuController sharedMenuController] setMenuItems:@[_copyMenuItem,_forwardMenuItem,_unreadMenuItem,_deleteMenuItem]];
        } else {
            [[UIMenuController sharedMenuController] setMenuItems:@[_forwardMenuItem,_unreadMenuItem,_deleteMenuItem]];
        }
        
    }
    
    
    [[UIMenuController sharedMenuController] setTargetRect:showInView.frame inView:showInView.superview];
    if (![[UIMenuController sharedMenuController] isMenuVisible]) {
        UIWindow *window = [[UIApplication sharedApplication].delegate window];
        if ([window isKeyWindow] == NO) {
            [window becomeKeyWindow];
            [window makeKeyAndVisible];
        }
        [[UIMenuController sharedMenuController] setMenuVisible:YES animated:YES];
    }
}


#pragma mark - Delegate UIDocumentInteractionControllerDelegate
// 预览的时候需要加上系统的代理方法
- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller{
    return self;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id obj = [self.dataSource objectAtIndex:indexPath.row];
    
    if ([obj isKindOfClass:[NSString class]]) {
        LHChatTimeCell *timeCell = (LHChatTimeCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([LHChatTimeCell class])];
        if (!timeCell) {
            timeCell = [[LHChatTimeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([LHChatTimeCell class])];
        }
        timeCell.timeLable.text = (NSString *)obj;
        return timeCell;
    }
    
    LHMessageModel *messageModel = (LHMessageModel *)obj;
    NSString *cellIdentifier = [LHChatViewCell cellIdentifierForMessageModel:messageModel];
    messageModel.indexPath = indexPath;
    LHChatViewCell *messageCell = (LHChatViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!messageCell) {
        messageCell = [[LHChatViewCell alloc] initWithMessageModel:messageModel reuseIdentifier:cellIdentifier];
    }
    
    long long callerId = messageModel.messageObjc.fromId;
    BMXMessage *message = messageModel.messageObjc;
    if (message.contentType == BMXMessage_ContentType_RTC) {
        if ([message.config.getRTCAction isEqualToString: @"hangup"]) {
            callerId = messageModel.messageObjc.config.getRTCInitiator;
            messageModel.isSender = [self isSenderOfMessageModel:messageModel];
        }
    }

    if (messageModel.isSender) {
        if (![self.deliveringMsgClientIds containsObject:[NSNumber numberWithLong:(long)messageModel.clientMsgId]]){
            messageCell.messageModel.status = MessageDeliveryState_Delivered;
        }
        if (self.messageType == BMXMessage_MessageType_Single) {
            // 配置是否已读
            if (messageModel.messageObjc.isReadAcked == YES) {
                messageCell.readStatusLabel.text = NSLocalizedString(@"Read", @"已读");
            } else {
                messageCell.readStatusLabel.text = NSLocalizedString(@"Unread", @"未读");
            }
        } else {
            messageCell.readStatusLabel.text = [NSString stringWithFormat:NSLocalizedString(@"npersons_have_read", @"%d人已读"), messageModel.messageObjc.groupAckCount];
        }
        [messageCell setAvaratImage:self.selfImage];
    }else{
        __weak  LHChatViewCell *weakCell = messageCell;
        [[[BMXClient sharedClient] rosterService] searchWithRosterId:callerId forceRefresh:NO completion:^(BMXRosterItem *roster, BMXError *error) {
            if (!error && roster) {
                
                if ([[NSFileManager defaultManager] fileExistsAtPath:roster.avatarThumbnailPath]) {
                    UIImage *avarat = [UIImage imageWithContentsOfFile:roster.avatarThumbnailPath];
                    [weakCell setAvaratImage:avarat];
                }else {
                    
                    [[[BMXClient sharedClient] rosterService] downloadAvatarWithItem:roster thumbnail:YES callback:^(int progress) {
                        
                    } completion:^(BMXError *error) {
                        if (!error) {
                            UIImage *avarat = [UIImage imageWithContentsOfFile:roster.avatarThumbnailPath];
                            [weakCell setAvaratImage:avarat];
                        }else {
                            [weakCell setAvaratImage:nil];
                        }
                    }];
                }
            }
        }];
    }
    
    if (self.messageType == BMXMessage_MessageType_Group) {
        
        messageModel.isChatGroup = YES;
        
        __weak  LHChatViewCell *weakCell = messageCell;
        [[[BMXClient sharedClient] rosterService] searchWithRosterId:messageModel.messageObjc.fromId forceRefresh:NO completion:^(BMXRosterItem *item, BMXError *error) {
            if (!error) {
                messageModel.nickName = [item.nickname length] ? item.nickname : item.username;
                [weakCell setMessageName:messageModel.nickName];
            }
        }];
    } else {
        messageModel.isChatGroup = NO;
    }
    if (messageModel.content){
        [[TextLayoutCache sharedInstance] layoutForKey:messageModel.content];
    }
    messageCell.messageModel = messageModel;
    return messageCell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSObject *obj = [self.dataSource objectAtIndex:indexPath.row];
    if ([obj isKindOfClass:[NSString class]]) {
        return 31;
    } else {
        LHMessageModel *model = (LHMessageModel *)obj;
        CGFloat height = [LHChatViewCell tableView:tableView heightForRowAtIndexPath:indexPath withObject:model];
        return height;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.isMeetRefresh) {
        return 40;
    }
    return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (!self.isMeetRefresh) return nil;
    UIView *refreshView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MAXScreenW, 40)];
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((MAXScreenW - 15) * 0.5, (20 - 15) * 0.5, 15, 15)];
    activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [activityIndicatorView startAnimating];
    [refreshView addSubview:activityIndicatorView];
    return refreshView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    MAXLog(@" scrollViewDidEndDecelerating == %.2f", scrollView.contentOffset.y);
    [self p_dropDownLoadDataWithScrollView:scrollView];
    
    if (self.messageType == BMXMessage_MessageType_Group) {
        return;
    }
    // 屏幕内标记为已读
    NSArray *array = [self.tableView visibleCells];
    NSMutableArray *messageModelList = [NSMutableArray array];
    for (UITableViewCell *cell in array) {
        if ([cell isKindOfClass:[LHChatViewCell class]]) {
            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
            if (self.dataSource.count > 0) {
                LHMessageModel *model = self.dataSource[indexPath.row];
                if (model != nil) {
                    [messageModelList addObject:model];
                }
            }
        }
    }
    if (self.messageType == BMXMessage_MessageType_Single) {
        [self ackMessage:messageModelList];
    } else {
        if (self.currentGroup.enableReadAck == YES) {
            [self ackMessage:messageModelList];
        }
    }
}

- (void)ackMessage:(NSArray<LHMessageModel *> *)modelArray {
    for (LHMessageModel *model in modelArray) {
        if ([model.class isKindOfClass:[LHMessageModel class]]) {
            continue;
        }
        if (!model.isSender && model.messageObjc.isReadAcked == NO) {
            [[[BMXClient sharedClient] chatService] ackMessageWithMsg:model.messageObjc completion:^(BMXError *aError) {
            }];
        }
    }
}

- (void)ackMessagebyModel:(LHMessageModel *)model {
    if (!model.isSender == YES && model.messageObjc.isReadAcked == NO) {
        [[[BMXClient sharedClient] chatService] ackMessageWithMsg:model.messageObjc completion:^(BMXError *aError) {
        }];
    }
}

- (void)ackMessagebyMessageObject:(BMXMessage *)messageObject {
    NSString *fromIdStr = [NSString stringWithFormat:@"%lld", messageObject.fromId];
    if (![fromIdStr isEqualToString:self.account.usedId] && messageObject.isRead == NO) {
        [[[BMXClient sharedClient] chatService] ackMessageWithMsg:messageObject completion:^(BMXError *aError) {
        }];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (decelerate == NO) {
        MAXLog(@"scrollView停止滚动，完全静止");
        [self p_dropDownLoadDataWithScrollView:scrollView];
    } else {
        MAXLog(@"用户停止拖拽，但是scrollView由于惯性，会继续滚动，并且减速");
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    //打开会话后一旦用户拖动了画面，则无须再自动滚屏到最新消息
    _needAutoScrollToBottom = false;
    [self.chatBarView hideKeyboard];
}

#pragma mark - XSBrowserDelegate
/** 获取一个和被点击cell一模一样的UIImageView */
- (UIImageView *)XSBrowserDelegate:(XSBrowserAnimateDelegate *)browserDelegate imageViewForRowAtIndex:(NSInteger)index {
    NSArray *cells = [self.tableView visibleCells];
    __block UIImageView *imageView = nil;
    [cells enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[LHChatViewCell class]]) {
            LHChatViewCell *cell = (LHChatViewCell *)obj;
            if (cell.messageModel.type == MessageBodyType_Image) {
                LHChatImageBubbleView *imageBubbleView = (LHChatImageBubbleView *)cell.bubbleView;
                if ([cell.messageModel.date isEqualToString:_imageKeys[index]]) {
                    imageView = [[UIImageView alloc] initWithImage:imageBubbleView.imageView.image];
                    imageView.frame = imageBubbleView.imageView.frame;
                    *stop = YES;
                }
            }
        }
    }];
    return imageView;
}

/** 获取被点击cell相对于keywindow的frame */
- (CGRect)XSBrowserDelegate:(XSBrowserAnimateDelegate *)browserDelegate fromRectForRowAtIndex:(NSInteger)index {
    NSArray *cells = [self.tableView visibleCells];
    __block LHChatImageBubbleView *currentImageBubbleView;
    __block UIImageView *imageView = nil;
    [cells enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[LHChatViewCell class]]) {
            LHChatViewCell *cell = (LHChatViewCell *)obj;
            if (cell.messageModel.type == MessageBodyType_Image) {
                LHChatImageBubbleView *imageBubbleView = (LHChatImageBubbleView *)cell.bubbleView;
                if ([cell.messageModel.date isEqualToString:_imageKeys[index]]) {
                    imageView = imageBubbleView.imageView;
                    currentImageBubbleView = imageBubbleView;
                    *stop = YES;
                }
            }
        }
    }];
    if (imageView) {
        return [currentImageBubbleView convertRect:imageView.frame toView:[UIApplication sharedApplication].keyWindow];
    } else return CGRectZero;
}

/** 获取被点击cell中的图片, 将来在图片浏览器中显示的尺寸 */
- (CGRect)XSBrowserDelegate:(XSBrowserAnimateDelegate *)browserDelegate toRectForRowAtIndex:(NSInteger)index {
    return CGRectMake(0, 0, MAXScreenW, MAXScreenH);
}

/** 是否在可视区域 */
- (BOOL)XSBrowserDelegate:(XSBrowserAnimateDelegate *)browserDelegate isVisibleForRowAtIndex:(NSInteger)index {
    
    MAXLog(@"是否在可视区域");
    NSArray *cells = [self.tableView visibleCells];
    __block BOOL isVisual = YES;
    [cells enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[LHChatViewCell class]]) {
            LHChatViewCell *cell = (LHChatViewCell *)obj;
            if (cell.messageModel.type == MessageBodyType_Image) {
                if ([cell.messageModel.date isEqualToString:_imageKeys[index]]) {
                    isVisual = NO;
                    *stop = YES;
                }
            }
        }
    }];
    return isVisual;
}

#pragma mark - manager
- (void)getHistoryMessage {
    BMXMessage *firstMessage;
    for (int i = 0; i < self.dataSource.count;i++) {
        LHMessageModel *messageModel = self.dataSource[i];
        if ([messageModel isKindOfClass:[LHMessageModel class]]) {
            firstMessage = messageModel.messageObjc;
            break;
        }
    }
    long long firstMessageId = firstMessage? firstMessage.msgId : 0;
    
    [[[BMXClient sharedClient] chatService] retrieveHistoryMessagesWithConversation:self.conversation refMsgId:firstMessageId size:10 completion:^(BMXMessageList *messageList, BMXError *error) {
        MAXLog(@"retrieveHistoryBMXconversation:%lu", (unsigned long)messageList.size);
        NSMutableArray *messageListms = [[NSMutableArray alloc] init];
        for (int i=0; i<messageList.size; i++){
            BMXMessage *message = [messageList get:i];
            if (message.contentType != BMXMessage_ContentType_RTC ||
                [message.config.getRTCAction isEqualToString: @"record"]) {
                [messageListms addObject:message];
            }
        }

        NSArray *sortedMessages =  [messageListms sortedArrayUsingComparator:^NSComparisonResult(BMXMessage *message1, BMXMessage *message2) {
            return message1.serverTimestamp < message2.serverTimestamp;
        }];
        
        [sortedMessages enumerateObjectsUsingBlock:^(BMXMessage *message, NSUInteger idx, BOOL * stop) {
            if ([message.extension isEqualToString:@"istyping"] || [message.extension isEqualToString:@"endtyping"] ) {
                [self dealWithidTyping:message];
                
            }else {
                
                LHMessageModel *messageModel = [self changeUIModelWithBMXMessage:message atIndex:0];
                NSString *time = [LHTools dayStringWithDate:messageModel.date];
                if (![self.lastTime isEqualToString:time]) {
                    [self.dataSource insertObject:time atIndex:0];
                    self.lastTime = time;
                }
            }
        }];
        [self.tableView.mj_header endRefreshing];
        [self.tableView reloadData];
    }];
}

- (void)messageCellUpdateWithIndex:(NSInteger)index message:(BMXMessage*)message model:(LHMessageModel *)viewmodel{
    __block LHChatViewCell *messageCell = (LHChatViewCell *) [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    if (messageCell == nil) {
        NSArray *cells = [self.tableView visibleCells];
        [cells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[LHChatViewCell class]]) {
                LHChatViewCell *cell = (LHChatViewCell *)obj;
                if (cell.messageModel.clientMsgId == message.clientMsgId) {
                    messageCell = cell;
                    *stop = YES;
                }
            }
        }];

    }
    viewmodel.messageObjc.deliveryStatus = message.deliveryStatus;

    switch ( message.deliveryStatus) {
        case BMXMessage_DeliveryStatus_New:
            messageCell.messageModel.status = MessageDeliveryState_Pending;
            break;
        case BMXMessage_DeliveryStatus_Delivering:
            messageCell.messageModel.status = MessageDeliveryState_Delivering;
            break;
        case BMXMessage_DeliveryStatus_Deliveried:
            messageCell.messageModel.status = MessageDeliveryState_Delivered;
            break;
        case BMXMessage_DeliveryStatus_Failed:
            messageCell.messageModel.status = MessageDeliveryState_Failure;
            break;
        case BMXMessage_DeliveryStatus_Recalled:
            messageCell.messageModel.status = MessageDeliveryState_Pending;
            break;

        default:
            break;
    }
    
    [messageCell layoutSubviews];

}

#pragma mark - listener
//  消息状态发生变化
- (void)messageStatusChanged:(BMXMessage *)message error:(BMXError *)error {
    if (error) {
        [HQCustomToast showDialog:[error description]];
    }
    MAXLog(@"message content:%@", message.content);
    if ([self isHaveExtion:message]) {
        //如果是扩展信息（现在的扩展信息，是不展示消息，）所以return不做UI处理
        return;
    } else {
        MAXLogDebug(@"Message have no ext");
        [self.deliveringMsgClientIds removeObject:[NSNumber numberWithLong:(long) message.clientMsgId]];
        for (LHMessageModel *viewmodel in self.dataSource) {
            if ([viewmodel isKindOfClass:[LHMessageModel class]] && viewmodel.messageObjc.clientMsgId  == message.clientMsgId) {
                MAXLogDebug(@"Message found in list");
                NSInteger index = [self.dataSource indexOfObject:viewmodel];
                if ([NSThread isMainThread]) {
                    [self messageCellUpdateWithIndex:index message:message model:viewmodel];
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self messageCellUpdateWithIndex:index message:message model:viewmodel];
                    });
                }
                break;
            }
        }
    }
}

- (void)messageAttachmentUploadProgressChanged:(BMXMessage *)message percent:(int)percent {
    MAXLog(@"%d",percent);
}

// 收到消息
- (void)receivedMessages:(NSArray<BMXMessage*> *)messages {
    MAXLog(@"11--11---收到");
    if (messages.count > 0) {
        for (BMXMessage *message in messages) {
            [self dealWithMessage:message];
        }
    }
}
/**
 * 收到追加内容消息
 **/
- (void)receivedAppendContentMessages:(NSArray<BMXMessage*> *)messages {
    for (BMXMessage *message in messages) {
        [_typeWriterLock lock];
        BOOL isTypeWriterRunning = _typeWriterMessageText !=nil && _typeWriterMessageText.length > 0;
        if(isTypeWriterRunning && message.msgId == _typeWriterDbMessageModel.messageObjc.msgId){
            _typeWriterMessageText = message.content;
        }
        [_typeWriterLock unlock];
    }
}
/**
 * 收到变更内容消息
 **/
- (void)receivedReplaceMessages:(NSArray<BMXMessage*> *)messages {
    for (BMXMessage *message in messages) {
        [_typeWriterLock lock];
        BOOL isTypeWriterRunning = _typeWriterMessageText !=nil && _typeWriterMessageText.length > 0;
        if(isTypeWriterRunning && message.msgId == _typeWriterDbMessageModel.messageObjc.msgId){
            _typeWriterMessageText = message.content;
            _needTypeToEnd = YES;
        }else{
            for (LHMessageModel *viewmodel in self.dataSource) {
                if ([viewmodel isKindOfClass:[LHMessageModel class]] &&  viewmodel.messageObjc.msgId  == message.msgId) {
                    NSInteger index = [self.dataSource indexOfObject:viewmodel];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSString *date =  [NSString stringWithFormat:@"%lld", message.serverTimestamp];
                        LHMessageModel *dbMessageModel = [[LHIMDBManager shareManager] searchModel:[LHMessageModel class] keyValues:@{@"date" : date, @"status" : @(MessageDeliveryState_Delivered)}];
                        dbMessageModel.messageObjc = message;

                        NSIndexPath *ip = [NSIndexPath indexPathForRow:index inSection:0];
                        [self.tableView reloadRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationNone];
                    });
                }
            }
        }
        [_typeWriterLock unlock];
    }
}

- (void)showTypeWriter{
    [_typeWriterLock lock];
    NSString *typeWriterMessageText = self->_typeWriterMessageText;
    NSIndexPath *typeWriterIndex = self->_typeWriterIndex;
    [_typeWriterLock unlock];
    
    if(typeWriterIndex){
        LHChatViewCell *messageCell = (LHChatViewCell *) [self.tableView cellForRowAtIndexPath:typeWriterIndex];
        if(messageCell){
            [self.tableView reloadRowsAtIndexPaths:@[typeWriterIndex] withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView scrollToRowAtIndexPath:typeWriterIndex atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{
            [self showTypeWriter];
        });
        if(!typeWriterMessageText){
            [_typeWriterLock lock];
            _typeWriterIndex = nil;
            [_messageHandleLock unlock];
            [_typeWriterLock unlock];
        }
    }
}

- (void)stepTypeWriter{
    [_typeWriterLock lock];
    LHMessageModel *typeWriterDbMessageModel = self->_typeWriterDbMessageModel;
    NSString *typeWriterMessageText = self->_typeWriterMessageText;
    NSUInteger msgLen = typeWriterMessageText.length;
    NSUInteger curLen = typeWriterDbMessageModel.content.length + 5;
    if(curLen > msgLen){
        curLen = msgLen;
        _waitingTimes++;
    }else{
        _waitingTimes = 0;
    }
    NSUInteger waitTimes = _waitingTimes;
    [_typeWriterLock unlock];
    
    if(msgLen > 0){
        [_typeWriterLock lock];
        BOOL needTypeToEnd = _needTypeToEnd;
        [_typeWriterLock unlock];

        if(needTypeToEnd){
            typeWriterDbMessageModel.content = typeWriterMessageText;
        }else{
            typeWriterDbMessageModel.content = [typeWriterMessageText substringToIndex:curLen];
        }
        if(!needTypeToEnd && waitTimes < kMaxWaitTimes){
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)),
                           dispatch_get_main_queue(), ^{
                [self stepTypeWriter];
            });
        }else{
            [_typeWriterLock lock];
            _needTypeToEnd = NO;
            _typeWriterMessageText = nil;
            [_typeWriterLock unlock];
        }
    }
}

- (void)dealWithMessage:(BMXMessage *)message {
    [_typeWriterLock lock];
    BOOL isTypeWriterRunning = _typeWriterMessageText !=nil && _typeWriterMessageText.length > 0;
    if(isTypeWriterRunning){
        _needTypeToEnd = YES;
    }
    [_typeWriterLock unlock];
    if (message.type == BMXMessage_MessageType_Group) {
        if (self.conversation.type != BMXConversation_Type_Group || message.toId != self.conversation.conversationId) {
            return;
        }
    } else {
        if (message.fromId  != self.conversation.conversationId || message.type != BMXMessage_MessageType_Single) {
            if (message.fromId == [self.account.usedId longLongValue] && message.toId == self.conversation.conversationId) {
            } else {
                return;
            }
        }
    }
    if ([self isHaveExtion:message] ) {
        bool isTyping = [self isInTyping:message];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self dealWithidTyping:isTyping];
        });
        bool isTypingMessage = [self isTypingMessage:message.extension];
        if (isTypingMessage){
            return;
        }
    }
    [_messageHandleLock lock];
    BOOL needTypeWriter = NO;
    {
        if (self.messageType == BMXMessage_MessageType_Single) {
            [self ackMessagebyMessageObject:message];
        } else {
            if (self.currentGroup.enableReadAck == YES) {
                MAXLog(@"enableReadAckandgroupack");

                [self ackMessagebyMessageObject:message];
            }
        }

        
        NSString *date =  [NSString stringWithFormat:@"%lld", message.clientTimestamp];
        LHMessageModel *dbMessageModel = [[LHIMDBManager shareManager] searchModel:[LHMessageModel class] keyValues:@{@"date" : date, @"status" : @(MessageDeliveryState_Delivered)}];
        dbMessageModel.content = message.content;
        dbMessageModel.messageObjc = message;
        dbMessageModel.status = MessageDeliveryState_Delivering;
        NSString *fromIdStr = [NSString stringWithFormat:@"%lld", message.fromId];
        BOOL isFrom = [fromIdStr isEqualToString:self.account.usedId];
        dbMessageModel.isSender = [self isSenderOfMessageModel:dbMessageModel];
        dbMessageModel.date = date;
        dbMessageModel.id = date;
        
        if (message.contentType == BMXMessage_ContentType_Text) {
            dbMessageModel.content = message.content;
            
            NSData *data = [message.extension dataUsingEncoding:NSUTF8StringEncoding];
            id result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if ([result isKindOfClass:[NSDictionary class]] ||
                [result isKindOfClass:[NSMutableDictionary class]]){
                NSDictionary *ext = (NSDictionary *)result;
                NSDictionary *ai = [ext objectForKey:@"ai"];
                if(ai){
                    BOOL finish = [[ai objectForKey:@"finish"] boolValue];
                    if(!finish){
                        needTypeWriter = YES;
                    }
                }
            }

            if(needTypeWriter){
                dbMessageModel.content = @"";
            }
            dbMessageModel.status = MessageDeliveryState_Delivered;
            dbMessageModel.type = MessageBodyType_Text;
            
            [[LHIMDBManager shareManager] insertModel:dbMessageModel];
            dispatch_async(dispatch_get_main_queue(), ^{
                NSIndexPath *index = [self insertNewMessageOrTime:dbMessageModel];
                [self.tableView scrollToRowAtIndexPath:index atScrollPosition:UITableViewScrollPositionBottom animated:NO];
                if (needTypeWriter){
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)),
                                       dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        [self->_typeWriterLock lock];
                        self->_typeWriterMessageText = message.content;
                        self->_typeWriterDbMessageModel = dbMessageModel;
                        self->_typeWriterIndex = index;
                        [self->_typeWriterLock unlock];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)),
                                       dispatch_get_main_queue(), ^{
                            [self showTypeWriter];
                        });
                        [self stepTypeWriter];
                    });
                }
            });
        } else if (message.contentType == BMXMessage_ContentType_Image) {
            [[[BMXClient sharedClient] chatService] downloadThumbnailWithMsg:message strategy:BMXChatService_ThumbnailStrategy_ThirdpartyServerCreate completion:^(BMXError *aError) {
            }];
            
            [[[BMXClient sharedClient] chatService] downloadAttachmentWithMsg:message completion:^(BMXError *aError) {
            }];
        } else if (message.contentType == BMXMessage_ContentType_Voice) {
            [[[BMXClient sharedClient] chatService] downloadAttachmentWithMsg:message completion:^(BMXError *aError) {
            }];
            
        } else if (message.contentType == BMXMessage_ContentType_Location) {
            BMXLocationAttachment *locationAttach = [BMXLocationAttachment dynamicCastWithAttachment: message.attachment];
            dbMessageModel.content = [NSString stringWithFormat:NSLocalizedString(@"Current_location", @"当前位置：%@"),locationAttach.address];
            dbMessageModel.status = MessageDeliveryState_Delivered;
            dbMessageModel.type = MessageBodyType_Location;
            [[LHIMDBManager shareManager] insertModel:dbMessageModel];
            NSIndexPath *index = [self insertNewMessageOrTime:dbMessageModel];
            [self.tableView scrollToRowAtIndexPath:index atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        } else if (message.contentType == BMXMessage_ContentType_File) {
            [[[BMXClient sharedClient] chatService] downloadAttachmentWithMsg:message completion:^(BMXError *aError) {
            }];
        }else if (message.contentType == BMXMessage_ContentType_Video) {
            [[[BMXClient sharedClient] chatService] downloadThumbnailWithMsg:message strategy:BMXChatService_ThumbnailStrategy_ThirdpartyServerCreate completion:^(BMXError *aError) {
            }];
        }else if (message.contentType == BMXMessage_ContentType_RTC) {
            if ([message.config.getRTCAction isEqualToString: @"record"]) {
                dbMessageModel.content = message.content;
                if ([message.content isEqualToString:@"rejected"]) {
                    if (!isFrom) {
                        dbMessageModel.content = NSLocalizedString(@"call_rejected", @"通话已拒绝");
                    }else{
                        dbMessageModel.content = NSLocalizedString(@"call_rejected_by_callee", @"通话已被对方拒绝");
                    }
                } else if ([message.content isEqualToString:@"canceled"]) {
                    if (isFrom) {
                        dbMessageModel.content = NSLocalizedString(@"call_canceled", @"通话已取消");
                    }else{
                        dbMessageModel.content = NSLocalizedString(@"call_canceled_by_caller", @"通话已被对方取消");
                    }
                } else if ([message.content isEqualToString:@"timeout"]) {
                    if (isFrom) {
                        dbMessageModel.content = NSLocalizedString(@"callee_not_responding", @"对方未应答");
                    }else{
                        dbMessageModel.content = NSLocalizedString(@"call_not_responding", @"未应答");
                    }
                } else if ([message.content isEqualToString:@"busy"]) {
                    if (!isFrom) {
                        dbMessageModel.content = NSLocalizedString(@"call_busy", @"忙线未接听");
                    }else{
                        dbMessageModel.content = NSLocalizedString(@"callee_busy", @"对方忙");
                    }
                } else{
                    int sec = [dbMessageModel.content intValue]/1000;
                    NSString *format = dbMessageModel.messageObjc.config.isPeerDrop?
                    NSLocalizedString(@"call_ended", @"通话中断：%02d:%02d"):
                    NSLocalizedString(@"call_duration", @"通话时长：%02d:%02d");
                    dbMessageModel.content = [NSString stringWithFormat:format, sec/60, sec%60];
                }

                dbMessageModel.status = MessageDeliveryState_Delivered;
                dbMessageModel.type = MessageBodyType_Text;
                
                [[LHIMDBManager shareManager] insertModel:dbMessageModel];
                NSIndexPath *index = [self insertNewMessageOrTime:dbMessageModel];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView scrollToRowAtIndexPath:index atScrollPosition:UITableViewScrollPositionBottom animated:NO];
                });
            }
        }
    }
    if(!needTypeWriter){
        [_messageHandleLock unlock];
    }
}

//  附件下载状态发生变化
- (void)messageAttachmentStatusDidChanged:(BMXMessage *)message
                                    error:(BMXError*)error
                                  percent:(int)percent {
    if (message.type == BMXMessage_MessageType_Group) {
        if (self.conversation.type != BMXConversation_Type_Group || message.toId != self.conversation.conversationId) {
            return;
        }
    } else {
        if (message.fromId  != self.conversation.conversationId || message.type != BMXMessage_MessageType_Single) {
            if (message.fromId == [self.account.usedId longLongValue] && message.toId == self.conversation.conversationId) {
                
            } else {
                return;
            }
        }
    }
    
    if (percent == 101 && !error ) {

        NSString *date =  [NSString stringWithFormat:@"%lld",  message.serverTimestamp];
        LHMessageModel *dbMessageModel = [[LHIMDBManager shareManager] searchModel:[LHMessageModel class] keyValues:@{@"date" : date}];
        dbMessageModel.status = MessageDeliveryState_Delivered;
        dbMessageModel.messageObjc = message;
        NSString *fromIdStr = [NSString stringWithFormat:@"%lld", message.fromId];
        dbMessageModel.isSender = [self isSenderOfMessageModel:dbMessageModel];
        dbMessageModel.id = date;
        dbMessageModel.date = date;
        
        if (message.contentType == BMXMessage_ContentType_Image) {
            dbMessageModel.type = MessageBodyType_Image;
            BMXImageAttachment *imageAtt = [BMXImageAttachment dynamicCastWithAttachment: message.attachment];
            dbMessageModel.imageRemoteURL = imageAtt.thumbnailPath;
            dbMessageModel.width = imageAtt.size.getMWidth;
            dbMessageModel.height = imageAtt.size.getMHeight;
            
        } else if (message.contentType == BMXMessage_ContentType_Voice) {
            dbMessageModel.type = MessageBodyType_Voice;
            
            BMXVoiceAttachment *voiceAtt =[BMXVoiceAttachment dynamicCastWithAttachment:message.attachment];
            dbMessageModel.vociePath = voiceAtt.path;
            dbMessageModel.content = [NSString stringWithFormat:@"  %0.1d",voiceAtt.duration];
        } else if (message.contentType == BMXMessage_ContentType_File) {
            dbMessageModel.type = MessageBodyType_File;
            
            BMXFileAttachment *fileAtt = [BMXFileAttachment dynamicCastWithAttachment: message.attachment];
            dbMessageModel.content = fileAtt.displayName ? fileAtt.displayName : @"file";
        }else if (message.contentType == BMXMessage_ContentType_Video) {
            dbMessageModel.type = MessageBodyType_Video;
            BMXVideoAttachment *videoAtt = [BMXVideoAttachment dynamicCastWithAttachment: message.attachment];
            dbMessageModel.imageRemoteURL = videoAtt.thumbnailPath;
            dbMessageModel.width = videoAtt.size.getMWidth;
            dbMessageModel.height = videoAtt.size.getMHeight;
            dbMessageModel.content = videoAtt.displayName ? videoAtt.displayName : @"video";
            dbMessageModel.videoPath = videoAtt.path;

        }
        
        BOOL hasContain = NO;
        NSInteger index = 0;
        for (int i = 0 ; i < self.dataSource.count; i++) {
            if ([self.dataSource[i] isKindOfClass:[LHMessageModel class]]) {
                LHMessageModel *msg = self.dataSource[i];
                if ([msg.id isEqualToString:dbMessageModel.id]) {
                    hasContain = YES;
                    index = i;
                    break;
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (hasContain) {
                NSIndexPath *ip = [NSIndexPath indexPathForRow:index inSection:0];
                [self.tableView reloadRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationAutomatic];
            }else {
                [[LHIMDBManager shareManager] insertModel:dbMessageModel];
                NSIndexPath *index = [self insertNewMessageOrTime:dbMessageModel];
                [self.tableView scrollToRowAtIndexPath:index atScrollPosition:UITableViewScrollPositionBottom animated:NO];
            }
        });
    } else {
//        MAXLog(@"%@", error.errorMessage);
    }
}

//消息撤回状态改变
- (void)messageRecallStatusDidChanged:(BMXMessage *)message error:(BMXError *)error {
    MAXLog(@"消息撤回状态");
    
    if (!error) {
        LHMessageModel *deleteObject = nil;
        for (LHMessageModel *recallMessage in self.recallMessages) {
            
            NSString *recallId = [NSString stringWithFormat:@"%lld", recallMessage.messageObjc.msgId];
            NSString *messagId = [NSString stringWithFormat:@"%lld", message.msgId];
            
            if ([recallId isEqualToString:messagId]) {
                deleteObject = recallMessage;
                break;
                
            }
        }
        if(deleteObject) {
            NSInteger index = -1;
            [self.recallMessages removeObject:deleteObject];
            
            if ([self.dataSource containsObject:deleteObject]) {
                index = [self.dataSource indexOfObject:deleteObject];
                [self.dataSource removeObject:deleteObject];
            }
            if ([self.messages containsObject:deleteObject]) {
                [self.messages removeObject:deleteObject];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
            MAXLog(@"删除");
        }
    } else {
        [HQCustomToast showDialog:[NSString stringWithFormat:@"%@", error.description]];
    }
}

//收到撤回的消息
- (void)receivedRecallMessages:(NSArray<BMXMessage *> *)messages{
    for (LHMessageModel *lhModel in self.dataSource) {
        if (![lhModel isKindOfClass:[LHMessageModel class]]) {
            continue;
        }
        BMXMessage *messageObjec = [messages firstObject];
        if (lhModel.messageObjc.msgId == messageObjec.msgId) {
            
            //更新撤回的信息的显示内容
            lhModel.content = NSLocalizedString(@"Withdrawn_by_the_other_party", @"对方已撤回");
            lhModel.type = MessageBodyType_Text;
//            messageObjec.contentType = BMXMessage_ContentType_Text;
            messageObjec.content = NSLocalizedString(@"Withdrawn_by_the_other_party", @"对方已撤回");
            
            [self.tableView reloadData];
        }
    }
    MAXLog(@"收到撤回的消息");
}

/**
 * 收到消息已读回执
 **/
- (void)receivedReadAcks:(NSArray<BMXMessage*> *)messages {
    //会话列表页面 刷新已读未读状态
    //会话页面 刷新已读未读状态
    
    //更新未读数
    MAXLog(@"收到消息已读回执");
    if (self.messageType == BMXMessage_MessageType_Single) {
        for (BMXMessage *message in messages) {
            for (LHMessageModel *viewmodel in self.dataSource) {
                if ([viewmodel isKindOfClass:[LHMessageModel class]] &&  viewmodel.messageObjc.msgId  == message.msgId) {
                    NSInteger index = [self.dataSource indexOfObject:viewmodel];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        LHChatViewCell *messageCell = (LHChatViewCell *) [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
                        viewmodel.messageObjc.isReadAcked = YES;
                        messageCell.readStatusLabel.text = NSLocalizedString(@"Read", @"已读");
                    });
                }
            }
        }
    } else {
            for (BMXMessage *message in messages) {
                for (LHMessageModel *viewmodel in self.dataSource) {
                    if ([viewmodel isKindOfClass:[LHMessageModel class]] &&  viewmodel.messageObjc.msgId  == message.msgId) {
                        NSInteger index = [self.dataSource indexOfObject:viewmodel];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            LHChatViewCell *messageCell = (LHChatViewCell *) [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
                            viewmodel.messageObjc.isReadAcked = YES;
                            messageCell.readStatusLabel.text = [NSString stringWithFormat:NSLocalizedString(@"npersons_have_read", @"%d人已读"),message.groupAckCount];
                        });
                    }
                }
            }
        
    }
    
}

#pragma mark -- recoder
// 语音动画
- (BMXVoiceHud *)voiceHud {
    if (!_voiceHud) {
        _voiceHud = [[BMXVoiceHud alloc] initWithFrame:CGRectMake(0, 0, 155, 155)];
        _voiceHud.hidden = YES;
        [self.view addSubview:_voiceHud];
        _voiceHud.center = CGPointMake(MAXScreenW/2, MAXScreenH/2);
    }
    return _voiceHud;
}

// 语音动画提示文字
- (UILabel *)voiceTip {
    if (!_voiceTip) {
        _voiceTip = [[UILabel alloc] init];
        _voiceTip.hidden = YES;
        _voiceTip.textColor = [UIColor whiteColor];
        _voiceTip.font = [UIFont systemFontOfSize:14.0];
        [self.view addSubview:_voiceTip];
    }
    return _voiceTip;
}

// 语音动画计时器
- (NSTimer *)timer {
    if (!_timer) {
        _timer =[NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(progressChange) userInfo:nil repeats:YES];
    }
    return _timer;
}

- (void)timerInvalue {
    [_timer invalidate];
    _timer  = nil;
}

// 录音动画
- (void)progressChange {
    AVAudioRecorder *recorder = [[BMXRecoderTools shareManager] recorder] ;
    [recorder updateMeters];
    float power= [recorder averagePowerForChannel:0];
    CGFloat progress = (1.0/160)*(power + 160);
    self.voiceHud.progress = progress;
}

- (void)changeVoiceTipWithText:(NSString *) text{
    self.voiceTip.text = text;
    [self.voiceTip sizeToFit];
    self.voiceTip.center = CGPointMake(MAXScreenW/2, MAXScreenH/2 + 50);
}

// 录音
- (void)chatViewDidStartRecordingVoice:(LHChatBarView *)chatView {
    self.recordName = [self p_currentRecordFileName];
    [[BMXRecoderTools shareManager] startRecordingWithFileName:self.recordName completion:^(NSError *error) {
        if (error) {
            if (error.code == 201) {
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Unable_to_record", @"无法录音") message:NSLocalizedString(@"allow_BMX_to_access_your_microphone", @"请在iPhone的设置-隐私-麦克风选项中，允许BMX访问你的手机麦克风。") preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", @"确定") style:UIAlertActionStyleCancel handler:nil];
                [alert addAction:action];
                [self presentViewController:alert animated:NO completion:nil];
            }
        } else {            
            [self timerInvalue];
            self.voiceHud.hidden = NO;
            self.voiceTip.hidden = NO;
            [self timer];
            [self changeVoiceTipWithText: NSLocalizedString(@"Finger_up", @"手指上移，取消发送")];
        }
    }];
}

- (NSString *)p_currentRecordFileName {
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970] * 1000;
    NSString *fileName = [NSString stringWithFormat:@"%ld",(long)timeInterval];
    return fileName;
}


- (void)chatViewDidCancelRecordingVoice:(LHChatBarView *)chatView {
    [[BMXRecoderTools shareManager] removeCurrentRecordFile:self.recordName];
    self.voiceHud.hidden = YES;
    self.voiceTip.hidden = YES;
    [self timerInvalue];
}

- (void)chatViewDidStopRecordingVoice:(LHChatBarView *)chatView {
    __weak typeof(self) weakSelf = self;
    [[BMXRecoderTools shareManager] stopRecordingWithCompletion:^(NSString *recordPath, int duation) {
        
        self.voiceHud.hidden = YES;
        self.voiceTip.hidden = YES;

        if ([recordPath isEqualToString:shortRecord]) {
            MAXLog(@"录音时间太短");
        } else {
            NSLog(@"发送录音消息 == %@", recordPath);
            [weakSelf sendVocieMessage:recordPath duration:duation];
        }
        [self timerInvalue];
    }];
}

- (void)chatViewDidDrag:(BOOL)inside {
    
    if (inside) {
        [_timer setFireDate:[NSDate distantPast]];
        _voiceHud.image  = [UIImage imageNamed:@"voice_1"];
        [self changeVoiceTipWithText: NSLocalizedString(@"Finger_up", @"手指上移，取消发送")];
    } else {
        [_timer setFireDate:[NSDate distantFuture]];
        self.voiceHud.animationImages  = nil;
        self.voiceHud.image = [UIImage imageNamed:@"cancelVoice"];
        [self changeVoiceTipWithText: NSLocalizedString(@"Finger_release", @"松开手指，取消发送")];
    }
}

- (BMXMessage *)configMessage:(id)message {
    BMXMessage *messageObject;
    long long toId = 0;
    NSInteger conversationId = self.conversationId;
    if (self.messageType == BMXMessage_MessageType_Single) {
        toId = self.currentRoster.rosterId;
    }else {
        toId = self.currentGroup.groupId;
    }
    
    if ([message isKindOfClass:[NSString class]]) {
        messageObject = [BMXMessage createMessageWithFrom:[self.account.usedId longLongValue] to:toId type:self.messageType conversationId:conversationId content:message];
    }else {
        messageObject = [BMXMessage createMessageWithFrom:[self.account.usedId longLongValue] to:toId type:self.messageType conversationId:conversationId attachment:message];
    }
    return messageObject;
}

- (BMXMessageConfig *)dealtWithConfigjson {
    BMXMessageConfig *config = [BMXMessageConfig createMessageConfigWithMentionAll:NO];
    ListOfLongLong *idArray = [[ListOfLongLong alloc] init];
    for (BMXRosterItem *roster in self.atArray) {
        long long rosterId = roster.rosterId;
        [idArray addWithX: &rosterId];
    }
    config.mentionList = idArray;
    config.mentionAll  = false;
    return config;
}

#pragma mark  - sendMessage
- (void)p_configsendMessage:(id)content type:(MessageBodyType)type duartion:(int)duartion {
    // 发送消息
    BMXMessage *messageObject;
    __block LHMessageModel *messageModel = [LHMessageModel new];
    messageModel.isSender = YES;
    messageModel.status = MessageDeliveryState_Delivering;
    messageModel.type = type;
    switch (type) {
        case MessageBodyType_Text: {
            messageModel.content = content;
            NSString *messageText = content;
            messageObject = [self configMessage:messageText];
            if (self.messageType == BMXMessage_MessageType_Group && self.groupAt == YES) {
                messageObject.config = [self dealtWithConfigjson];
                self.groupAt = NO;
            }
            
            break;
        }
        case MessageBodyType_Image: {
            UIImage *image = (UIImage *)content;
            messageModel.width = image.size.width;
            messageModel.height = image.size.height;
            [SDImageCache.sharedImageCache storeImage:image forKey:messageModel.date completion:nil];
            
            NSData *imageData = UIImageJPEGRepresentation(image,1.0f);
            NSData *thumImageData =  UIImageJPEGRepresentation(image,1.0f);
            BMXMessageAttachmentSize *sz = [[BMXMessageAttachmentSize alloc] initWithWidth:image.size.width height:image.size.height];
            BMXImageAttachment *imageAttachment = [[BMXImageAttachment alloc] initWithData:imageData thumbnailData:thumImageData imageSize:sz displayName:@"1" conversationId:(long)self.conversationId];
            messageObject = [self configMessage:imageAttachment];
            messageModel.imageRemoteURL = [imageAttachment thumbnailPath];
            
            break;
        }
        case MessageBodyType_Voice: {
            NSString *voicePath = (NSString *)content;
            BMXVoiceAttachment *vocieAttachment = [[BMXVoiceAttachment alloc] initWithPath:voicePath duration:duartion displayName:@"voice"];
            messageObject = [self configMessage:vocieAttachment];
            messageModel.vociePath = voicePath;
            messageModel.content = [NSString stringWithFormat:@"  %d s",duartion];
            
            break;
        }
        case MessageBodyType_Location: {
            NSDictionary *locationInfo = (NSDictionary *)content;
            double latitude = [locationInfo[@"latitude"] doubleValue];
            double longitude = [locationInfo[@"longitude"] doubleValue];
            NSString *address = locationInfo[@"address"];
            
            BMXLocationAttachment *locationment = [[BMXLocationAttachment alloc] initWithLatitude:latitude longitude:longitude address:address];
            messageObject = [self configMessage:locationment];
            messageModel.content = [NSString stringWithFormat:NSLocalizedString(@"Current_location", @"当前位置：%@"),locationment.address];
            break;
        }
        case MessageBodyType_File: {
            NSDictionary *dic = [NSDictionary dictionaryWithDictionary:content];
            BMXFileAttachment *fileAttachment = [[BMXFileAttachment alloc] initWithData:dic[@"data"] displayName:dic[@"displayName"] conversationId: (long)self.conversationId];
            messageObject = [self configMessage:fileAttachment];
            messageModel.content = dic[@"displayName"];
            break;
        }
            
        case MessageBodyType_Video: {
            NSDictionary *dic = [NSDictionary dictionaryWithDictionary:content];
            UIImage *image = dic[@"thumbImage"];
            BMXMessageAttachmentSize *sz = [[BMXMessageAttachmentSize alloc] initWithWidth:image.size.width height:image.size.height];
            BMXVideoAttachment *videoAttachment = [[BMXVideoAttachment alloc] initWithData:dic[@"videodata"]
                                                                             thumbnailData:dic[@"thumbnaildata"]
                                                                                  duration:duartion
                                                                                      size:sz
                                                                               displayName:@"1.mp4" conversationId:(long)self.conversationId];
            messageObject = [self configMessage:videoAttachment];
            messageModel.content = dic[@"displayName"];
            messageModel.width = image.size.width;
            messageModel.height = image.size.height;
            messageModel.imageRemoteURL = [videoAttachment thumbnailPath];
            messageModel.videoPath = videoAttachment.path;


            break;
        }
        default:
            break;
    }
    
    messageModel.date = [NSString stringWithFormat:@"%lld", messageObject.clientTimestamp];
    messageModel.id = messageModel.date;
    messageModel.clientMsgId = messageObject.clientMsgId;
    messageModel.messageObjc = messageObject;
    [self.deliveringMsgClientIds addObject:[NSNumber numberWithLong:(long) messageModel.clientMsgId]];

    [[LHIMDBManager shareManager] insertModel:messageModel];
    
    [_typeWriterLock lock];
    BOOL isTypeWriterRunning = _typeWriterMessageText !=nil && _typeWriterMessageText.length > 0;
    if(isTypeWriterRunning){
        _needTypeToEnd = YES;
    }
    [_typeWriterLock unlock];

    double delay = isTypeWriterRunning ? 0.2 : 0;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)),dispatch_get_main_queue(), ^{
        NSString *time = [LHTools dayStringWithDate:[NSString stringWithFormat:@"%f",messageModel.messageObjc.serverTimestamp * 0.001]];
        if (messageModel.messageObjc.serverTimestamp * 0.001 - self.lastTime.doubleValue > 3 * 60) {
            self.lastTime = [NSString stringWithFormat:@"%f",messageModel.messageObjc.serverTimestamp * 0.001];
            [self insertNewMessageOrTime:time];
            //        self.lastTime = time;
        }
        
        NSIndexPath *index = [self insertNewMessageOrTime:messageModel];
        [self.tableView scrollToRowAtIndexPath:index atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        if (messageObject) {
            messageObject.clientTimestamp = [messageModel.date longLongValue];
            [[[BMXClient sharedClient] chatService] sendMessageWithMsg: messageObject completion:^(BMXError *aError) {
            }];
        }
    });

}

//voice
- (void)sendVocieMessage:(NSString *)recordPath duration:(int)duration{
    [self p_configsendMessage:recordPath type:MessageBodyType_Voice duartion:duration];
}

#pragma mark - Delegate ChatBarProtocol
- (void)chatViewSendLocation {
    [self p_StartLocate];
}

- (void)chatViewVideoCall {
    CallViewController *videoCallViewController =
        [[CallViewController alloc] initForRoom:[self.account.usedId longLongValue]
                                                 callId:0
                                                   myId:[self.account.usedId longLongValue]
                                                 peerId:self.currentRoster.rosterId
                                              messageId:0
                                                    pin:@""
                                               isCaller:YES
                                               hasVideo:YES
                                          currentRoster:_currentRoster];
    videoCallViewController.modalTransitionStyle =  UIModalTransitionStyleCrossDissolve;
    videoCallViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:videoCallViewController
                       animated:NO
                     completion:nil];
}

- (void)chatViewVoiceCall {
    CallViewController *videoCallViewController =
        [[CallViewController alloc] initForRoom:[self.account.usedId longLongValue]
                                                 callId:0
                                                   myId:[self.account.usedId longLongValue]
                                                 peerId:self.currentRoster.rosterId
                                              messageId:0
                                                    pin:@""
                                               isCaller:YES
                                               hasVideo:NO
                                          currentRoster:_currentRoster];
    videoCallViewController.modalTransitionStyle =  UIModalTransitionStyleCrossDissolve;
    videoCallViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:videoCallViewController
                       animated:NO
                     completion:nil];
}

- (void)p_StartLocate {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:{
            [self.locationManager requestWhenInUseAuthorization];
        }
            break;
            
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusDenied:{
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Alert", @"提示") message:NSLocalizedString(@"location_service_need_to_turn_it_on", @"您还未开启定位服务，是否需要开启？") preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"取消") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            }];
            UIAlertAction *queren = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", @"确定") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSURL *setingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                [[UIApplication sharedApplication]openURL:setingsURL];
            }];
            [alert addAction:cancel];
            [alert addAction:queren];
            [self.navigationController presentViewController:alert animated:YES completion:nil];
        }
            break;
            
        default:{
            self.locationManager.delegate = self;//设置代理
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;//设置精度
            self.locationManager.distanceFilter = 1000.0f;//距离过滤
            [self.locationManager requestWhenInUseAuthorization];//位置权限申请
            [self.locationManager requestLocation];//开始定位
            [HQCustomToast showWating];
        }
            
            break;
    }
}

- (void)chatViewSendVideoWithVideoView:(VideoView *)view {
    self.videoView = view;
    view.hidden = NO;
        // 在这里创建视频设配
        UIView *videoLayerView = [view viewWithTag:1000];
        UIView *placeholderView = [view viewWithTag:1001];
        [[VideoManager shareManager] setVideoPreviewLayer:videoLayerView];
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(videoPreviewLayerWillAppear:) userInfo:placeholderView repeats:NO];
}

// 移除录视频时的占位图片
- (void)videoPreviewLayerWillAppear:(NSTimer *)timer
{
    UIView *placeholderView = (UIView *)[timer userInfo];
    [placeholderView removeFromSuperview];
}

#pragma mark - ChatBarViewDelegate
// barview event
- (void)chatViewSelectedFile:(NSString *)filePath {
    [self p_configsendMessage:filePath type:MessageBodyType_File duartion:0];
}

- (void)chatViewSelectedFileData:(NSData *)data displayName:(NSString *)displayName {
    
    [self p_configsendMessage:@{@"data":data,
                        @"displayName":displayName}
                 type:MessageBodyType_File duartion:0];
}

//group mention event
- (void)inputat {
    if (self.messageType == BMXMessage_MessageType_Group) {
        GroupCreateViewController  *vc = [[GroupCreateViewController alloc] initWithCurrentGroup:self.currentGroup];
        vc.isAt = YES;
        vc.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - GroupCreateViewControllerDelegate
- (void)atgroupmemberVCdidPopToLastVC:(NSArray<BMXRosterItem *> *)rosterArray {
    NSMutableArray *array = [NSMutableArray array];
    for (BMXRosterItem *r in rosterArray) {
        [array addObject:r.username];
    }
    NSString *string = [array componentsJoinedByString:@",@"];
    self.chatBarView.textView.text = [self.chatBarView.textView.text stringByAppendingString:string];
    self.atArray = rosterArray;
    
    self.groupAt = YES;
}

#pragma mark - lazy
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, MAXIsFullScreen ? kNavBarHeight + 20 : kNavBarHeight , MAXScreenW, MAXScreenH - (MAXIsFullScreen ? kChatBarHeight + 34 : kChatBarHeight) - (MAXIsFullScreen ? kNavBarHeight + 20 : kNavBarHeight)) style:UITableViewStyleGrouped];
        _tableView.backgroundColor = [UIColor lh_colorWithHex:0xffffff];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView addObserver:self forKeyPath:kTableViewOffset options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        [_tableView addObserver:self forKeyPath:kTableViewFrame options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    }
    return _tableView;
}

- (LHChatBarView *)chatBarView {
    if (!_chatBarView) {
        LHWeakSelf;
        
        CGFloat height;
        if (MAXIsFullScreen) {
            height = 83;
        } else {
            height = kChatBarHeight;
        }
        _chatBarView = [[LHChatBarView alloc] initWithFrame:CGRectMake(0, MAXScreenH - height, MAXScreenW, kChatBarHeight)];
        _chatBarView.backgroundColor = [UIColor lh_colorWithHex:0xf8f8fa];
        _chatBarView.tableView = self.tableView;
        _chatBarView.delegate = self;
        
        _chatBarView.sendContent = ^(LHContentModel *content) {
            [weakSelf sendMessage:content];
        };
    }
    return _chatBarView;
}

- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = @[].mutableCopy;
    }
    return _dataSource;
}

- (NSMutableArray *)recallMessages {
    if (!_recallMessages) {
        _recallMessages = @[].mutableCopy;
    }
    return _recallMessages;
}

- (NSMutableArray *)messages {
    if (!_messages) {
        _messages = @[].mutableCopy;
    }
    return _messages;
}

- (NSCache *)rowHeight {
    if (!_rowHeight) {
        _rowHeight = [NSCache new];
    }
    return _rowHeight;
}

- (XSBrowserAnimateDelegate *)browserAnimateDelegate {
    if (!_browserAnimateDelegate) {
        _browserAnimateDelegate = [XSBrowserAnimateDelegate shareInstance];
    }
    return _browserAnimateDelegate;
}

- (void)setUpNavItem{
    NSString *title ;
    if (self.messageType == BMXMessage_MessageType_Group) {
        title = self.currentGroup.name;
    } else if (self.messageType == BMXMessage_MessageType_Single){
        title = [self.currentRoster.nickname length] ? self.currentRoster.nickname : self.currentRoster.username;
        if (!title) {
            title = [NSString stringWithFormat:@"%lld", self.conversationId];
        }
    } else {
        title = @"";
    }
    
    [self removeNavLeftButtonDefaultEvent];
    [self.navLeftButton addTarget:self action:@selector(returnButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self setNavigationBarTitle:title navLeftButtonIcon:@"blackback" navRightButtonIcon:@"chatNavMore"];
    [self.navRightButton addTarget:self action:@selector(clickMoreButton) forControlEvents:UIControlEventTouchUpInside];
}

- (void)dealloc {
    MAXLog(@"销毁");
    if (self.chatBarView.textView.text && [self.chatBarView.textView.text  length]) {
        self.conversation.editMessage = self.chatBarView.textView.text;
    } else {
        self.conversation.editMessage = @"";
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshConversation" object:self.conversation];

    self.documentIntertactionController.delegate = nil;
    [self timerInvalue];
    [self.tableView removeObserver:self forKeyPath:kTableViewFrame];
    [self.tableView removeObserver:self forKeyPath:kTableViewOffset];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[[BMXClient sharedClient] chatService] removeDelegate:self];
    [[[BMXClient sharedClient] rtcService] removeDelegate:self];
}

- (CLLocationManager *)locationManager {
    if (_locationManager  == nil) {
        _locationManager = [[CLLocationManager alloc] init];
    }
    return _locationManager;
}

@end
