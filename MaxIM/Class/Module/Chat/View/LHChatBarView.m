#import "LHChatBarView.h"
#import "LHChatBarEmoticonView.h"
#import "LHChatBarMoreView.h"
#import "LHContentModel.h"
#import "LHTools.h"
#import "TZImagePickerController.h"
#import "ICDocumentViewController.h"
#import <floo-ios/floo_proxy.h>

#import "VideoView.h"
#import "VideoManager.h"
#import "UIView+Addtions.h"
#import "AppDelegate.h"
#import "MAXUtils.h"
#import "UIResponder+Router.h"

@interface LHChatBarView () <UITextViewDelegate, LHChatBarMoreViewDelegate,
TZImagePickerControllerDelegate, UINavigationControllerDelegate,
UIImagePickerControllerDelegate, ICDocumentDelegate, UIDocumentPickerDelegate>{
    UIViewAnimationCurve _animationCurve;
    CGFloat _animationDuration;
    CGFloat _keyboardHeight;
}

@property (nonatomic, strong) UIButton *emojiBtn;


@property (nonatomic, strong) UIView *inputAccessoryView;
@property (nonatomic, strong) LHPhotosModel *photos;
@property (nonatomic, strong) LHContentModel *contentModel;
@property (nonatomic, strong) UIView *videoView;
@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, strong) NSLayoutConstraint *textViewHeightConstraint; // 用于动态调整高度

@end

@implementation LHChatBarView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
        [self setupConfig];
        self.currentMode = LHChatBarModeDefault;
    }
    return self;
}

- (void)setupUI {
    // 语音按钮
    self.voiceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.voiceBtn setImage:[UIImage imageNamed:@"record"] forState:UIControlStateNormal];
    [self.voiceBtn addTarget:self action:@selector(voiceBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.voiceBtn];
    
    // 输入框
    self.textView = [[UITextView alloc] init];
    self.textView.font = [UIFont systemFontOfSize:16];
    self.textView.delegate = self;
    self.textView.layer.cornerRadius = 4;
    self.textView.layer.borderWidth = 0.5;
    self.textView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.textView.layoutManager.allowsNonContiguousLayout = NO;
    [self addSubview:self.textView];

    // 按住说话按钮
    self.talkButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.talkButton setTitle:NSLocalizedString(@"Press_to_speak", @"按住 说话") forState:UIControlStateNormal];
    [self.talkButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    self.talkButton.layer.cornerRadius = 4;
    self.talkButton.layer.borderWidth = 0.5;
    self.talkButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [self.talkButton addTarget:self action:@selector(talkButtonDown:) forControlEvents:UIControlEventTouchDown];
    [self.talkButton addTarget:self action:@selector(talkButtonUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.talkButton addTarget:self action:@selector(talkButtonUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
    [self.talkButton addTarget:self action:@selector(talkButtonTouchCancel:) forControlEvents:UIControlEventTouchCancel];
    [self.talkButton addTarget:self action:@selector(talkButtonDragOutside:) forControlEvents:UIControlEventTouchDragOutside];
    [self.talkButton addTarget:self action:@selector(talkButtonDragInside:) forControlEvents:UIControlEventTouchDragInside];

    self.talkButton.hidden = YES;
    [self addSubview:self.talkButton];
    
    // 表情按钮
    self.emoticonButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.emoticonButton setImage:[UIImage imageNamed:@"emoji"] forState:UIControlStateNormal];
    [self.emoticonButton addTarget:self action:@selector(emoticonButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.emoticonButton];
    
    // 更多按钮
    self.moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.moreBtn setImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
    [self.moreBtn addTarget:self action:@selector(moreBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.moreBtn];
    
    // 表情视图
    self.emojiKeyboard = [[LHChatBarEmoticonView alloc] init];
    self.emojiKeyboard.hidden = YES;
    __weak typeof(self) weakSelf = self;
    self.emojiKeyboard.didSelectEmoticon = ^(NSString *emoticon) {
        NSRange selectedRange = weakSelf.textView.selectedRange;
        NSString *text = weakSelf.textView.text;
        if ([emoticon isEqualToString:kEmoticonButtonBackspace]) {
            [weakSelf.textView deleteBackward];
        } else if ([emoticon isEqualToString:kEmoticonButtonSend]) {
            !weakSelf.sendContent ? : weakSelf.sendContent(weakSelf.contentModel);
            [weakSelf resetState];
        } else {
            NSString *newText = [text stringByReplacingCharactersInRange:selectedRange withString:emoticon];
            weakSelf.textView.text = newText;
            weakSelf.textView.selectedRange = NSMakeRange(selectedRange.location + emoticon.length, 0);
        }
        
        [self textViewChanged:weakSelf.textView];
    };
    [self addSubview:self.emojiKeyboard];
    
    // 更多功能视图
    self.moreView = [[LHChatBarMoreView alloc]initWithFrame:CGRectMake(0, MAXScreenH - kChatExtensionViewHeight, MAXScreenW, kChatExtensionViewHeight)];;
    self.moreView.delegate = self;
    self.moreView.hidden = YES;
    self.moreView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self addSubview:self.moreView];
    
    [self setupConstraints];
}

- (void)setupConfig {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - Keyboard Notifications

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    CGRect keyboardFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    _keyboardHeight = (keyboardFrame.origin.y != MAXScreenH) ? keyboardFrame.size.height:0;
    if (!_keyboardHeight) return;
    NSTimeInterval duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:(curve << 16)
                     animations:^{
        CGFloat y = MAXScreenH - (MAXIsFullScreen ? 83 : kChatBarHeight) - keyboardFrame.size.height;
        [self setTop: y];
        [self setTableViewHeight:y - kNavBarHeight];
        self.currentMode = LHChatBarModeKeyboard;
    } completion:nil];
    [self textViewChanged:self.textView];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    if (self.currentMode == LHChatBarModeDefault || self.currentMode == LHChatBarModeVoice) {
        NSDictionary *userInfo = notification.userInfo;
        CGRect keyboardFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        NSTimeInterval duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        UIViewAnimationCurve curve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
        
        [UIView animateWithDuration:duration
                              delay:0
                            options:(curve << 16)
                         animations:^{
            self.transform = CGAffineTransformIdentity;
            CGFloat y = MAXScreenH - (MAXIsFullScreen ? 83 : kChatBarHeight);
            [self setTop: y];
            [self setTableViewHeight:y - kNavBarHeight];
        } completion:nil];
    }
}

- (void)setupConstraints {
    // 设置自动布局约束
    self.voiceBtn.translatesAutoresizingMaskIntoConstraints = NO;
    self.textView.translatesAutoresizingMaskIntoConstraints = NO;
    self.talkButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.emoticonButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.moreBtn.translatesAutoresizingMaskIntoConstraints = NO;
    
    [NSLayoutConstraint activateConstraints:@[
        // 语音按钮约束
        [self.voiceBtn.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:8],
        [self.voiceBtn.topAnchor constraintEqualToAnchor:self.topAnchor constant:8],
        [self.voiceBtn.widthAnchor constraintEqualToConstant:32],
        [self.voiceBtn.heightAnchor constraintEqualToConstant:32],
        
        // 输入框约束
        [self.textView.leadingAnchor constraintEqualToAnchor:self.voiceBtn.trailingAnchor constant:8],
        [self.textView.topAnchor constraintEqualToAnchor:self.topAnchor constant:8],
        [self.textView.trailingAnchor constraintEqualToAnchor:self.emoticonButton.leadingAnchor constant:-8],
       ( self.textViewHeightConstraint = [self.textView.heightAnchor constraintEqualToConstant:kChatBarTextViewHeight]),
        
        // 按住说话按钮约束
        [self.talkButton.leadingAnchor constraintEqualToAnchor:self.voiceBtn.trailingAnchor constant:8],
        [self.talkButton.trailingAnchor constraintEqualToAnchor:self.emoticonButton.leadingAnchor constant:-8],
        [self.talkButton.topAnchor constraintEqualToAnchor:self.topAnchor constant:8],
        [self.talkButton.heightAnchor constraintEqualToConstant:kChatBarTextViewHeight],
        
        // 表情按钮约束
        [self.emoticonButton.leadingAnchor constraintEqualToAnchor:self.textView.trailingAnchor constant:8],
        [self.emoticonButton.topAnchor constraintEqualToAnchor:self.topAnchor constant:8],
        [self.emoticonButton.widthAnchor constraintEqualToConstant:32],
        [self.emoticonButton.heightAnchor constraintEqualToConstant:32],
        
        // 更多按钮约束
        [self.moreBtn.leadingAnchor constraintEqualToAnchor:self.emoticonButton.trailingAnchor constant:8],
        [self.moreBtn.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-8],
        [self.moreBtn.topAnchor constraintEqualToAnchor:self.topAnchor constant:8],
        [self.moreBtn.widthAnchor constraintEqualToConstant:32],
        [self.moreBtn.heightAnchor constraintEqualToConstant:32],
    ]];
    self.textViewHeightConstraint.priority = UILayoutPriorityDefaultHigh; // 优先级非必需，但有时可避免布局警告

    // 设置表情视图和更多功能视图的约束
    self.emojiKeyboard.translatesAutoresizingMaskIntoConstraints = NO;
    self.moreView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [NSLayoutConstraint activateConstraints:@[
        [self.emojiKeyboard.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [self.emojiKeyboard.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [self.emojiKeyboard.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
        [self.emojiKeyboard.heightAnchor constraintEqualToConstant:kChatExtensionViewHeight],
        [self.moreView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [self.moreView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [self.moreView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
        [self.moreView.heightAnchor constraintEqualToConstant:kChatExtensionViewHeight]
    ]];
}

#pragma mark - Mode Switching

- (void)setCurrentMode:(LHChatBarMode)currentMode {
    if (_currentMode == currentMode) return;
    
    _currentMode = currentMode;
    
    // 更新UI状态
    switch (currentMode) {
        case LHChatBarModeDefault:
            [self setupDefaultMode];
            break;
        case LHChatBarModeVoice:
            [self setupVoiceMode];
            break;
        case LHChatBarModeKeyboard:
            [self setupKeyboardMode];
            break;
        case LHChatBarModeEmoticon:
            [self setupEmoticonMode];
            break;
        case LHChatBarModeMore:
            [self setupMoreMode];
            break;
    }
}

- (void)setupDefaultMode {
    [self.voiceBtn setImage:[UIImage imageNamed:@"record"] forState:UIControlStateNormal];
    self.textView.hidden = NO;
    self.textViewHeightConstraint.constant = kChatBarTextViewHeight;
    self.talkButton.hidden = YES;
    self.emojiKeyboard.hidden = YES;
    self.moreView.hidden = YES;

    [self.emoticonButton setImage:[UIImage imageNamed:@"emoji"] forState:UIControlStateNormal];
    [self.moreBtn setImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
    
    [self.textView resignFirstResponder];

    CGFloat y = MAXScreenH - (MAXIsFullScreen ? 83 : kChatBarHeight);
    [self setTop: y];
    [self setTableViewHeight:y - kNavBarHeight];
}

- (void)setupVoiceMode {
    [self.voiceBtn setImage:[UIImage imageNamed:@"keyboard"] forState:UIControlStateNormal];
    self.textView.hidden = YES;
    self.textViewHeightConstraint.constant = kChatBarTextViewHeight;
    self.talkButton.hidden = NO;
    self.emojiKeyboard.hidden = YES;
    self.moreView.hidden = YES;
    [self.emoticonButton setImage:[UIImage imageNamed:@"emoji"] forState:UIControlStateNormal];
    [self.moreBtn setImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
    
    [self.textView resignFirstResponder];
    
    CGFloat y = MAXScreenH - (MAXIsFullScreen ? 83 : kChatBarHeight);
    [self setTop: y];
    [self setTableViewHeight:y - kNavBarHeight];
}

- (void)setupKeyboardMode {
    [self.voiceBtn setImage:[UIImage imageNamed:@"record"] forState:UIControlStateNormal];
    self.textView.hidden = NO;
    self.talkButton.hidden = YES;
    self.emojiKeyboard.hidden = YES;
    self.moreView.hidden = YES;
    [self.emoticonButton setImage:[UIImage imageNamed:@"emoji"] forState:UIControlStateNormal];
    [self.moreBtn setImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
    [self.textView becomeFirstResponder];
}

- (void)setupEmoticonMode {
    [self.voiceBtn setImage:[UIImage imageNamed:@"record"] forState:UIControlStateNormal];
    self.textView.hidden = NO;
    self.talkButton.hidden = YES;
    [self.emoticonButton setImage:[UIImage imageNamed:@"keyboard"] forState:UIControlStateNormal];
    [self.moreBtn setImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
    
    [self showEmoticonView];
    [self.textView resignFirstResponder];
}

- (void)setupMoreMode {
    [self.voiceBtn setImage:[UIImage imageNamed:@"record"] forState:UIControlStateNormal];
    self.textView.hidden = NO;
    self.talkButton.hidden = YES;
    [self.emoticonButton setImage:[UIImage imageNamed:@"emoji"] forState:UIControlStateNormal];
    [self.moreBtn setImage:[UIImage imageNamed:@"keyboard"] forState:UIControlStateNormal];
    
    [self showMoreView];
    [self.textView resignFirstResponder];
}

#pragma mark - Button Actions

- (void)voiceBtnTapped {
    if (self.currentMode == LHChatBarModeVoice) {
        self.currentMode = LHChatBarModeKeyboard;
    } else {
        self.currentMode = LHChatBarModeVoice;
    }
}

- (void)emoticonButtonTapped {
    if (self.currentMode == LHChatBarModeEmoticon) {
        self.currentMode = LHChatBarModeKeyboard;
    } else {
        self.currentMode = LHChatBarModeEmoticon;
    }
}

- (void)moreBtnTapped {
    if (self.currentMode == LHChatBarModeMore) {
        self.currentMode = LHChatBarModeKeyboard;
    } else {
        self.currentMode = LHChatBarModeMore;
    }
}

- (LHContentModel *)contentModel {
    return [LHContentModel contentModelWitiPhotos:self.photos words:self.textView.text];
}

#pragma mark - Extension View Animation

- (void)showEmoticonView {
    self.emojiKeyboard.hidden = NO;
    self.moreView.hidden = YES;
    [self textViewChanged:self.textView];
}

- (void)showMoreView {
    self.emojiKeyboard.hidden = YES;
    self.moreView.hidden = NO;
    [self textViewChanged:self.textView];
}

#pragma mark - LHChatBarMoreViewDelegate
- (void)moreViewTakePicAction:(LHChatBarMoreView *)moreView {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"错误")
                                                            message:NSLocalizedString(@"No_camera_on_device", @"设备没有摄像头")
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"好的")
                                                  otherButtonTitles: nil];
        [alertView show];
    } else {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = NO;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        if (![LHTools cameraLimit]) {
            UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"allow_LHChatUI_to_access_your_camera", @"请在iPhone的设置-隐私-相机选项中,允许LHChatUI访问你的相机") delegate:nil cancelButtonTitle:NSLocalizedString(@"Confirm", @"确定") otherButtonTitles:nil, nil];
            [alertView show];
            return;
        }
        picker.modalPresentationStyle = UIModalPresentationFullScreen;
        [self.viewController presentViewController:picker animated:YES completion:nil];
    }
}


- (void)moreViewPhotoAction:(LHChatBarMoreView *)moreVie {
    if (![LHTools photoLimit]) {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"allow_LHChatUI_to_access_your_photos", @"请在iPhone的设置-隐私-照片选项中,允许LHChatUI访问你的照片") delegate:nil cancelButtonTitle:NSLocalizedString(@"Confirm", @"确定") otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:9 delegate:self];
    imagePickerVc.alwaysEnableDoneBtn = NO;
    imagePickerVc.allowPickingVideo = YES;
    imagePickerVc.allowTakePicture = NO;
    imagePickerVc.allowPickingOriginalPhoto = NO;
    imagePickerVc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.viewController presentViewController:imagePickerVc animated:YES completion:nil];
}

-(void)showAlertForPermissionError {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"permission_required", @"权限不足") message:NSLocalizedString(@"permission_need_enabled", @"此业务需要开通，请联系App管理员。") preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", @"确定") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    
    [self.viewController presentViewController:alertController animated:YES completion:nil];
}

- (void)moreViewLocationAction:(LHChatBarMoreView *)moreView {
    bool disableSendLocation = [MAXUtils getAppSwitch:@"disable_send_location"];
    if (disableSendLocation) {
        [self showAlertForPermissionError];
        return;
    }
    // 进入定位页面，获取定位信息
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatViewSendLocation)]) {
 
        [self.delegate chatViewSendLocation];
    }
}

- (void)moreViewFileAction:(LHChatBarMoreView *)moreView {
     // 进入页面管理，选择文件
    
    if (SystemVersion >=  11.0) {
        [self displayChooseFileViewController];
    } else {
        ICDocumentViewController *docVC = [[ICDocumentViewController alloc] init];
        docVC.delegate = self;
        NSString *filePath = [[[[BMXClient sharedClient] chatService] attachmentDir] stringByAppendingPathComponent:@"file"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:filePath]) {
            [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
            
            NSString *testFile = @"test";
            [testFile writeToFile:[filePath stringByAppendingPathComponent:@"test.text"] atomically:YES encoding:NSUTF8StringEncoding error:nil];
            
        }
        docVC.filePath = filePath;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:docVC];
        nav.modalPresentationStyle = UIModalPresentationFullScreen;
        [self.viewController presentViewController:nav animated:YES completion:nil];
    }
}

- (void)moreViewVideoAction:(LHChatBarMoreView *)moreView {

    MAXLog(@"点击小视频");
    
    [self resignFirstResponder];
    if (![[VideoManager shareManager] canRecordViedo]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"allow_MaxIM_to_access_your_camera_and_microphone", @"请在iPhone的设置-隐私选项中，允许Lanying IM访问你的摄像头和麦克风。") message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"Confirm", @"确定") otherButtonTitles:nil, nil];
        [alert show];
    } else {
        [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(videoViewWillAppear) userInfo:nil repeats:NO]; // 待动画完成
    }
}

- (void)moreViewVideoCallAction:(LHChatBarMoreView *)moreView {
    MAXLog(@"点击视频通话");
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatViewVideoCall)]) {
        [self.delegate chatViewVideoCall];
    }
}

- (void)moreViewVoiceCallAction:(LHChatBarMoreView *)moreView {
    MAXLog(@"点击语音通话");
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatViewVoiceCall)]) {
        [self.delegate chatViewVoiceCall];
    }
}

- (void)videoViewWillAppear {
    VideoView *videoView = [[VideoView alloc] initWithFrame:CGRectMake(0, 0, MAXScreenW, MAXScreenH)];
    UIWindow *window = ((AppDelegate *)[UIApplication sharedApplication].delegate).window;
    [self.viewController.view addSubview:videoView];
    self.videoView = videoView;
    videoView.hidden = YES;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatViewSendVideoWithVideoView:)]) {
        [self.delegate chatViewSendVideoWithVideoView:videoView];
    }
}

- (void)displayChooseFileViewController {
    NSArray *documentTypes = @[@"public.content",
                        @"public.text",
                        @"public.source-code",
                        @"public.image",
                        @"public.audiovisual-content",
                        @"com.adobe.pdf",
                        @"com.apple.keynote.key",
                        @"com.microsoft.word.doc",
                        @"com.microsoft.excel.xls",
                        @"com.microsoft.powerpoint.ppt"];
    UIDocumentPickerViewController *vc = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:documentTypes inMode:UIDocumentPickerModeOpen];
//    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];

    vc.delegate = self;
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.viewController presentViewController:vc animated:YES completion:nil];}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    [self textViewChanged:textView];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (!text.length) {
        return YES;
    }
    else {
        if ([text isEqualToString:@"@"]) {
            [self.delegate inputat];
        }
        // 判断按了return(send) 调用发送内容的方法
        if ([text isEqualToString:@"\n"]) {
            !self.sendContent ? : self.sendContent(self.contentModel);
            [self resetState];
            return NO;
        }
        return YES;
    }
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ChatTextFieldBegin" object:nil];
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ChatTextFieldEnd" object:nil];
    return YES;
    
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    // 发送拍摄图片
    UIImage *orgImage = info[UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    self.photos = [LHPhotosModel photosModelWitiPhotos:@[orgImage] originalPhoto:NO];
    !self.sendContent ? : self.sendContent(self.contentModel);
    [self resetState];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - TZImagePickerControllerDelegate
// 相册选的图片
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto {
    self.photos = [LHPhotosModel photosModelWitiPhotos:photos originalPhoto:isSelectOriginalPhoto];
    !self.sendContent ? : self.sendContent(self.contentModel);
    [self resetState];
}

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(PHAsset *)asset {
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.version = PHVideoRequestOptionsVersionOriginal; // 获取原始视频
    __weak typeof(self) weakSelf = self;

    [[PHImageManager defaultManager] requestAVAssetForVideo:asset
                                                       options:options
                                                 resultHandler:^(AVAsset * _Nullable avAsset,
                                                                 AVAudioMix * _Nullable audioMix,
                                                                 NSDictionary * _Nullable info) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if ([avAsset isKindOfClass:[AVURLAsset class]]) {
            AVURLAsset *urlAsset = (AVURLAsset *)avAsset;
            NSURL *videoURL = urlAsset.URL;
            NSDictionary *userInfo = @{VideoPathKey : videoURL.path};
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf routerEventWithName:GXRouterEventVideoRecordFinish userInfo:userInfo];
            });
        }
    }];
}

#pragma mark - ICDocumentDelegate
- (void)selectedFileName:(NSString *)fileName {
    MAXLog(@"%@", fileName);

    if (fileName.length > 0) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(chatViewSelectedFile:)]) {
            [self.delegate chatViewSelectedFile:fileName];
        }
    }
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url {
    MAXLog(@"%@", url);
    
    BOOL fileUrlAuthozied = [url startAccessingSecurityScopedResource];
    if (fileUrlAuthozied) {
        
        NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc] init];
        NSError *error;
        
        [fileCoordinator coordinateReadingItemAtURL:url options:0 error:&error byAccessor:^(NSURL *newURL) {
            //读取文件
            NSString *fileName = [newURL lastPathComponent];
            NSError *error = nil;
            NSData *fileData = [NSData dataWithContentsOfURL:newURL options:NSDataReadingMappedIfSafe error:&error];
            if (error) {
                //读取出错
            } else {
                if (self.delegate && [self.delegate respondsToSelector:@selector(chatViewSelectedFileData:displayName:)]) {
                    [self.delegate chatViewSelectedFileData:fileData displayName:fileName];
                }
            }
        }];
       
        [url stopAccessingSecurityScopedResource];

    }
}

#pragma mark - 公共方法
- (void)hideKeyboard {
    if (self.currentMode != LHChatBarModeDefault && self.currentMode != LHChatBarModeVoice) {
        self.currentMode = LHChatBarModeDefault;
    }
}

- (void)setText:(NSString *)text {
    self.textView.text = text;

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.textView becomeFirstResponder];
        NSRange endRange = NSMakeRange(self.textView.text.length, 0);
        self.textView.selectedRange = endRange;
    });
}

#pragma mark - 私有方法
//重置状态
- (void)resetState {
    [self hideKeyboard];
    [UIView animateWithDuration:0.25 animations:^{
        CGFloat y = MAXScreenH - (MAXIsFullScreen ? 83 : kChatBarHeight);
        [self setTop: y];
        [self setTableViewHeight:y - kNavBarHeight];

        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (!finished) return;
        self.contentModel = nil;
        _textView.text = @"";
        self.photos = nil;
    }];
}

- (void)textViewChanged:(UITextView *)textView {
    if (textView != self.textView) {
        return;
    }
    static CGFloat maxHeight = 80.0f;
    CGRect frame = textView.frame;
    CGSize constraintSize = CGSizeMake(frame.size.width, MAXFLOAT);
    CGSize size = [textView sizeThatFits:constraintSize];
    self.textViewHeightConstraint.constant = size.height;
    if (size.height >= maxHeight) {
        size.height = maxHeight;
        self.textViewHeightConstraint.constant = size.height;
        textView.scrollEnabled = YES;   // 允许滚动
        [textView scrollRectToVisible:CGRectMake(0, textView.contentSize.height-7.5, textView.contentSize.width, 10) animated:NO];
    } else {
        textView.scrollEnabled = NO;    // 不允许滚动，当textview的大小足以容纳它的text的时候，需要设置scrollEnabed为NO，否则会出现光标乱滚动的情况
    }
    
    [UIView animateWithDuration:_animationDuration delay:0 options:(_animationCurve << 16 | UIViewAnimationOptionBeginFromCurrentState) animations:^{
        CGFloat keyboardHeight = self->_keyboardHeight;
        if (self.currentMode == LHChatBarModeMore || self.currentMode == LHChatBarModeEmoticon) {
            keyboardHeight = kChatExtensionViewHeight;
        } else if(self.currentMode == LHChatBarModeDefault){
            keyboardHeight = 0;
        }
        self.height = (size.height < kChatBarTextViewHeight ? (MAXIsFullScreen ? 83 : kChatBarHeight) : (size.height + 50)) + keyboardHeight;
        CGFloat y = MAXScreenH - self.height;
        [self setTop: y];
        [self setTableViewHeight:y - kNavBarHeight];
        [self layoutIfNeeded];
    } completion:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setTop:(CGFloat)y{
    self.y = y;
}

- (void)setTableViewHeight:(CGFloat)h{
    self.tableView.height = h;
}

#pragma mark - Voice Recording
// 说话按钮
- (void)talkButtonDown:(UIButton *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatViewDidStartRecordingVoice:)]) {
        [self.delegate chatViewDidStartRecordingVoice:self];
    }
}

- (void)talkButtonUpInside:(UIButton *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatViewDidStopRecordingVoice:)]) {
        [self.delegate chatViewDidStopRecordingVoice:self];
    }
}

- (void)talkButtonUpOutside:(UIButton *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatViewDidCancelRecordingVoice:)]) {
        [self.delegate chatViewDidCancelRecordingVoice:self];
    }
}

- (void)talkButtonDragOutside:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(chatViewDidDrag:)]) {
        [self.delegate chatViewDidDrag:NO];
    }
}

- (void)talkButtonDragInside:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(chatViewDidDrag:)]) {
        [self.delegate chatViewDidDrag:YES];
    }
}

- (void)talkButtonTouchCancel:(UIButton *)sender
{
    
}


@end
