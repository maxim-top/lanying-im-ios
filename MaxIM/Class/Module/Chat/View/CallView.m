/*
 *  Copyright 2015 The WebRTC Project Authors. All rights reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import "CallView.h"

#import <AVFoundation/AVFoundation.h>

#import <WebRTC/RTCEAGLVideoView.h>
#if defined(RTC_SUPPORTS_METAL)
#import <WebRTC/RTCMTLVideoView.h>
#endif
#import "UIView+BMXframe.h"


static CGFloat const kButtonPadding = 40;
static CGFloat const kButtonSize = 60;
static CGFloat const kLocalVideoViewPadding = 8;

@interface CallView () <RTCVideoViewDelegate>
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *durationLabel;
@property (nonatomic, strong) UIImageView *remoteImageView;
@property (nonatomic, strong) UIImageView *myImageView;
@property (nonatomic, strong) BMXRosterItem *currentRoster;
@property(nonatomic, assign) bool cameraOn;//摄像头打开
@property(nonatomic, assign) long duration;//通话计时（秒）
@property (nonatomic, strong) NSTimer *timer; //通话计时器
@end

@implementation CallView {
    UIButton *_cameraButton;
    UIButton *_camerasSwitchButton;
    UIButton *_micButton;
    UIButton *_speakerButton;
    UIButton *_hangupButton;
    UIButton *_answerButton;
    CGSize _remoteVideoSize;
}

- (instancetype)initWithFrame:(CGRect)frame
                     isCaller:(BOOL)isCaller
                     hasVideo:(BOOL)hasVideo
                currentRoster:(BMXRosterItem *)roster{
    if (self = [super initWithFrame:frame]) {
        [self setBackgroundColor:[UIColor blackColor]];
        _remoteVideoSize = CGSizeMake(360, 480);
        _isCaller = isCaller;
        _hasVideo = hasVideo;
        _isConnected = NO;
        _currentRoster = roster;
        _cameraOn = YES;
        if (_hasVideo) {
#if defined(RTC_SUPPORTS_METAL)
            _remoteVideoView = [[RTCMTLVideoView alloc] initWithFrame:CGRectZero];
#else
            RTCEAGLVideoView *remoteView = [[RTCEAGLVideoView alloc] initWithFrame:CGRectZero];
            remoteView.delegate = self;
            _remoteVideoView = remoteView;
#endif
            
            [self addSubview:_remoteVideoView];
            
            _localVideoView = [[UIView alloc] initWithFrame:CGRectZero];
            [self addSubview:_localVideoView];
        }
        
        if ([self.currentRoster.username length]) {
            self.nameLabel.text = [NSString stringWithFormat:@"%@", [self.currentRoster.nickname length] ? self.currentRoster.nickname : self.currentRoster.username];
            [self.nameLabel sizeToFit];
        }

        if ([self.currentRoster.avatarThumbnailPath length]) {
            UIImage *image = [UIImage imageWithContentsOfFile:self.currentRoster.avatarThumbnailPath];
            self.remoteImageView.image = image ? image : [UIImage imageNamed:@"profileavatar"];
        }
        self.myImageView.image = [UIImage imageNamed:@"profileavatar"];
        self.myImageView.backgroundColor = [UIColor lh_colorWithHex:0xdddddd alpha:0.4];

        _cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cameraButton.backgroundColor = [UIColor whiteColor];
        _cameraButton.layer.cornerRadius = kButtonSize / 2;
        _cameraButton.layer.masksToBounds = YES;
        UIImage *image = [UIImage imageNamed:@"icon_call_camera"];
        [_cameraButton setImage:image forState:UIControlStateNormal];
        [_cameraButton addTarget:self
                               action:@selector(onCamera:)
                     forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_cameraButton];
        
        _micButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _micButton.backgroundColor = [UIColor whiteColor];
        _micButton.layer.cornerRadius = kButtonSize / 2;
        _micButton.layer.masksToBounds = YES;
        image = [UIImage imageNamed:@"icon_call_mic"];
        [_micButton setImage:image forState:UIControlStateNormal];
        [_micButton addTarget:self
                               action:@selector(onSwitchMic:)
                     forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_micButton];
        
        _speakerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _speakerButton.backgroundColor = [UIColor whiteColor];
        _speakerButton.layer.cornerRadius = kButtonSize / 2;
        _speakerButton.layer.masksToBounds = YES;
        image = [UIImage imageNamed:@"icon_call_speaker"];
        [_speakerButton setImage:image forState:UIControlStateNormal];
        [_speakerButton addTarget:self
                               action:@selector(onSwitchSoundOutputDevice:)
                     forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_speakerButton];

        // TODO(tkchin): don't display this if we can't actually do camera switch.
        _camerasSwitchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _camerasSwitchButton.layer.cornerRadius = kButtonSize / 2;
        _camerasSwitchButton.layer.masksToBounds = YES;
        image = [UIImage imageNamed:@"icon_call_switch_camera_big"];
        [_camerasSwitchButton setImage:image forState:UIControlStateNormal];
        [_camerasSwitchButton addTarget:self
                                action:@selector(onCamerasSwitch:)
                      forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_camerasSwitchButton];
        
        _hangupButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _hangupButton.backgroundColor = [UIColor redColor];
        _hangupButton.layer.cornerRadius = kButtonSize / 2;
        _hangupButton.layer.masksToBounds = YES;
        image = [UIImage imageNamed:@"icon_call_hangup"];
        [_hangupButton setImage:image forState:UIControlStateNormal];
        [_hangupButton addTarget:self
                          action:@selector(onHangup:)
                forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_hangupButton];
        
        _answerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _answerButton.backgroundColor = [UIColor redColor];
        _answerButton.layer.cornerRadius = kButtonSize / 2;
        _answerButton.layer.masksToBounds = YES;
        image = [UIImage imageNamed:@"icon_call_answer"];
        [_answerButton setImage:image forState:UIControlStateNormal];
        [_answerButton addTarget:self
                          action:@selector(onAnswer:)
                forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_answerButton];
        
        _statusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _statusLabel.font = [UIFont fontWithName:@"Roboto" size:16];
        _statusLabel.textColor = [UIColor whiteColor];
        [self addSubview:_statusLabel];
        
        [self nameLabel];
        [self durationLabel];
        [self remoteImageView];
        [self myImageView];
    }
    return self;
}

- (void)dealloc {
    if (_timer){
        [_timer invalidate];
        _timer  = nil;
    }
}

- (void)setConnected:(BOOL)isConnected {
    _isConnected = isConnected;
    if (isConnected){
        _duration = 0;
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
            _duration++;
            _durationLabel.text = [NSString stringWithFormat:@"%02d:%02d",_duration/60, _duration%60];
        }];
    }
}

- (UILabel *)durationLabel {
    if (!_durationLabel) {
        _durationLabel = [[UILabel alloc] init];
        [self addSubview:_durationLabel];
    }
    return _durationLabel;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        [self addSubview:_nameLabel];
        CGFloat nameLabelRight = 15;
        _nameLabel.size = CGSizeMake(80, 30);
        _nameLabel.bmx_top = self.remoteImageView.bmx_top + 3;
        _nameLabel.bmx_left = self.remoteImageView.bmx_right + nameLabelRight;
    }
    return _nameLabel;
}

- (UIImageView *)remoteImageView {
    if (!_remoteImageView) {        
        _remoteImageView = [[UIImageView alloc] init];
        [self addSubview:_remoteImageView];
    }
    return _remoteImageView;
}

- (UIImageView *)myImageView {
    if (!_myImageView) {
        _myImageView = [[UIImageView alloc] init];
        [self addSubview:_myImageView];
    }
    return _myImageView;
}

- (void)layoutSubviews {
    [self setBackgroundColor:[UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1]];
    CGRect bounds = self.bounds;
    CGFloat ratioVideo = _remoteVideoSize.width/_remoteVideoSize.height;
    CGFloat ratioBounds = bounds.size.width/bounds.size.height;
    CGFloat scale = 1;
    CGRect bigVideoFrame = CGRectMake(0, 0, _remoteVideoSize.width, _remoteVideoSize.height);
    if (ratioVideo > ratioBounds) {
        scale = bounds.size.height / _remoteVideoSize.height;
    }else {
        scale = bounds.size.width / _remoteVideoSize.width;
    }
    
    bigVideoFrame.size.height *= scale;
    bigVideoFrame.size.width *= scale;
    CGFloat diffHeight = bigVideoFrame.size.height - bounds.size.height;
    CGFloat diffWidth = bigVideoFrame.size.width - bounds.size.width;
    if (diffHeight > 1) {
        bigVideoFrame.origin.y -= diffHeight/2;
    }
    if (diffWidth > 1) {
        bigVideoFrame.origin.x -= diffWidth/2;
    }
    
    if (_nameLabel) {
        _nameLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:20];
        _nameLabel.textColor = [UIColor whiteColor];
        _nameLabel.textAlignment = NSTextAlignmentCenter;

        CGFloat nameLabelLeft = self.bmx_centerX - 40;
        _nameLabel.bmx_size = CGSizeMake(80, 30);
        _nameLabel.bmx_top = self.bmx_top + 100;
        _nameLabel.bmx_left = nameLabelLeft;
    }
    
    if (_durationLabel && _isConnected) {
        _durationLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:20];
        _durationLabel.textColor = [UIColor whiteColor];
        _durationLabel.textAlignment = NSTextAlignmentCenter;

        CGFloat labelLeft = self.bmx_centerX - 40;
        _durationLabel.bmx_size = CGSizeMake(80, 30);
        _durationLabel.bmx_top = self.bmx_top + 60;
        _durationLabel.bmx_left = labelLeft;
    }

    if (_remoteImageView) {
        CGSize avatarImageViewSize = CGSizeMake(171, 171);
        CGFloat avatarImageViewLeft = self.bmx_centerX - avatarImageViewSize.width/2;
        _remoteImageView.bmx_size = avatarImageViewSize;
        _remoteImageView.bmx_top = self.bmx_top + 160;
        _remoteImageView.bmx_left = avatarImageViewLeft;
    }

    //small view
    CGRect smallVideoFrame =  CGRectMake(0, 0, 180, 240);
    // Place the view in the bottom right.
    smallVideoFrame.origin.x = CGRectGetMaxX(bounds) - smallVideoFrame.size.width - kLocalVideoViewPadding;
    smallVideoFrame.origin.y = kButtonPadding;
    
    if (_myImageView) {
        _myImageView.frame = smallVideoFrame;
    }

    UIView *bigView = _localVideoView;
    UIView *smallView = _remoteVideoView;
    if (_isConnected) {
        bigView = _remoteVideoView;
        smallView = _localVideoView;
    }
    bigView.frame = bigVideoFrame;
    smallView.frame = smallVideoFrame;
    NSUInteger smallIndex = [[self subviews] indexOfObject:smallView];
    NSUInteger bigIndex = [[self subviews] indexOfObject:bigView];
    if (smallIndex < bigIndex) {
        [self exchangeSubviewAtIndex:smallIndex withSubviewAtIndex:bigIndex];
    }
    bigView.clipsToBounds = YES;
    
    bigView.hidden = !_hasVideo;
    smallView.hidden = !_hasVideo || !_isConnected;
    
    _nameLabel.hidden = _hasVideo && _isConnected;
    _durationLabel.hidden = !_isConnected;
    _remoteImageView.hidden = _hasVideo && _isConnected;
    _myImageView.hidden = _cameraOn;
    _localVideoView.hidden = !_cameraOn;
    
    UIImage *image = [UIImage imageNamed: _isConnected ? @"icon_call_switch_camera":@"icon_call_switch_camera_big"];
    [_camerasSwitchButton setImage:image forState:UIControlStateNormal];

    CGFloat y = CGRectGetMaxY(bounds) - 2 * kButtonSize; //y pos of buttons
    CGRect rectCenterBtn = CGRectMake(CGRectGetMaxX(bounds)/2 - kButtonSize/2,
                                     y,
                                     kButtonSize,
                                     kButtonSize);

    _micButton.frame = rectCenterBtn;
    _speakerButton.frame = rectCenterBtn;
    _cameraButton.frame = rectCenterBtn;
    _camerasSwitchButton.frame = rectCenterBtn;
    _hangupButton.frame = rectCenterBtn;
    _answerButton.frame = rectCenterBtn;
    
    _micButton.hidden = YES;
    _speakerButton.hidden = YES;
    _cameraButton.hidden = YES;
    _camerasSwitchButton.hidden = YES;
    _hangupButton.hidden = NO;
    _answerButton.hidden = YES;

    _speakerButton.x += kButtonSize + kButtonPadding;
    _micButton.x -= kButtonSize + kButtonPadding;
    if (_isConnected) {
        if (!_hasVideo) {
            _micButton.hidden = NO;
            _speakerButton.hidden = NO;
        }else{
            _micButton.hidden = NO;
            _speakerButton.hidden = NO;
            _cameraButton.hidden = NO;
            _camerasSwitchButton.hidden = NO;
            
            _camerasSwitchButton.x += kButtonSize + kButtonPadding;
            
            _cameraButton.y -= kButtonSize + kButtonPadding;
            _micButton.y -= kButtonSize + kButtonPadding;
            _speakerButton.y -= kButtonSize + kButtonPadding;
        }
    }else{
        if (_isCaller) {
            if (_hasVideo){
                _cameraButton.hidden = NO;
                _camerasSwitchButton.hidden = NO;
                
                _camerasSwitchButton.x += kButtonSize + kButtonPadding;
                _cameraButton.x -= kButtonSize + kButtonPadding;
            }else{
                _micButton.hidden = NO;
                _speakerButton.hidden = NO;
            }
        }else{
            _answerButton.hidden = NO;

            _answerButton.x += kButtonSize + kButtonPadding;
            _hangupButton.x -= kButtonSize + kButtonPadding;

        }
    }
    
    [_statusLabel sizeToFit];
    _statusLabel.center =
    CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
}

#pragma mark - RTCVideoViewDelegate

- (void)videoView:(id<RTCVideoRenderer>)videoView didChangeVideoSize:(CGSize)size {
    if ((UIView *)videoView == _remoteVideoView) {
        _remoteVideoSize = size;
        [self layoutSubviews];
    }
    [self setNeedsLayout];
}

#pragma mark - Private

- (void)onCamerasSwitch:(id)sender {
    [_delegate videoCallViewDidSwitchCameras:self];
}

- (void)onCamera:(id)sender {
    _cameraOn = [_delegate videoCallViewDidSwitchCamera:self];
    UIImage *image = [UIImage imageNamed:_cameraOn ? @"icon_call_camera" : @"icon_call_camera_off"];
    [_cameraButton setImage:image forState:UIControlStateNormal];
    _localVideoView.hidden = !_cameraOn;
    _myImageView.hidden = _cameraOn || !_isConnected;
}

- (void)onSwitchSoundOutputDevice:(id)sender {
    bool speakerOn = [_delegate videoCallViewDidSwitchSoundOutputDevice:self];
    UIImage *image = [UIImage imageNamed:speakerOn ? @"icon_call_speaker" : @"icon_call_speaker_off"];
    [_speakerButton setImage:image forState:UIControlStateNormal];
}

- (void)onSwitchMic:(id)sender {
    bool micOn = [_delegate videoCallViewDidSwitchMic:self];
    UIImage *image = [UIImage imageNamed:micOn ? @"icon_call_mic" : @"icon_call_mic_off"];
    [_micButton setImage:image forState:UIControlStateNormal];
}

- (void)onHangup:(id)sender {
    [_delegate videoCallViewDidHangup:self];
}

- (void)onAnswer:(id)sender {
    [_delegate videoCallViewDidAnswer:self];
}

@end
