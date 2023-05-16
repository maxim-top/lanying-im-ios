//
//  LHChatInputView.m
//  LHChatUI
//
//  Created by hyt on 2016/12/22.
//  Copyright © 2016年 hyt. All rights reserved.
//

#import "LHChatBarView.h"
#import "KeyboardEmojiTextView.h"
#import "LHChatBarMoreView.h"
#import "KeyboardVC.h"
#import "LHContentModel.h"
#import "LHTools.h"
#import "TZImagePickerController.h"
#import "ICDocumentViewController.h"
#import <floo-ios/floo_proxy.h>

#import "VideoView.h"
#import "VideoManager.h"
#import "UIView+Addtions.h"
#import "AppDelegate.h"



CGFloat const kChatInputTextViewFont = 16.0f;
CGFloat const kChatEmojiHeight = 216.0f;
CGFloat const kChatMoreHeight = 130.0f + 20 + 55;
CGFloat const kChatBatItemWH = 26.0f;

@interface LHChatBarView () <UITextViewDelegate, LHChatBarMoreViewDelegate,TZImagePickerControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, ICDocumentDelegate, UIDocumentPickerDelegate> {
    UIViewAnimationCurve _animationCurve;
    CGFloat _animationDuration;
    CGFloat _keyboardHeight;
}

@property (nonatomic, strong) UIButton *voiceBtn;
@property (nonatomic, strong) UIButton *moreBtn;
@property (nonatomic, strong) UIButton *talkButton;
@property (nonatomic, strong) LHChatBarMoreView *moreView;
@property (nonatomic, strong) UIView *emojiView;
@property (nonatomic, strong) KeyboardVC *emojiKeyboardVC;

/** 是否正在切换键盘emoji */
@property (nonatomic, assign, getter=isEmojiKeyboard) BOOL emojiKeyboard;
/** 是否正在切换键盘more */
@property (nonatomic, assign, getter=isMoreKeyboard) BOOL moreKeyboard;
/** 是否系统键盘显示 */
@property (nonatomic, assign, getter=isShowingSystemKeyboard) BOOL showingSystemKeyboard;

@property (nonatomic, strong) LHPhotosModel *photos;
@property (nonatomic, strong) LHContentModel *contentModel;
@property (nonatomic, strong) UIView *videoView;

@property (nonatomic, strong) NSString *filePath;

@end

@implementation LHChatBarView


#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupSubViews];
        [self setupConfig];
    }
    return self;
}

- (void)setupSubViews {
    [self addSubview:self.textView];
    [self addSubview:self.voiceBtn];
    [self addSubview:self.moreBtn];
    [self addSubview:self.talkButton];
}

- (void)setupConfig {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.voiceBtn.frame = CGRectMake(MAXScreenW - 10 - kChatBatItemWH * 2 - 10 , self.height - kChatBatItemWH - 11, kChatBatItemWH, kChatBatItemWH);
    
    self.moreBtn.frame = CGRectMake(CGRectGetMaxX(self.voiceBtn.frame) + 10, self.height - kChatBatItemWH - 11, kChatBatItemWH, kChatBatItemWH);
    
//    CGFloat textViewX = CGRectGetMaxX(self.moreBtn.frame) + 10;

    self.textView.frame = CGRectMake(10, 7.5, MAXScreenW - kChatBatItemWH * 2  - 30 - 10, self.height - 15);
    
    self.talkButton.frame = CGRectMake(10, 7.5, MAXScreenW - kChatBatItemWH * 2  -30 -10, self.height - 15);
    
}

#pragma mark - 事件监听
/**
 *  键盘弹出
 *
 *  @param notice 通知
 */
- (void)keyboardWillShow:(NSNotification *)notice {
    self.showingSystemKeyboard = YES;
    self.moreBtn.selected = NO;
    self.voiceBtn.selected = NO;
    
    NSDictionary *userInfo = [notice userInfo];
    CGRect endFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    _keyboardHeight = (endFrame.origin.y != MAXScreenH) ? endFrame.size.height:0;
    if (!_keyboardHeight) return;
    
    CGRect beginRect = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect endRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    if(!(beginRect.size.height > 0 && ( fabs(beginRect.origin.y - endRect.origin.y) > 0))) return;
    
    _animationDuration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    _animationCurve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    [UIView animateWithDuration:_animationDuration delay:0 options:(_animationCurve << 16 | UIViewAnimationOptionBeginFromCurrentState) animations:^{
        // 修改frame
        self.y = MAXScreenH - self.height - _keyboardHeight;
        _tableView.height = self.y - kNavBarHeight;
//        [_conversationChatVC scrollToBottomAnimated:NO refresh:NO];
    } completion:nil];
    
    // 添加动画
    if (self.emojiKeyboard) { // 当前展示的是表情键盘
        [UIView animateWithDuration:_animationDuration delay:0 options:(_animationCurve << 16 | UIViewAnimationOptionBeginFromCurrentState) animations:^{
            self.emojiView.y = MAXScreenH - kChatEmojiHeight;
            [self.superview layoutIfNeeded];
        } completion:^(BOOL finished) {
            self.emojiView.y = MAXScreenH;
            self.moreView.y = MAXScreenH - kChatMoreHeight;
            [self.emojiView removeFromSuperview];
        }];
        
    } else if (self.isMoreKeyboard) { // 当前展示的是工具
        [UIView animateWithDuration:_animationDuration delay:0 options:(_animationCurve << 16 | UIViewAnimationOptionBeginFromCurrentState) animations:^{
            self.moreView.y = MAXScreenH - kChatMoreHeight;
            [self.superview layoutIfNeeded];
        } completion:^(BOOL finished) {
            [self.moreView removeFromSuperview];
        }];
    }
}


- (void)keyboardWillHide:(NSNotification *)noti {
    self.showingSystemKeyboard = NO;
    if (self.voiceBtn.selected || self.moreBtn.selected) return;
    self.moreBtn.selected = NO;
    self.voiceBtn.selected = NO;
    
    //获取键盘的高度
    NSDictionary *userInfo = [noti userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    _keyboardHeight = [aValue CGRectValue].size.height;
    
    CGFloat duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    [UIView animateWithDuration:duration delay:0 options:(curve << 16 | UIViewAnimationOptionBeginFromCurrentState) animations:^{
        self.y = MAXScreenH - self.height;
        _tableView.height = self.y - kNavBarHeight;
    } completion:nil];
}


// 点击语音按钮
- (void)voiceBtnClick:(UIButton *)voiceBtn {
    [self.moreView removeFromSuperview];
    self.moreKeyboard = NO;
    self.emojiKeyboard = YES;
    [self.talkButton setHidden:!self.talkButton.isHidden];
    [self.textView endEditing:YES];
    
    if (self.moreBtn.selected) { 
        self.moreBtn.selected = NO;
        [UIView animateWithDuration:0.25 animations:^{
            self.y = MAXScreenH  - self.height - (MAXIsFullScreen ? 34 : 0);
            _tableView.height = self.y - kNavBarHeight;
            self.emojiView.y = MAXScreenH ;
        }];
        
    }
}

// 点击工具按钮
- (void)moreBtnClick:(UIButton *)moreBtn {
    [self.talkButton setHidden:!self.talkButton.isHidden];
    
    [self.emojiView removeFromSuperview];
    self.emojiKeyboard = NO;
    UIView *moreView = self.moreView;
    
    if (self.voiceBtn.selected) { // 表情键盘有选中
        self.moreBtn.selected = YES;
        self.moreKeyboard = YES;
        if (!self.showingSystemKeyboard) {
            self.moreView.y = MAXScreenH;
        }
        
        self.emojiView.y = MAXScreenH;
        self.voiceBtn.selected = NO;
        [self.superview addSubview:moreView];
        // 2.更改inputToolBar 底部约束
        
        
        // 添加动画
        [UIView animateWithDuration:0.25 animations:^{
            self.y = MAXScreenH - kChatMoreHeight - self.height;
            _tableView.height = self.y - kNavBarHeight;
            moreView.y = MAXScreenH - kChatMoreHeight;
        }];
        
    } else { // 表情键盘没有选择
        moreBtn.selected = !moreBtn.selected;
        if (moreBtn.selected) {
            // 让vioce声音按钮,取消选择,隐藏录音按钮
            
            if (!self.showingSystemKeyboard) {
                self.moreView.y = MAXScreenH;
            }
            [self.textView resignFirstResponder];
            self.moreKeyboard = YES;
            [self.superview addSubview:moreView];
            // 2.更改inputToolBar 底部约束
            
            
            // 添加动画
            [UIView animateWithDuration:0.25 animations:^{
                self.y = MAXScreenH - kChatMoreHeight - self.height;
                _tableView.height = self.y - kNavBarHeight;
                
                moreView.y = MAXScreenH - kChatMoreHeight;
                // 4.把消息现在在顶部
//                [_conversationChatVC scrollToBottomAnimated:NO refresh:NO];
            }];
            
        } else {
            self.moreKeyboard = YES;
            [self.textView becomeFirstResponder];
        }
    }
}

#pragma mark - 公共方法
- (void)hideKeyboard {
    [self.superview endEditing:YES];
    
    // 添加动画
    [UIView animateWithDuration:0.25 animations:^{
        if (self.showingSystemKeyboard || self.voiceBtn.selected || self.moreBtn.selected) {
            self.moreView.y = MAXScreenH;
            self.emojiView.y = MAXScreenH;
        }
        self.y = MAXScreenH - self.height - (MAXIsFullScreen ? 34 : 0);
        _tableView.height = self.y - kNavBarHeight;
    } completion:^(BOOL finished) {
    }];
    self.moreBtn.selected = NO;
    self.voiceBtn.selected = NO;
}

#pragma mark - 私有方法
//重置状态
- (void)resetState {
    
    [UIView animateWithDuration:0.25 animations:^{
        self.height = kChatBarHeight;
        CGFloat keyboardHeight = _keyboardHeight;
        if (self.moreBtn.selected) {
            keyboardHeight = kChatMoreHeight;
        }
        else if (self.voiceBtn.selected) {
            keyboardHeight = kChatEmojiHeight;
        }
        self.y = MAXScreenH - self.height - keyboardHeight;
        _tableView.height = self.y - kNavBarHeight;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (!finished) return;
        self.contentModel = nil;
        _textView.text = @"";
        self.photos = nil;
    }];
}

- (NSRange)isPresenceExpressionWithText:(NSString *)text {
    NSInteger length = text.length;
    
    NSArray *array = [self emojiArrayWithText:text];
    
    NSInteger index = array.count;
    if (!index) return NSMakeRange(0, 0);
    while (index > 0) {
        index --;
        NSTextCheckingResult *result = array[index];
        if (length == result.range.location + result.range.length) {
            return result.range;
        }
    }
    return NSMakeRange(0, 0);
}

- (NSArray *)emojiArrayWithText:(NSString *)text {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\[\\w+\\]" options:NSRegularExpressionCaseInsensitive error:nil];
    
    return [regex matchesInString:text options:NSMatchingReportProgress range:NSMakeRange(0, text.length)];
}


- (void)deleteEmoji:(NSString *)text range:(NSRange)range {
    text = [text substringToIndex:range.location];
    self.textView.text = text;
    [self textViewDidChange:self.textView];
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
    imagePickerVc.allowPickingVideo = NO;
    imagePickerVc.allowTakePicture = NO;
    imagePickerVc.allowPickingOriginalPhoto = NO;
    imagePickerVc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.viewController presentViewController:imagePickerVc animated:YES completion:nil];
}

- (void)moreViewLocationAction:(LHChatBarMoreView *)moreView {
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
    
    static CGFloat maxHeight = 80.0f;
    CGRect frame = textView.frame;
    CGSize constraintSize = CGSizeMake(frame.size.width, MAXFLOAT);
    CGSize size = [textView sizeThatFits:constraintSize];
    if (size.height >= maxHeight) {
        size.height = maxHeight;
        textView.scrollEnabled = YES;   // 允许滚动
        [textView scrollRectToVisible:CGRectMake(0, textView.contentSize.height-7.5, textView.contentSize.width, 10) animated:NO];
    } else {
        textView.scrollEnabled = NO;    // 不允许滚动，当textview的大小足以容纳它的text的时候，需要设置scrollEnabed为NO，否则会出现光标乱滚动的情况
    }
    
    [UIView animateWithDuration:_animationDuration delay:0 options:(_animationCurve << 16 | UIViewAnimationOptionBeginFromCurrentState) animations:^{
        // 调整整个InputToolBar 的高度
        self.height = (15 + size.height) - kChatBarHeight < 5 ? kChatBarHeight : 15 + size.height;
        CGFloat keyboardHeight = _keyboardHeight;
        if (self.moreBtn.selected) {
            keyboardHeight = kChatMoreHeight;
        }
        else if (self.voiceBtn.selected) {
            keyboardHeight = kChatEmojiHeight;
        }
        
        self.y = MAXScreenH - self.height - keyboardHeight;
        _tableView.height = self.y - kNavBarHeight;
        [self layoutIfNeeded];
    } completion:nil];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (!text.length) {
        NSRange range = [self isPresenceExpressionWithText:textView.text];
        if (range.length) {
            [self deleteEmoji:textView.text range:range];
            return NO;
        }
        
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

#pragma mark - lazy
- (KeyboardEmojiTextView *)textView {
    if (!_textView) {
        LHWeakSelf
        _textView = [KeyboardEmojiTextView new];
        _textView.delegate = self;
        _textView.backgroundColor = [UIColor whiteColor];
        _textView.font = [UIFont systemFontOfSize:kChatInputTextViewFont];
        _textView.returnKeyType = UIReturnKeySend;
        _textView.enablesReturnKeyAutomatically = YES;
        _textView.layer.borderColor = [UIColor lh_colorWithHex:0xe1e1e5].CGColor;
        _textView.layer.borderWidth = 0.5;
        _textView.showsVerticalScrollIndicator = YES;
        _textView.showsHorizontalScrollIndicator = NO;
        _textView.layer.cornerRadius = 5;
        _textView.insertEmojiTextBlock = ^(UITextView *textView) {
            [weakSelf textViewDidChange:textView];
        };
        _textView.layoutManager.allowsNonContiguousLayout = NO;
    }
    return _textView;
}

- (UIButton *)voiceBtn {
    if (!_voiceBtn) {
        _voiceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_voiceBtn setImage:[UIImage imageNamed:@"record"] forState:UIControlStateNormal];
        [_voiceBtn setImage:[UIImage imageNamed:@"record"] forState:UIControlStateSelected];
        [_voiceBtn addTarget:self action:@selector(voiceBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _voiceBtn;
}

- (UIButton *)moreBtn {
    if (!_moreBtn) {
        _moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_moreBtn setImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
        [_moreBtn setImage:[UIImage imageNamed:@"more"] forState:UIControlStateSelected];
        [_moreBtn addTarget:self action:@selector(moreBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _moreBtn;
}

- (UIButton *)talkButton {
    if (_talkButton == nil) {
        _talkButton = [[UIButton alloc] init];
        [_talkButton setTitle:NSLocalizedString(@"Press_to_speak", @"按住 说话") forState:UIControlStateNormal];
        [_talkButton setTitle:NSLocalizedString(@"Release_to_end", @"松开 结束") forState:UIControlStateHighlighted];
        [_talkButton setTitleColor:[UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1.0] forState:UIControlStateNormal];
        [_talkButton.titleLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
        [_talkButton.layer setMasksToBounds:YES];
        [_talkButton.layer setCornerRadius:4.0f];
        [_talkButton.layer setBorderWidth:0.5f];
        [_talkButton setHidden:YES];
        [_talkButton addTarget:self action:@selector(talkButtonDown:) forControlEvents:UIControlEventTouchDown];
        [_talkButton addTarget:self action:@selector(talkButtonUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [_talkButton addTarget:self action:@selector(talkButtonUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
        [_talkButton addTarget:self action:@selector(talkButtonTouchCancel:) forControlEvents:UIControlEventTouchCancel];
        [_talkButton addTarget:self action:@selector(talkButtonDragOutside:) forControlEvents:UIControlEventTouchDragOutside];
        [_talkButton addTarget:self action:@selector(talkButtonDragInside:) forControlEvents:UIControlEventTouchDragInside];
    }
    return _talkButton;
}

- (LHChatBarMoreView *)moreView {
    if (!_moreView) {
        _moreView = [[LHChatBarMoreView alloc]initWithFrame:CGRectMake(0, MAXScreenH, MAXScreenW, kChatMoreHeight)];
        _moreView.backgroundColor = [UIColor lh_colorWithHex:0xf8f8f8];
        _moreView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        _moreView.delegate = self;
        [self.superview addSubview:_moreView];
    }
    return _moreView;
}

- (UIView *)emojiView {
    if (!_emojiView) {
        _emojiView = self.emojiKeyboardVC.view;
        _emojiView.frame = CGRectMake(0, MAXScreenH, MAXScreenW, kChatEmojiHeight);
        [self.emojiKeyboardVC.view layoutIfNeeded];
        [self.superview addSubview:_emojiView];
    }
    return _emojiView;
}

- (KeyboardVC *)emojiKeyboardVC {
    if (!_emojiKeyboardVC) {
        LHWeakSelf;
        _emojiKeyboardVC = [[KeyboardVC alloc] initWithCallBack:^(KeyboardEmojiModel *keyboardEmoticon) {
            [weakSelf.textView insertEmojiText:keyboardEmoticon];
        }];
        _emojiKeyboardVC.emojiSend = ^() {
            !weakSelf.sendContent ? : weakSelf.sendContent(weakSelf.contentModel);
            [weakSelf resetState];
        };
    }
    return _emojiKeyboardVC;
}

- (LHContentModel *)contentModel {
    return [LHContentModel contentModelWitiPhotos:self.photos words:self.textView.text];
}



#pragma mark -- Recoder
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
