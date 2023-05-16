//
//  LHChatInputView.h
//  LHChatUI
//
//  Created by hyt on 2016/12/22.
//  Copyright © 2016年 hyt. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KeyboardEmojiTextView;
@class LHChatBarView;
@class VideoView;
@protocol ChatBarProtocol <NSObject>


@optional
/**
 *  开始录音
 *
 *  @param chatView chatBox
 */
- (void)chatViewDidStartRecordingVoice:(LHChatBarView *)chatView;
- (void)chatViewDidStopRecordingVoice:(LHChatBarView *)chatView;
- (void)chatViewDidCancelRecordingVoice:(LHChatBarView *)chatView;
- (void)chatViewDidDrag:(BOOL)inside;

- (void)chatViewSendLocation;
- (void)chatViewVideoCall;
- (void)chatViewVoiceCall;
- (void)chatViewSelectedFile:(NSString *)filePath;
- (void)chatViewSelectedFileData:(NSData *)data displayName:(NSString *)displayName;

- (void)chatViewSendVideoWithVideoView:(VideoView *)view;



- (void)inputat;

@end

@class LHContentModel;

@interface LHChatBarView : UIView

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) void(^sendContent)(LHContentModel *content);
@property (nonatomic, assign) id<ChatBarProtocol> delegate;
@property (nonatomic, strong) KeyboardEmojiTextView *textView;


- (void)hideKeyboard;

@end
