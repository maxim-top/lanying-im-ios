#import "CallViewController.h"

#import <floo-rtc-ios/RTCEngineManager.h>
#import "CallView.h"
#import "NSString+Extention.h"
#import "AppDelegate.h"
#import "AVFoundation/AVFoundation.h"

@interface CallViewController () <
    CallViewDelegate,
    BMXRTCEngineProtocol,
    BMXRTCServiceProtocol,
    BMXChatServiceProtocol>
@property(nonatomic, readonly) CallView *videoCallView;
@property(nonatomic, strong) BMXRosterItem *currentRoster;
@property(nonatomic, strong, nullable) dispatch_source_t vibrationTimer;//振动计时器
@property(nonatomic, assign) int ringTimes;
@property(nonatomic, assign) NSTimeInterval pickupTimestamp;
@end

@implementation CallViewController 

- (instancetype)initForRoom:(long long)roomId
                     callId:(NSString*)callId
                       myId:(long long)myId
                     peerId:(long long)peerId
                  messageId:(long long)messageId
                        pin:(NSString*)pin
                   isCaller:(BOOL)isCaller
                   hasVideo:(BOOL)hasVideo
              currentRoster:(BMXRosterItem *)roster{
  if (self = [super init]) {
      _roomId = roomId;
      _callId = callId;
      _myId = myId;
      _peerId = peerId;
      _messageId = messageId;
      _pin = pin;
      _isCaller = isCaller;
      _hasVideo = hasVideo;
      _currentRoster = roster;
      _ringTimes = 20;
      [[RTCEngineManager engineWithType:kMaxEngine] addDelegate:self];
      [[[BMXClient sharedClient] chatService] addDelegate:self delegateQueue:dispatch_get_main_queue()];
      [[[BMXClient sharedClient] rtcService] addDelegate:self];
      if (_isCaller){
          NSUUID *uuid = [NSUUID UUID];
          NSString *pin = [uuid UUIDString];
          _pin = pin;
          [self joinRoomWithUserId:_myId pin:pin];
      }
      [self ring];
  }
  return self;
}

- (BMXErrorCode)joinRoomWithUserId:(long long) userId pin:(NSString*) pin{
    if (_hasVideo) {
        BMXVideoConfig *videoConfig = [[BMXVideoConfig alloc] init];
        [videoConfig setWidth:240];
        [videoConfig setHeight:360];
        [[RTCEngineManager engineWithType:kMaxEngine] setVideoProfile:videoConfig];
    }
    BMXRoomAuth *auth = [[BMXRoomAuth alloc] init];
    [auth setMUserId:userId];
    [auth setMToken:pin];
    return [[RTCEngineManager engineWithType:kMaxEngine] joinRoomWithAuth:auth];
}

- (BMXErrorCode)joinRoomWithUserId:(long long) userId pin:(NSString*) pin roomId:(long long) roomId{
    BMXVideoConfig *videoConfig = [[BMXVideoConfig alloc] init];
    [videoConfig setWidth:720];
    [videoConfig setHeight:1280];
    [[RTCEngineManager engineWithType:kMaxEngine] setVideoProfile:videoConfig];
    BMXRoomAuth *auth = [[BMXRoomAuth alloc] init];
    [auth setMUserId:userId];
    [auth setMToken:pin];
    [auth setMRoomId:roomId];
    return [[RTCEngineManager engineWithType:kMaxEngine] joinRoomWithAuth:auth];
}

- (void)ring{
    SystemSoundID soundID;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"bell.mp3" ofType:nil];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &soundID);

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    if (self.vibrationTimer) {
        dispatch_cancel(self.vibrationTimer);
        self.vibrationTimer = nil;
    }
    self.vibrationTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, 0 * NSEC_PER_SEC);
    uint64_t interval = 2 * NSEC_PER_SEC;
    dispatch_source_set_timer(self.vibrationTimer, start, interval, 0);
    __weak typeof(self) weakSelf = self;
    dispatch_source_set_event_handler(self.vibrationTimer, ^{
        typeof(self) strongSelf = weakSelf;
        if(strongSelf.ringTimes <= 0){
            dispatch_cancel(strongSelf.vibrationTimer);
            if (strongSelf.ringTimes == 0) {
                [self hangupByMe:YES];
                return;
            }
        }
        AudioServicesPlaySystemSound(soundID);

        strongSelf.ringTimes--;
    });
    dispatch_resume(self.vibrationTimer);
}

- (void)sendCallMessage{
    BMXMessageConfig *config = [BMXMessageConfig createMessageConfigWithMentionAll: NO];
    [config setRTCCallInfo:_hasVideo?BMXMessageConfig_RTCCallType_VideoCall:BMXMessageConfig_RTCCallType_AudioCall roomId:_roomId initiator:_myId roomType:BMXMessageConfig_RTCRoomType_Broadcast pin:_pin];
    _callId = config.getRTCCallId;
    BMXMessage *msg = [BMXMessage createRTCMessageWithFrom:_myId to:_peerId type:BMXMessage_MessageType_Single conversationId:_peerId content:@"new call"];
    msg.config = config;
    [msg setExtension:@"{\"rtc\":\"call\"}"];
    [[[BMXClient sharedClient] rtcService] sendRTCMessageWithMsg:msg completion:^(BMXError *aError) {
    }];
}

- (void)sendSwitchToVoiceCall{
    BMXMessage *msg = [BMXMessage createRTCMessageWithFrom:_myId to:_peerId type:BMXMessage_MessageType_Single conversationId:_peerId content:@""];
    msg.extension = [NSString jsonStringWithDictionary:@{@"rtc_cmd":@"switch_audio"}];
    msg.deliveryQos = BMXMessage_DeliveryQos_AtMostOnce;
    [[[BMXClient sharedClient] rtcService] sendRTCMessageWithMsg:msg completion:^(BMXError *aError) {
    }];
}

- (void)sendPickupMessage{
    BMXMessageConfig *config = [BMXMessageConfig createMessageConfigWithMentionAll: NO];
    [config setRTCPickupInfo:_callId];
    BMXMessage *msg = [BMXMessage createRTCMessageWithFrom:_myId to:_peerId type:BMXMessage_MessageType_Single conversationId:_peerId content:@""];
    msg.config = config;
    [[[BMXClient sharedClient] rtcService] sendRTCMessageWithMsg:msg completion:^(BMXError *aError) {
    }];
    [self ackMessageWithMessageId:_messageId];
}

- (void)sendHangupMessage{
    BMXMessageConfig *config = [BMXMessageConfig createMessageConfigWithMentionAll: NO];
    if (_callId) {
        [config setRTCHangupInfo:_callId];
        _callId = nil;
    }
    NSTimeInterval duration = 0.0;
    NSString *content = @"canceled"; //Caller canceled
    if (!_isCaller) {
        content = @"rejected"; //Callee rejected
    }else{
        if (_ringTimes == 0) { //Callee not responding
            content = @"timeout";
        }
    }
    if (_pickupTimestamp > 1.0) {
        duration = [self getTimeStamp] - _pickupTimestamp;
    }
    if (duration > 1.0) {
        content = [NSString stringWithFormat:@"%.0f", duration];
    }
    BMXMessage *msg = [BMXMessage createRTCMessageWithFrom:_myId to:_peerId type:BMXMessage_MessageType_Single conversationId:_peerId content:content];
    msg.config = config;
    [[[BMXClient sharedClient] rtcService] sendRTCMessageWithMsg:msg completion:^(BMXError *aError) {
        NSNotification *noti = [NSNotification notificationWithName:@"call" object:self userInfo:@{@"event":@"hangup"}];
        //发送通知
        [[NSNotificationCenter defaultCenter]postNotification:noti];
    }];
}

-(NSTimeInterval)getTimeStamp
{
    NSDate* timeStamp = [NSDate dateWithTimeIntervalSinceNow:0];
    return [timeStamp timeIntervalSince1970]*1000;
}

- (void)hangupByMe:(BOOL)byMe{
    if (byMe) {
        [self sendHangupMessage];
    }
    [[RTCEngineManager engineWithType:kMaxEngine] leaveRoom];
    [[RTCEngineManager engineWithType:kMaxEngine] removeDelegate:self];
    [[[BMXClient sharedClient] rtcService] removeDelegate:self];
    [[[BMXClient sharedClient] chatService] removeDelegate:self];

    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    });
}

- (void)ackMessageWithMessageId:(long long)messageId{
    BMXMessage *msg = [[[BMXClient sharedClient] chatService] getMessage:messageId];
    if (msg) {
        [[[BMXClient sharedClient] chatService] ackMessageWithMsg:msg];
    }
}

- (void)dealWithMessage:(BMXMessage *)message {
    if (message.fromId  != _peerId || message.type != BMXMessage_MessageType_Single) {
        return;
    }
    NSString * ext = message.extension;
    if (message.contentType == BMXMessage_ContentType_RTC && ext.length>0 ) {
        NSDictionary *dic = [NSString dictionaryWithJsonString:ext];
        NSString *cmd = dic[@"rtc_cmd"];
        if ([cmd isEqualToString:@"switch_audio"]){
            if (message.fromId == _peerId) {
                [self muteVideo];
            }
        }
    }
}

- (void)muteVideo{
    _hasVideo = NO;
    _videoCallView.hasVideo = NO;
    [[RTCEngineManager engineWithType:kMaxEngine] muteLocalVideoWithType:BMXVideoMediaType_Camera mute:YES];
    [_videoCallView layoutSubviews];
}

#pragma mark - BMXRTCServiceProtocol
- (void)onRTCHangupMessageReceiveWithMsg:(BMXMessage*)msg {
    long long otherId = [[RTCEngineManager engineWithType:kMaxEngine] otherId];
    if ([msg.config.getRTCCallId isEqualToString: _callId] &&
        (msg.fromId == otherId || [msg.content isEqualToString:@"busy"]
         || [msg.content isEqualToString:@"rejected"] || ![[RTCEngineManager engineWithType:kMaxEngine] isOnCall])) {
        [self hangupByMe:NO];
        _ringTimes = -1;
        [self ackMessageWithMessageId:msg.msgId];
    }
}

- (void)onRTCPickupMessageReceiveWithMsg:(BMXMessage*)msg{
    if ([msg.config.getRTCCallId isEqualToString: _callId] && msg.fromId == _myId) {
        [self hangupByMe:NO];
        _ringTimes = -1;
        [self ackMessageWithMessageId:msg.msgId];
    }
}

#pragma mark - BMXChatServiceProtocol
// 收到消息
- (void)receivedMessages:(NSArray<BMXMessage*> *)messages {
    if (messages.count > 0) {
        for (BMXMessage *message in messages) {
            [self dealWithMessage:message];
        }
    }
}

- (void)loadView {
    _videoCallView = [[CallView alloc] initWithFrame:CGRectZero isCaller:_isCaller hasVideo:_hasVideo currentRoster:_currentRoster];
    _videoCallView.delegate = self;
    self.view = _videoCallView;
}

- (void)switchToVoiceCall{
    [self muteVideo];
    [self sendSwitchToVoiceCall];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
  return UIInterfaceOrientationMaskAll;
}

#pragma mark - BMXRTCEngineProtocol
- (void)onJoinRoomWithInfo:(NSString*)info roomId:(long long)roomId error:(BMXErrorCode)error{
    _roomId = roomId;
    if (error == BMXErrorCode_NoError) {
        [[RTCEngineManager engineWithType:kMaxEngine] publishWithType:BMXVideoMediaType_Camera hasVideo:_hasVideo hasAudio:YES];
        if (_isCaller) {
            [self sendCallMessage];
        }
    }
}

- (void)onSubscribeWithStream:(BMXStream*)stream info:(NSString*)info error:(BMXErrorCode)error{
    if (error != BMXErrorCode_NoError) {
        return;
    }
    BOOL hasVideo = [stream getMEnableVideo];
    if (hasVideo) {
        BMXVideoCanvas *canvas = [[BMXVideoCanvas alloc] init];
        [canvas setMStream:stream];
        [canvas setMUserId:[stream getMUserId]];
        [canvas setMView:(void*)_videoCallView.remoteVideoView];
        [[RTCEngineManager engineWithType:kMaxEngine] startRemoteViewWithCanvas:canvas];
    }
    _videoCallView.isConnected = YES;
    [_videoCallView layoutSubviews];
    _ringTimes = -1;
    _pickupTimestamp = [self getTimeStamp];
}

- (void)onRemotePublishWithStream:(BMXStream*)stream info:(NSString*)info error:(BMXErrorCode)error{
    if (error != BMXErrorCode_NoError) {
        return;
    }
    [[RTCEngineManager engineWithType:kMaxEngine] subscribeWithStream:stream];
}

#pragma mark - CallViewDelegate

- (void)videoCallViewDidHangup:(CallView *)view {
    _ringTimes = -1;
    [self hangupByMe:YES];
    if (_pickupTimestamp < 1.0) {
        [self ackMessageWithMessageId:_messageId];
    }
}

- (void)videoCallViewDidAnswer:(CallView *)view {
    [self joinRoomWithUserId:_myId pin:_pin roomId:_roomId];
    [self sendPickupMessage];
}

- (void)videoCallViewDidSwitchCamera:(CallView *)view {
    [[RTCEngineManager engineWithType:kMaxEngine] switchCamera];
}

- (void)videoCallViewDidSwitchToVoice:(CallView *)view {
    [self switchToVoiceCall];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (_hasVideo) {
        BMXVideoCanvas *canvas = [[BMXVideoCanvas alloc] init];
        [canvas setMView:(void*)_videoCallView.localVideoView];
        [[RTCEngineManager engineWithType:kMaxEngine] startPreviewWithCanvas:canvas];
    }
}
@end
