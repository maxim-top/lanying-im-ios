#import <UIKit/UIKit.h>

@class LHChatBarView;
@class LHChatBarMoreView;
@class LHChatBarEmoticonView;
@class VideoView;

@protocol LHChatBarViewDelegate <NSObject>

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

// 聊天输入条的模式
typedef NS_ENUM(NSInteger, LHChatBarMode) {
    LHChatBarModeDefault,  // 缺省模式
    LHChatBarModeVoice,   // 语音模式
    LHChatBarModeKeyboard, // 键盘模式
    LHChatBarModeEmoticon, // 表情模式
    LHChatBarModeMore      // 更多模式
};
@class LHContentModel;

@interface LHChatBarView : UIView

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) id<LHChatBarViewDelegate> delegate;
@property (nonatomic, assign) LHChatBarMode currentMode;

@property (nonatomic, strong) UIButton *voiceBtn;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIButton *talkButton;
@property (nonatomic, strong) UIButton *emoticonButton;
@property (nonatomic, strong) UIButton *moreBtn;
@property (nonatomic, strong) void(^sendContent)(LHContentModel *content);

@property (nonatomic, strong) UIView *extensionView;
@property (nonatomic, strong) LHChatBarEmoticonView *emojiKeyboard;
@property (nonatomic, strong) LHChatBarMoreView *moreView;

- (void)hideKeyboard;
- (void)setText:(NSString *)text;

@end
