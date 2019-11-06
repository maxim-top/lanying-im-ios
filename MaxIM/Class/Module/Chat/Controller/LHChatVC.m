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

#import "BMXClient.h"
#import "BMXChatManager.h"
#import "BMXMessageObject.h"
#import "BMXMessageAttachment.h"
#import "BMXImageAttachment.h"
#import "BMXVoiceAttachment.h"
#import "BMXLocationAttachment.h"
#import "BMXFileAttachment.h"
#import "BMXVideoAttachment.h"

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
#import "BMXRoster.h"

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


//#import "BMXGroupMember.h"

NSString *const kTableViewOffset = @"contentOffset";
NSString *const kTableViewFrame = @"frame";

@interface LHChatVC () <UITableViewDelegate,
UITableViewDataSource,
XSBrowserDelegate,
BMXChatServiceProtocol,
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

@property (nonatomic, strong) BMXRoster *currentRoster;
@property (nonatomic, strong) BMXGroup *currentGroup;
@property (nonatomic,assign)  BMXMessageType messageType;


@property (strong, nonatomic) UITableView *tableView;
@property (nonatomic, strong) LHChatBarView *chatBarView;
// 满足刷新
@property (nonatomic, assign, getter=isMeetRefresh) BOOL meetRefresh;
// 正在刷新
@property (nonatomic, assign, getter=isHeaderRefreshing) BOOL headerRefreshing;

@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, strong) NSMutableArray *recallMessages;

@property (nonatomic, strong) NSCache *rowHeight;

// 消息时间
@property (nonatomic, strong) NSString *lastTime;
@property (nonatomic, assign) CGFloat tableViewOffSetY;
@property (nonatomic, assign) NSInteger imageIndex;

@property (nonatomic, strong) XSBrowserAnimateDelegate *browserAnimateDelegate;

@property (nonatomic, strong) IMAcount *account;

// 录音
@property (nonatomic, strong) BMXVoiceHud *voiceHud;
@property (nonatomic, strong) NSTimer *timer; //记录录音的动画

@property (nonatomic, assign) NSInteger conversationId;
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


@property (nonatomic, strong) VideoView *videoView;

@end

@implementation LHChatVC

- (instancetype)initWithRoster:(BMXRoster *)roster
                   messageType:(BMXMessageType)messageType {
    if (self = [super init]) {
        self.currentRoster = roster;
        self.messageType = messageType;
        MAXLog(@"单聊：roster%lld",self.currentRoster.rosterId );
    }
    return self;
}

- (instancetype)initWithGroupChat:(BMXGroup *)group
                      messageType:(BMXMessageType)messageType {
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
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.account = [IMAcountInfoStorage loadObject];
    [self  getMyProfile];
    
    [self setUpNavItem];
    [self setupSubview];
    
    [self loadMessages];
    
    [self scrollToBottomAnimated:NO refresh:NO];
    
    [[[BMXClient sharedClient] chatService] addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    [self p_configNotification];
    [self p_configEditMessage];
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
    if (self.messageType == BMXMessageTypeGroup) {
        return;
    }
    [self sendTypingMessage:@{@"input_status":@"nothing"}];
}

- (void)sendTypingMessage:(NSDictionary *)configdic {
    BMXMessageObject *messageObject = [[BMXMessageObject alloc] initWithBMXMessageText:@""
                                                                                fromId:[self.account.usedId longLongValue]
                                                                                  toId:self.currentRoster.rosterId
                                                                                  type:BMXMessageTypeSingle
                                                                        conversationId:self.currentRoster.rosterId];
    messageObject.extensionJson = [NSString jsonStringWithDictionary:configdic];
    messageObject.qos = DeliveryQosModeAtMostOnce;
    [[[BMXClient sharedClient] chatService] sendMessage:messageObject completion:^(BMXMessageObject *message, BMXError *error) {
        if (!error) {
            MAXLog(@"发送对方要显示正在输入的标题");
        }
    }];
}

- (void)beginEdit {
    MAXLog(@"正在编辑");
    if (self.messageType == BMXMessageTypeGroup) {
        return;
    }
    [self sendTypingMessage:@{@"input_status":@"typing"}];
}

- (void)getMyProfile {
    [[[BMXClient sharedClient] userService] getProfileForceRefresh:NO completion:^(BMXUserProfile *profile, BMXError *aError) {
        [self getSelfAvatar:profile];
    }];
}

- (void)getSelfAvatar:(BMXUserProfile *)profile {
    UIImage *avarat = [UIImage imageWithContentsOfFile:profile.avatarThumbnailPath];
    if (avarat) {
        self.selfImage  = avarat;
    }else {
        [[[BMXClient sharedClient] userService] downloadAvatarWithProfile:profile thumbnail:YES progress:^(int progress, BMXError *error) {
        } completion:^(BMXUserProfile *profile, BMXError *error) {
            UIImage *image = [UIImage imageWithContentsOfFile:profile.avatarThumbnailPath];
            self.selfImage  = image;
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
        self.title = @"正在输入...";
    } else {
        self.title = [self.currentRoster.nickName length] ? self.currentRoster.nickName : self.currentRoster.userName;
    }
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

- (BOOL)isHaveExtion:(BMXMessageObject *)model {
    if ([model.extensionJson length]) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)isTypingOperationStatus:(NSString *)extionJson {
    NSDictionary *dic = [NSString dictionaryWithJsonString:extionJson];
    if ([dic[@"input_status"] isEqualToString:@"typing"]) {
        return YES;
    } else if ([dic[@"input_status"] isEqualToString:@"nothing"] ){
        return NO;
    } else {
        return NO;
    }
}

- (void)loadMessages {
    BMXConversation *conversation;
    if (self.messageType == BMXConversationGroup) {
        self.conversationId =  self.conversationId ?self.conversationId : (NSInteger)self.currentGroup.groupId;
        BMXConversation *groupConversation = [[[BMXClient sharedClient] chatService] openConversation:self.conversationId type:BMXConversationGroup createIfNotExist:YES];
        
        conversation = groupConversation;
    } else {
        self.conversationId = self.conversationId ? self.conversationId: (NSInteger)self.currentRoster.rosterId;
        BMXConversation *singleConversation = [[[BMXClient sharedClient] chatService] openConversation:self.conversationId type:BMXConversationSingle createIfNotExist:YES];
        conversation = singleConversation;
        
        UIImage *image = [UIImage imageWithContentsOfFile:self.currentRoster.avatarThumbnailPath];
        if (!image) {
            [[[BMXClient sharedClient] rosterService] downloadAvatarWithRoster:self.currentRoster progress:^(int progress, BMXError *error) {
            }  completion:^(BMXRoster *rosterObjc, BMXError *error) {
                if (!error) {
                    UIImage *image = [UIImage imageWithContentsOfFile:rosterObjc.avatarThumbnailPath];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        self.deImage = image;
                    });
                }
            }];
        }else {
            self.deImage = image;
        }
        
    }
    self.conversation = conversation;
    
    [[[BMXClient sharedClient] chatService] retrieveHistoryBMXconversation:self.conversation msgId:0 size:10 completion:^(NSArray *messageListms, BMXError *error) {
        
        
        MAXLog(@"%lu", (unsigned long)messageListms.count);
        messageListms =  [messageListms sortedArrayUsingComparator:^NSComparisonResult(BMXMessageObject *message1, BMXMessageObject *message2) {
            return message1.serverTimestamp < message2.serverTimestamp;
        }];
        
        [messageListms enumerateObjectsUsingBlock:^(BMXMessageObject *message, NSUInteger idx, BOOL * stop) {
            
            LHMessageModel *messageModel = [self changeUIModelWithBMXMessage:message];
            
            if (self.messageType == BMXMessageTypeSingle) {
                [self ackMessagebyModel:messageModel];
            } else {
                if (self.currentGroup.enableReadAck == YES) {
                    [self ackMessagebyModel:messageModel];
                }
            }
            
            NSString *time = [LHTools processingTimeWithDate:messageModel.date];
            if (![self.lastTime isEqualToString:time]) {
                [self.dataSource insertObject:time atIndex:0];
                self.lastTime = time;
            }
        }];
        
        [self.tableView reloadData];
        
        
        if (self.dataSource.count >  1) {
            NSIndexPath *ip = [NSIndexPath indexPathForRow:self.dataSource.count - 1 inSection:0];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:NO ]; //滚动到最后一行
                
            });
        }
        
    }];
}

- (LHMessageModel *)changeUIModelWithBMXMessage:(BMXMessageObject *)message {
    NSString *date =  [NSString stringWithFormat:@"%lld", message.serverTimestamp];
    LHMessageModel *dbMessageModel = [[LHIMDBManager shareManager] searchModel:[LHMessageModel class] keyValues:@{@"date" : date, @"status" : @(MessageDeliveryState_Delivered)}];
    dbMessageModel.messageObjc = message;
    dbMessageModel.isSender = [message.fromId isEqualToString:self.account.usedId];
    dbMessageModel.date = date;
    dbMessageModel.id = date;
    switch ( message.deliverystatus) {
        case BMXDeliveryStatusNew:
            dbMessageModel.status = MessageDeliveryState_Pending;
            break;
        case BMXDeliveryStatusDelivering:
            dbMessageModel.status = MessageDeliveryState_Delivering;
            break;
        case BMXDeliveryStatusDeliveried:
            dbMessageModel.status = MessageDeliveryState_Delivered;
            break;
        case BMXDeliveryStatusFailed:
            dbMessageModel.status = MessageDeliveryState_Failure;
            break;
        case BMXDeliveryStatusRecalled:
            dbMessageModel.status = MessageDeliveryState_Pending;
            break;
            
        default:
            break;
    }
    
    if (message.contentType == BMXContentTypeText) {
        dbMessageModel.content = message.content;
        dbMessageModel.type = MessageBodyType_Text;
        [self.dataSource insertObject:dbMessageModel atIndex:0];
        [self.messages insertObject:dbMessageModel atIndex:0];
        
    } else if (message.contentType == BMXContentTypeImage) {
        dbMessageModel.type = MessageBodyType_Image;
        BMXImageAttachment *imageAtt = (BMXImageAttachment *)message.attachment;
        dbMessageModel.width = imageAtt.pictureSize.width;
        dbMessageModel.height = imageAtt.pictureSize.height;
        dbMessageModel.imageRemoteURL = imageAtt.thumbnailPath;
        [self.dataSource insertObject:dbMessageModel atIndex:0];
        [self.messages insertObject:dbMessageModel atIndex:0];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:dbMessageModel.imageRemoteURL]) {
            [[[BMXClient sharedClient] chatService] downloadThumbnail:message strategy:ThirdpartyServerCreate];
        }else {
            
        }
        
    } else if (message.contentType == BMXContentTypeVoice) {
        dbMessageModel.type = MessageBodyType_Voice;
        
        BMXVoiceAttachment *voiceAtt = (BMXVoiceAttachment *)message.attachment;
        
        dbMessageModel.vociePath = voiceAtt.path;
        dbMessageModel.content = [NSString stringWithFormat:@"  %d s",voiceAtt.duration];
        [self.dataSource insertObject:dbMessageModel atIndex:0];
        [self.messages insertObject:dbMessageModel atIndex:0];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:dbMessageModel.vociePath]) {
            
            [[[BMXClient sharedClient] chatService] downloadAttachment:message];
        }
        
    }else if (message.contentType == BMXContentTypeLocation) {
        BMXLocationAttachment *locationAttach = (BMXLocationAttachment *)message.attachment;
        dbMessageModel.content = [NSString stringWithFormat:@"当前位置：%@",locationAttach.address];
        dbMessageModel.status = MessageDeliveryState_Delivered;
        dbMessageModel.type = MessageBodyType_Location;
        [self.dataSource insertObject:dbMessageModel atIndex:0];
        [self.messages insertObject:dbMessageModel atIndex:0];
        
    } else if (message.contentType == BMXContentTypeFile) {
        BMXFileAttachment *fileAtt = (BMXFileAttachment *)message.attachment;
        dbMessageModel.content = fileAtt.displayName ? fileAtt.displayName : @"file";
        dbMessageModel.type = MessageBodyType_File;
        if (![[NSFileManager defaultManager] fileExistsAtPath:fileAtt.path]) {
            
            [[[BMXClient sharedClient] chatService] downloadAttachment:message];
        }
        [self.dataSource insertObject:dbMessageModel atIndex:0];
        [self.messages insertObject:dbMessageModel atIndex:0];
    } else if (message.contentType == BMXContentTypeVideo) {
        BMXVideoAttachment *videoAtt = (BMXVideoAttachment *)message.attachment;
        dbMessageModel.content = videoAtt.displayName ? videoAtt.displayName : @"video";
        dbMessageModel.type = MessageBodyType_Video;
        
        MAXLog(@"%f, %f", videoAtt.size.width, videoAtt.size.height)
        dbMessageModel.width = videoAtt.videoSize.width;
        dbMessageModel.height = videoAtt.videoSize.height;
        dbMessageModel.imageRemoteURL = videoAtt.thumbnailPath;
        dbMessageModel.videoPath = videoAtt.path;

        if (![[NSFileManager defaultManager] fileExistsAtPath:dbMessageModel.imageRemoteURL]) {
            [[[BMXClient sharedClient] chatService] downloadThumbnail:message strategy:ThirdpartyServerCreate];
            
        }else {
            MAXLog(@"存在");
        }
        
        [self.dataSource insertObject:dbMessageModel atIndex:0];
        [self.messages insertObject:dbMessageModel atIndex:0];
    }
    return dbMessageModel;
}

- (void)loadMessageWithId:(NSString *)Id {
    NSArray *messages = [[LHIMDBManager shareManager] searchModelArr:[LHMessageModel class] byKey:Id];
    self.meetRefresh = messages.count == kMessageCount;
    [messages enumerateObjectsUsingBlock:^(LHMessageModel *messageModel, NSUInteger idx, BOOL * stop) {
        messageModel.date = [NSString stringWithFormat:@"%f",messageModel.messageObjc.serverTimestamp * 0.001];
        NSString *time = [LHTools processingTimeWithDate:messageModel.date];
        
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
    NSIndexPath *index = [NSIndexPath indexPathForRow:self.dataSource.count inSection:0];
    [self.dataSource addObject:NewMessage];
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
            [tableView setContentOffset:CGPointMake(0, tableView.contentSize.height - newValue.size.height) animated:YES];
        }
        return;
    }
    
    CGPoint newValue = [change[NSKeyValueChangeNewKey] CGPointValue];
    if (!self.headerRefreshing) self.headerRefreshing = newValue.y < 40 && self.isMeetRefresh;
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
    }
}

- (void)p_configVideoMessageWithpath:(NSString *)path {
    
    MAXLog(@"%@", path);
    int dur =  [[VideoManager shareManager] getVideoTimeByUrlString:path];
    UIImage *image = [[VideoManager shareManager] getVideoPreViewImage:[NSURL fileURLWithPath:path]];
    NSData *thumbNailData = UIImageJPEGRepresentation(image,1.0f);//第二个参数为压缩倍数
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSDictionary *dic = @{@"videodata" : data,
                          @"tumbnaildata" : thumbNailData,
                          @"thumbImage":image};

    [self p_configsendMessage:dic type:MessageBodyType_Video duartion:dur];
}


-(void)clickMoreButton {
    switch (self.messageType) {
        case BMXMessageTypeGroup:
            if(self.currentGroup != nil) {
                if (self.currentGroup.groupStatus
                    == BMXGroupNormal) {
                    GroupDetailViewController* ctrl = [[GroupDetailViewController alloc] initWithGroup:self.currentGroup];
                    ctrl.conversation = self.conversation;
                    [self.navigationController pushViewController:ctrl animated:YES];
                } else {
                    [HQCustomToast showDialog:@"该群已解散"];
                }
            }
            break;
        case BMXMessageTypeSingle:
            if(self.currentRoster != nil) {
                ChatRosterProfileViewController* vc = [[ChatRosterProfileViewController alloc] initWithRoster:self.currentRoster];
                [self.navigationController pushViewController:vc animated:YES];
            }
            break;
        default:
            break;
    }
}

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
    [[[BMXClient sharedClient] chatService] recallMessage:self.currentMessage.messageObjc completion:nil];
    [self.recallMessages addObject:self.currentMessage];
    self.currentMessage = nil;
    [[UIMenuController sharedMenuController] setMenuItems:@[]];
}

// 设置未读
- (void)setUnread {
    [[[BMXClient sharedClient] chatService] readCancel:self.currentMessage.messageObjc];
    [[UIMenuController sharedMenuController] setMenuItems:@[]];
}

// 删除消息
- (void)deleteMessage {
    [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
    [[[BMXClient sharedClient] chatService] removeMessage:self.currentMessage.messageObjc synchronizeDeviceForce:YES];
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
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"您还未开启定位服务，是否需要开启？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    UIAlertAction *queren = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
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
                self.currentCity = @"⟳定位获取失败,点击重试";
            } else {
                self.currentCity = placeMark.locality ;//获取当前城市
                
            }
            
            NSString *addr = [NSString stringWithFormat:@"%@%@%@", placeMark.subLocality,placeMark.thoroughfare,placeMark.name];
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确定发送？" message:addr preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            }];
            UIAlertAction *queren = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                           [self p_configsendMessage:@{@"latitude" : lait, @"longitude" :longt, @"address" : addr } type:MessageBodyType_Location duartion:0];

            }];
            [alert addAction:cancel];
            [alert addAction:queren];
            [self.navigationController presentViewController:alert animated:YES completion:nil];
            
            
            
            
            
        } else if (error == nil && placemarks.count == 0 ) {
        } else if (error) {
            self.currentCity = @"⟳定位获取失败,点击重试";
            [HQCustomToast showDialog:self.currentCity];
        }
        // 还原Device 的语言
        [[NSUserDefaults
          standardUserDefaults] setObject:userDefaultLanguages
         forKey:@"AppleLanguages"];
    }];
}



#pragma mark - Delegate TransterMessageVC
- (void)transterSlectedRoster:(BMXRoster *)roster {
    [self groupOwnerTransterVCdidSelect:roster];
}

- (void)transterSlectedGroup:(BMXGroup *)group {
    BMXMessageObject *m = [[BMXMessageObject alloc] initWithForwardMessage:self.currentMessage.messageObjc fromId:[self.account.usedId longLongValue] toId:group.groupId type:BMXMessageTypeGroup conversationId:group.groupId];
    m.enableGroupAck = YES;
    [[[BMXClient sharedClient] chatService] forwardMessage:m];
}

- (void)groupOwnerTransterVCdidSelect:(id)toModel {
    BMXRoster *roster = toModel;
    BMXMessageObject *m = [[BMXMessageObject alloc] initWithForwardMessage:self.currentMessage.messageObjc fromId:[self.account.usedId longLongValue] toId:roster.rosterId type:BMXMessageTypeSingle conversationId:roster.rosterId];
    m.enableGroupAck = YES;
    [[[BMXClient sharedClient] chatService] forwardMessage:m];
}

// video的bubble被点击
- (void)chatVideoCellBubblePressed:(LHMessageModel *)model {
    if (model.videoPath && ![model.videoPath isKindOfClass:[NSNull class]] && [[NSFileManager defaultManager] fileExistsAtPath:model.videoPath]) {
        [self videoPlay:model.videoPath];
    } else {
        [[[BMXClient sharedClient] chatService] downloadAttachment:model.messageObjc];
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
    photoPreview.modalPresentationStyle = UIModalPresentationCustom;
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
    BMXFileAttachment *fileAtt = (BMXFileAttachment *)model.messageObjc.attachment;
    
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
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"操作" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* action1 = [UIAlertAction actionWithTitle:@"转发" style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action) {
                                                        //响应事件
                                                        TransterViewController *vc = [[TransterViewController alloc] init];
                                                        vc.delegate = self;
                                                        [self.navigationController pushViewController:vc animated:YES];
                                                        
                                                        self.currentMessage = message;
                                                        //
                                                        
                                                    }];
    UIAlertAction* action2 = [UIAlertAction actionWithTitle:@"设置为未读" style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action) {
                                                        if (message.messageObjc) {
                                                            //
                                                            [[[BMXClient sharedClient] chatService] readCancel:message.messageObjc];
                                                        }
                                                        
                                                    }];
    
    [alert addAction:action1];
    [alert addAction:action2];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}


- (void)chatBubbleLongPressed:(LHMessageModel *)message
                          ges:(UILongPressGestureRecognizer*)ges {
    
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
            _copyMenuItem = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copyMessage)];
        }
    }
    
    if (_forwardMenuItem == nil) {
        _forwardMenuItem = [[UIMenuItem alloc] initWithTitle:@"转发" action:@selector(forwardMessage)];
    }
    
    
    if (_deleteMenuItem == nil) {
        _deleteMenuItem = [[UIMenuItem alloc] initWithTitle:@"删除" action:@selector(deleteMessage)];
    }
    
    if (messageModel.isSender) {
        
        if (_recallMenuItem == nil) {
            _recallMenuItem = [[UIMenuItem alloc] initWithTitle:@"撤回" action:@selector(recallMessage)];
        }
        
        if (messageModel.type == MessageBodyType_Text) {
            [[UIMenuController sharedMenuController] setMenuItems:@[_copyMenuItem,_forwardMenuItem,_recallMenuItem,_deleteMenuItem]];
            
        } else {
            [[UIMenuController sharedMenuController] setMenuItems:@[_forwardMenuItem,_recallMenuItem,_deleteMenuItem]];
            
        }
        [[UIMenuController sharedMenuController] menuItems];
        
    } else {
        if (_unreadMenuItem == nil) {
            _unreadMenuItem = [[UIMenuItem alloc] initWithTitle:@"设置未读" action:@selector(setUnread)];
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
    
    if (messageModel.isSender) {
        [messageCell setAvaratImage:self.selfImage];
        
        if (self.messageType == BMXMessageTypeSingle) {
            // 配置是否已读
            if (messageModel.messageObjc.isReadAcked == YES) {
                messageCell.readStatusLabel.text = @"已读";
            } else {
                messageCell.readStatusLabel.text = @"未读";
            }
        } else {
            if (messageModel.messageObjc.enableGroupAck == YES) {
                messageCell.readStatusLabel.text = [NSString stringWithFormat:@"%d人已读", messageModel.messageObjc.groupAckCount];
            } else {
                messageCell.readStatusLabel.text = @"";

            }
        }
    } else {
        __weak  LHChatViewCell *weakCell = messageCell;
        [[[BMXClient sharedClient] rosterService] searchByRosterId:messageModel.messageObjc.fromId.integerValue forceRefresh:NO completion:^(BMXRoster *roster, BMXError *error) {
            if (!error) {
                
                if ([[NSFileManager defaultManager] fileExistsAtPath:roster.avatarThumbnailPath]) {
                    UIImage *avarat = [UIImage imageWithContentsOfFile:roster.avatarThumbnailPath];
                    [weakCell setAvaratImage:avarat];
                }else {
                    
                    [[[BMXClient sharedClient] rosterService] downloadAvatarWithRoster:roster progress:^(int progress, BMXError *error) {
                        
                    } completion:^(BMXRoster *roster, BMXError *error) {
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
    
    if (self.messageType == BMXMessageTypeGroup) {
        
        messageModel.isChatGroup = YES;
        
        __weak  LHChatViewCell *weakCell = messageCell;
        [[[BMXClient sharedClient] rosterService] searchByRosterId:[messageModel.messageObjc.fromId integerValue] forceRefresh:NO completion:^(BMXRoster *roster, BMXError *error) {
            if (!error) {
                messageModel.nickName = [roster.nickName length] ? roster.nickName : roster.userName;
                [weakCell setMessageName:messageModel.nickName];
            }
        }];
    } else {
        messageModel.isChatGroup = NO;
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
    
    if (self.messageType == BMXMessageTypeGroup) {
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
    if (self.messageType == BMXMessageTypeSingle) {
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
            [[[BMXClient sharedClient] chatService] ackMessage:model.messageObjc];
        }
    }
}

- (void)ackMessagebyModel:(LHMessageModel *)model {
    if (!model.isSender == YES && model.messageObjc.isReadAcked == NO) {
        [[[BMXClient sharedClient] chatService] ackMessage:model.messageObjc];
    }
}

- (void)ackMessagebyMessageObject:(BMXMessageObject *)messageObject {
    if (![messageObject.fromId isEqualToString:self.account.usedId] && messageObject.isRead == NO) {
        [[[BMXClient sharedClient] chatService] ackMessage:messageObject];
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
    BMXMessageObject *firstMessage;
    for (int i = 0; i < self.dataSource.count;i++) {
        LHMessageModel *messageModel = self.dataSource[i];
        if ([messageModel isKindOfClass:[LHMessageModel class]]) {
            firstMessage = messageModel.messageObjc;
            break;
        }
    }
    long long firstMessageId = firstMessage? firstMessage.msgId : 0;
    
    [[[BMXClient sharedClient] chatService] retrieveHistoryBMXconversation:self.conversation msgId:firstMessageId size:10 completion:^(NSArray *messageListms, BMXError *error) {
        
        messageListms =  [messageListms sortedArrayUsingComparator:^NSComparisonResult(BMXMessageObject *message1, BMXMessageObject *message2) {
            return message1.serverTimestamp < message2.serverTimestamp;
        }];
        
        [messageListms enumerateObjectsUsingBlock:^(BMXMessageObject *message, NSUInteger idx, BOOL * stop) {
            if ([message.extensionJson isEqualToString:@"istyping"] || [message.extensionJson isEqualToString:@"endtyping"] ) {
                [self dealWithidTyping:message];
                
            }else {
                
                LHMessageModel *messageModel = [self changeUIModelWithBMXMessage:message];
                NSString *time = [LHTools processingTimeWithDate:messageModel.date];
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

#pragma mark - listener
//  消息状态发生变化
- (void)messageStatusChanged:(BMXMessageObject *)message error:(BMXError *)error {
    if (error) {
        [HQCustomToast showDialog:error.errorMessage];
    }
    
    if ([self isHaveExtion:message]) {
        //如果是扩展信息（现在的扩展信息，是不展示消息，）所以return不做UI处理
        return;
    } else {
        
        NSString *date = [NSString stringWithFormat:@"%lld",  message.clientTimestamp];
        __block LHMessageModel *messageModel;
        __block LHChatViewCell *messagecell;
        NSArray *cells = [self.tableView visibleCells];
        [cells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[LHChatViewCell class]]) {
                LHChatViewCell *cell = (LHChatViewCell *)obj;
                if ([cell.messageModel.date isEqualToString:date]) {
                    messageModel = cell.messageModel;
                    messagecell = cell;
                    *stop = YES;
                }
            }
        }];
        MAXLog(@"%u",message.deliverystatus);
        if (messageModel) {
            switch ( message.deliverystatus) {
                case BMXDeliveryStatusNew:
                    messageModel.status = MessageDeliveryState_Pending;
                    break;
                case BMXDeliveryStatusDelivering:
                    messageModel.status = MessageDeliveryState_Delivering;
                    break;
                case BMXDeliveryStatusDeliveried:
                    messageModel.status = MessageDeliveryState_Delivered;
                    break;
                case BMXDeliveryStatusFailed:
                    messageModel.status = MessageDeliveryState_Failure;
                    break;
                case BMXDeliveryStatusRecalled:
                    messageModel.status = MessageDeliveryState_Pending;
                    break;
                    
                default:
                    break;
            }
            
            MAXLog(@"%d",message.deliverystatus);
            [messagecell layoutSubviews];
        }
    }
}

- (void)messageAttachmentUploadProgressChanged:(BMXMessageObject *)message percent:(int)percent {
    MAXLog(@"%d",percent);
}

// 收到消息
- (void)receivedMessages:(NSArray<BMXMessageObject*> *)messages {
    if (messages.count > 0) {
        for (BMXMessageObject *message in messages) {
            [self dealWithMessage:message];
        }
    }
}

- (void)dealWithMessage:(BMXMessageObject *)message {
    if (message.messageType == BMXMessageTypeGroup) {
        if (self.conversation.type != BMXMessageTypeGroup || message.toId.longLongValue != self.conversation.conversationId) {
            return;
        }
        
    } else {
        if (message.fromId.longLongValue  != self.conversation.conversationId || message.messageType != BMXMessageTypeSingle) {
            if (message.fromId.longLongValue == [self.account.usedId longLongValue] && message.toId.longLongValue == self.conversation.conversationId) {

            } else {
                return;
            }
        }
    }
    
    if ([self isHaveExtion:message] ) {
        [self dealWithidTyping:[self isTypingOperationStatus:message.extensionJson]];
        return;
    } else {
        
        
        if (self.messageType == BMXMessageTypeSingle) {
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
        dbMessageModel.status = MessageDeliveryState_Delivering;
        dbMessageModel.isSender = [message.fromId isEqualToString:self.account.usedId];
        dbMessageModel.date = date;
        dbMessageModel.id = date;
        
        if (message.contentType == BMXContentTypeText) {
            dbMessageModel.content = message.content;
            dbMessageModel.status = MessageDeliveryState_Delivered;
            dbMessageModel.type = MessageBodyType_Text;
            
            dbMessageModel.messageObjc = message;
            [[LHIMDBManager shareManager] insertModel:dbMessageModel];
            NSIndexPath *index = [self insertNewMessageOrTime:dbMessageModel];
            [self.messages addObject:dbMessageModel];
            [self.tableView scrollToRowAtIndexPath:index atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            
        } else if (message.contentType == BMXContentTypeImage) {
            [[[BMXClient sharedClient] chatService] downloadThumbnail:message strategy:ThirdpartyServerCreate];
            
            [[[BMXClient sharedClient] chatService] downloadAttachment:message];
        } else if (message.contentType == BMXContentTypeVoice) {
            [[[BMXClient sharedClient] chatService] downloadAttachment:message];
            
        } else if (message.contentType == BMXContentTypeLocation) {
            BMXLocationAttachment *locationAttach = (BMXLocationAttachment *)message.attachment;
            dbMessageModel.content = [NSString stringWithFormat:@"当前位置：%@",locationAttach.address];
            dbMessageModel.status = MessageDeliveryState_Delivered;
            dbMessageModel.isSender = NO;
            dbMessageModel.type = MessageBodyType_Location;
            dbMessageModel.messageObjc = message;
            [[LHIMDBManager shareManager] insertModel:dbMessageModel];
            NSIndexPath *index = [self insertNewMessageOrTime:dbMessageModel];
            [self.messages addObject:dbMessageModel];
            [self.tableView scrollToRowAtIndexPath:index atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            
        } else if (message.contentType == BMXContentTypeFile) {
            [[[BMXClient sharedClient] chatService] downloadAttachment:message];
        }else if (message.contentType == BMXContentTypeVideo) {
            [[[BMXClient sharedClient] chatService] downloadThumbnail:message strategy:ThirdpartyServerCreate];
        }
    }
}

//  附件下载状态发生变化
- (void)messageAttachmentStatusDidChanged:(BMXMessageObject *)message
                                    error:(BMXError*)error
                                  percent:(int)percent {
    if (message.messageType == BMXMessageTypeGroup) {
        if (self.conversation.type != BMXMessageTypeGroup || message.toId.longLongValue != self.conversation.conversationId) {
            return;
        }
    } else {
        if (message.fromId.longLongValue  != self.conversation.conversationId || message.messageType != BMXMessageTypeSingle) {
            if (message.fromId.longLongValue == [self.account.usedId longLongValue] && message.toId.longLongValue == self.conversation.conversationId) {
                
            } else {
                return;
            }
        }
    }
    
    if (percent == 100 && !error ) {

        NSString *date =  [NSString stringWithFormat:@"%lld",  message.serverTimestamp];
        LHMessageModel *dbMessageModel = [[LHIMDBManager shareManager] searchModel:[LHMessageModel class] keyValues:@{@"date" : date}];
        dbMessageModel.status = MessageDeliveryState_Delivered;
        dbMessageModel.messageObjc = message;
        dbMessageModel.isSender = [message.fromId isEqualToString:self.account.usedId];
        dbMessageModel.id = date;
        dbMessageModel.date = date;
        
        if (message.contentType == BMXContentTypeImage) {
            dbMessageModel.type = MessageBodyType_Image;
            BMXImageAttachment *imageAtt = (BMXImageAttachment *)message.attachment;
            dbMessageModel.imageRemoteURL = imageAtt.thumbnailPath;
            dbMessageModel.width = imageAtt.pictureSize.width;
            dbMessageModel.height = imageAtt.pictureSize.height;
            
        } else if (message.contentType == BMXContentTypeVoice) {
            dbMessageModel.type = MessageBodyType_Voice;
            
            BMXVoiceAttachment *voiceAtt = (BMXVoiceAttachment *)message.attachment;
            dbMessageModel.vociePath = voiceAtt.path;
            dbMessageModel.content = [NSString stringWithFormat:@"  %0.1d",voiceAtt.duration];
        } else if (message.contentType == BMXContentTypeFile) {
            dbMessageModel.type = MessageBodyType_File;
            
            BMXFileAttachment *fileAtt = (BMXFileAttachment *)message.attachment;
            dbMessageModel.content = fileAtt.displayName ? fileAtt.displayName : @"file";
        }else if (message.contentType == BMXContentTypeVideo) {
            dbMessageModel.type = MessageBodyType_Video;
            BMXVideoAttachment *videoAtt = (BMXVideoAttachment *)message.attachment;
            dbMessageModel.imageRemoteURL = videoAtt.thumbnailPath;
            dbMessageModel.width = videoAtt.videoSize.width;
            dbMessageModel.height = videoAtt.videoSize.height;
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
                [self.messages addObject:dbMessageModel];
                [self.tableView scrollToRowAtIndexPath:index atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            }
        });
    }
}

//消息撤回状态改变
- (void)messageRecallStatusDidChanged:(BMXMessageObject *)message error:(BMXError *)error {
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
        [HQCustomToast showDialog:[NSString stringWithFormat:@"%@", error.errorMessage]];
    }
}

//收到撤回的消息
- (void)receivedRecallMessages:(NSArray<BMXMessageObject *> *)messages{
    for (LHMessageModel *lhModel in self.dataSource) {
        if (![lhModel isKindOfClass:[LHMessageModel class]]) {
            continue;
        }
        BMXMessageObject *messageObjec = [messages firstObject];
        if (lhModel.messageObjc.msgId == messageObjec.msgId) {
            
            //更新撤回的信息的显示内容
            lhModel.content = @"对方已撤回";
            lhModel.type = MessageBodyType_Text;
            messageObjec.contentType = BMXContentTypeText;
            messageObjec.content = @"对方已撤回";
            
            [self.tableView reloadData];
        }
    }
    MAXLog(@"收到撤回的消息");
}

/**
 * 收到消息已读回执
 **/
- (void)receivedReadAcks:(NSArray<BMXMessageObject*> *)messages {
    //会话列表页面 刷新已读未读状态
    //会话页面 刷新已读未读状态
    
    //更新未读数
    MAXLog(@"收到消息已读回执");
    if (self.messageType == BMXMessageTypeSingle) {
        for (BMXMessageObject *message in messages) {
            for (LHMessageModel *viewmodel in self.dataSource) {
                if ([viewmodel isKindOfClass:[LHMessageModel class]] &&  viewmodel.messageObjc.msgId  == message.msgId) {
                    NSInteger index = [self.dataSource indexOfObject:viewmodel];
                    LHChatViewCell *messageCell = (LHChatViewCell *) [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
                    viewmodel.messageObjc.isReadAcked = YES;
                    messageCell.readStatusLabel.text = @"已读";
                }
            }
        }
    } else {
            for (BMXMessageObject *message in messages) {
                for (LHMessageModel *viewmodel in self.dataSource) {
                    if ([viewmodel isKindOfClass:[LHMessageModel class]] &&  viewmodel.messageObjc.msgId  == message.msgId) {
                        NSInteger index = [self.dataSource indexOfObject:viewmodel];
                        LHChatViewCell *messageCell = (LHChatViewCell *) [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
                        viewmodel.messageObjc.isReadAcked = YES;
                        messageCell.readStatusLabel.text = [NSString stringWithFormat:@"%d人已读",message.groupAckCount];

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

// 录音
- (void)chatViewDidStartRecordingVoice:(LHChatBarView *)chatView {
    self.recordName = [self p_currentRecordFileName];
    [[BMXRecoderTools shareManager] startRecordingWithFileName:self.recordName completion:^(NSError *error) {
        if (error) {
            if (error.code == 201) {
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"无法录音" message:@"请在iPhone的“设置-隐私-麦克风”选项中，允许BMX访问你的手机麦克风。" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
                [alert addAction:action];
                [self presentViewController:alert animated:NO completion:nil];
            }
        } else {
            
            [self timerInvalue];
            self.voiceHud.hidden = NO;
            [self timer];
            
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
    [self timerInvalue];
}

- (void)chatViewDidStopRecordingVoice:(LHChatBarView *)chatView {
    __weak typeof(self) weakSelf = self;
    [[BMXRecoderTools shareManager] stopRecordingWithCompletion:^(NSString *recordPath, int duation) {
        
        self.voiceHud.hidden = YES;
        
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
    } else {
        [_timer setFireDate:[NSDate distantFuture]];
        self.voiceHud.animationImages  = nil;
        self.voiceHud.image = [UIImage imageNamed:@"cancelVoice"];
    }
}

- (BMXMessageObject *)configMessage:(id)message {
    BMXMessageObject *messageObject;
    NSInteger toId = 0;
    NSInteger conversationId = self.conversationId;
    if (self.messageType == BMXMessageTypeSingle) {
        toId = self.currentRoster.rosterId;
    }else {
        toId = self.currentGroup.groupId;
    }
    
    if ([message isKindOfClass:[NSString class]]) {
        messageObject = [[BMXMessageObject alloc] initWithBMXMessageText:message
                                                                  fromId:[self.account.usedId longLongValue]
                                                                    toId:toId
                                                                    type:self.messageType
                                                          conversationId:conversationId];
        messageObject.enableGroupAck = YES;

    }else {
        messageObject = [[BMXMessageObject alloc] initWithBMXMessageAttachment:message
                                                                        fromId:[self.account.usedId longLongValue]
                                                                          toId:toId type:self.messageType
                                                                conversationId:conversationId];
        messageObject.enableGroupAck = YES;
    }
    return messageObject;
}

- (NSString *)dealtWithConfigjson {
    NSMutableArray *idArray = [NSMutableArray array];
    for (BMXRoster *roster in self.atArray) {
        [idArray addObject:[NSString stringWithFormat:@"%lld", roster.rosterId]];
    }
    
    NSDictionary *dic = @{@"mentionAll": @0,
                          @"mentionList": idArray,
                          @"pushMessage": @"",
                          @"senderNickname": @""};
    return [NSString jsonStringWithDictionary:dic];
}

#pragma mark  - sendMessage
- (void)p_configsendMessage:(id)content type:(MessageBodyType)type duartion:(int)duartion {
    // 发送消息
    BMXMessageObject *messageObject;
    __block LHMessageModel *messageModel = [LHMessageModel new];
    messageModel.isSender = YES;
    messageModel.status = MessageDeliveryState_Delivering;
    messageModel.type = type;
    switch (type) {
        case MessageBodyType_Text: {
            messageModel.content = content;
            NSString *messageText = content;
            messageObject = [self configMessage:messageText];
            if (self.messageType == BMXMessageTypeGroup && self.groupAt == YES) {
                messageObject.configJson = [self dealtWithConfigjson];
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
            BMXImageAttachment *imageAttachment = [[BMXImageAttachment alloc] initWithData:imageData thumbnailData:thumImageData imageSize:image.size conversationId:[NSString stringWithFormat:@"%ld",(long)self.conversationId]];
            imageAttachment.pictureSize = CGSizeMake(image.size.width, image.size.height);
            messageObject = [self configMessage:imageAttachment];
            messageObject.contentType = BMXContentTypeImage;
            messageModel.imageRemoteURL = [imageAttachment thumbnailPath];
            
            break;
        }
        case MessageBodyType_Voice: {
            NSString *voicePath = (NSString *)content;
            
            BMXVoiceAttachment *vocieAttachment = [[BMXVoiceAttachment alloc] initWithPath:voicePath displayName:@"voice" duration:duartion];
            messageObject = [self configMessage:vocieAttachment];
            messageObject.contentType = BMXContentTypeVoice;
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
            messageObject.contentType = BMXContentTypeLocation;
            messageModel.content = [NSString stringWithFormat:@"当前位置：%@",locationment.address];
            break;
        }
        case MessageBodyType_File: {
            NSDictionary *dic = [NSDictionary dictionaryWithDictionary:content];
            BMXFileAttachment *fileAttachment = [[BMXFileAttachment alloc] initWithData:dic[@"data"] displayName:dic[@"displayName"] conversationId:[NSString stringWithFormat:@"%ld",(long)self.conversationId]];
            messageObject = [self configMessage:fileAttachment];
            messageObject.contentType = BMXContentTypeFile;
            messageModel.content = dic[@"displayName"];
            break;
        }
            
        case MessageBodyType_Video: {
            NSDictionary *dic = [NSDictionary dictionaryWithDictionary:content];
//            int videoTime = (int)dic[@"videoduration"];
            NSData *tumbnaildata = [NSData dataWithData:dic[@"tumbnaildata"]];
            UIImage *image = dic[@"thumbImage"];
            BMXVideoAttachment *videoAttachment = [[BMXVideoAttachment alloc] initWithData:dic[@"videodata"]
                                                                                  duration:duartion
                                                                                 videoSize:image.size
                                                                               displayName:@""
                                                                             thumbnailData:tumbnaildata
                                                                            conversationId:[NSString stringWithFormat:@"%ld",(long)self.conversationId]];
            videoAttachment.size = CGSizeMake(image.size.width, image.size.height);
            messageObject = [self configMessage:videoAttachment];
            messageObject.contentType = BMXContentTypeVideo;
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
    messageModel.messageObjc = messageObject;
    [[LHIMDBManager shareManager] insertModel:messageModel];
    NSString *time = [LHTools processingTimeWithDate:[NSString stringWithFormat:@"%f",messageModel.messageObjc.serverTimestamp * 0.001]];
    if (messageModel.messageObjc.serverTimestamp * 0.001 - self.lastTime.doubleValue > 3 * 60) {
        self.lastTime = [NSString stringWithFormat:@"%f",messageModel.messageObjc.serverTimestamp * 0.001];
        [self insertNewMessageOrTime:time];
        //        self.lastTime = time;
    }
    NSIndexPath *index = [self insertNewMessageOrTime:messageModel];
    [self.messages addObject:messageModel];
    [self.tableView scrollToRowAtIndexPath:index atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
    if (messageObject) {
        messageObject.clientTimestamp = [messageModel.date longLongValue];
        [[[BMXClient sharedClient] chatService] sendMessage:messageObject completion:^(BMXMessageObject *message, BMXError *error) {
            MAXLog(@"发送消息%@", error);
        }];
    }
}

//voice
- (void)sendVocieMessage:(NSString *)recordPath duration:(int)duration{
    [self p_configsendMessage:recordPath type:MessageBodyType_Voice duartion:duration];
}

#pragma mark - Delegate ChatBarProtocol
- (void)chatViewSendLocation {
    [self p_StartLocate];
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
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"您还未开启定位服务，是否需要开启？" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            }];
            UIAlertAction *queren = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
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
    if (self.messageType == BMXMessageTypeGroup) {
        GroupCreateViewController *vc = [[GroupCreateViewController alloc] initWithCurrentGroup:self.currentGroup];
        vc.isAt = YES;
        vc.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - GroupCreateViewControllerDelegate
- (void)atgroupmemberVCdidPopToLastVC:(NSArray<BMXRoster *> *)rosterArray {
    NSMutableArray *array = [NSMutableArray array];
    for (BMXRoster *r in rosterArray) {
        [array addObject:r.userName];
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
    if (self.messageType == BMXMessageTypeGroup) {
        title = self.currentGroup.name;
    } else if (self.messageType == BMXMessageTypeSingle){
        title = [self.currentRoster.nickName length] ? self.currentRoster.nickName : self.currentRoster.userName;
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
    self.documentIntertactionController.delegate = nil;
    [self timerInvalue];
    [self.tableView removeObserver:self forKeyPath:kTableViewFrame];
    [self.tableView removeObserver:self forKeyPath:kTableViewOffset];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (CLLocationManager *)locationManager {
    if (_locationManager  == nil) {
        _locationManager = [[CLLocationManager alloc] init];
    }
    return _locationManager;
}

@end
