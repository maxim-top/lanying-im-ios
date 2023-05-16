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
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) BMXRosterItem *currentRoster;
@end

@implementation CallView {
    UIButton *_routeChangeButton;
    UIButton *_cameraSwitchButton;
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

        self.avatarImageView.image = [UIImage imageNamed:@"profileavatar"];
        if ([self.currentRoster.avatarThumbnailPath length]) {
            UIImage *image = [UIImage imageWithContentsOfFile:self.currentRoster.avatarThumbnailPath];
            self.avatarImageView.image = image ? image : [UIImage imageNamed:@"profileavatar"];
        }
        
        _routeChangeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _routeChangeButton.backgroundColor = [UIColor whiteColor];
        _routeChangeButton.layer.cornerRadius = kButtonSize / 2;
        _routeChangeButton.layer.masksToBounds = YES;
        UIImage *image = [UIImage imageNamed:@"icon_call_switch_audio"];
        [_routeChangeButton setImage:image forState:UIControlStateNormal];
        [_routeChangeButton addTarget:self
                               action:@selector(onRouteChange:)
                     forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_routeChangeButton];
        
        // TODO(tkchin): don't display this if we can't actually do camera switch.
        _cameraSwitchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cameraSwitchButton.backgroundColor = [UIColor whiteColor];
        _cameraSwitchButton.layer.cornerRadius = kButtonSize / 2;
        _cameraSwitchButton.layer.masksToBounds = YES;
        image = [UIImage imageNamed:@"icon_call_switch_camera"];
        [_cameraSwitchButton setImage:image forState:UIControlStateNormal];
        [_cameraSwitchButton addTarget:self
                                action:@selector(onCameraSwitch:)
                      forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_cameraSwitchButton];
        
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
        [self avatarImageView];
    }
    return self;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        [self addSubview:_nameLabel];
        CGFloat nameLabelRight = 15;
        _nameLabel.size = CGSizeMake(80, 30);
        _nameLabel.bmx_top = self.avatarImageView.bmx_top + 3;
        _nameLabel.bmx_left = self.avatarImageView.bmx_right + nameLabelRight;
    }
    return _nameLabel;
}

- (UIImageView *)avatarImageView {
    if (!_avatarImageView) {        
        _avatarImageView = [[UIImageView alloc] init];
        [self addSubview:_avatarImageView];
    }
    return _avatarImageView;
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

    if (_avatarImageView) {
        CGSize avatarImageViewSize = CGSizeMake(171, 171);
        CGFloat avatarImageViewLeft = self.bmx_centerX - avatarImageViewSize.width/2;
        _avatarImageView.bmx_size = avatarImageViewSize;
        _avatarImageView.bmx_top = self.bmx_top + 160;
        _avatarImageView.bmx_left = avatarImageViewLeft;
    }

    //small view
    CGRect smallVideoFrame =  CGRectMake(0, 0, 180, 240);
    // Place the view in the bottom right.
    smallVideoFrame.origin.x = CGRectGetMaxX(bounds) - smallVideoFrame.size.width - kLocalVideoViewPadding;
    smallVideoFrame.origin.y = kButtonPadding;
    
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
    bigView.contentMode = UIViewContentModeScaleAspectFill;
    
    bigView.hidden = !_hasVideo;
    smallView.hidden = !_hasVideo || !_isConnected;
    
    _nameLabel.hidden = _hasVideo && _isConnected;
    _avatarImageView.hidden = _hasVideo && _isConnected;
    
    CGFloat y = CGRectGetMaxY(bounds) - 2 * kButtonSize; //y pos of buttons
    CGRect rectCenterBtn = CGRectMake(CGRectGetMaxX(bounds)/2 - kButtonSize/2,
                                     y,
                                     kButtonSize,
                                     kButtonSize);

    if (_isConnected) {
        _answerButton.hidden = YES;
        
        _routeChangeButton.hidden = NO;
        _cameraSwitchButton.hidden = NO;
        _hangupButton.hidden = NO;
        
        _routeChangeButton.frame = rectCenterBtn;
        _cameraSwitchButton.frame = rectCenterBtn;
        _hangupButton.frame = rectCenterBtn;

        if (!_hasVideo) {
            _routeChangeButton.hidden = YES;
            _cameraSwitchButton.hidden = YES;
        }else{
            _routeChangeButton.x -= kButtonSize + kButtonPadding;
            _hangupButton.x += kButtonSize + kButtonPadding;
        }
    }else{
        if (_isCaller) {
            _routeChangeButton.hidden = YES;
            _cameraSwitchButton.hidden = YES;
            _answerButton.hidden = YES;

            _hangupButton.hidden = NO;
            _hangupButton.frame = rectCenterBtn;
            
        }else{
            _routeChangeButton.hidden = YES;
            _cameraSwitchButton.hidden = YES;
            
            _hangupButton.hidden = NO;
            _answerButton.hidden = NO;
            
            _hangupButton.frame = rectCenterBtn;
            _answerButton.frame = rectCenterBtn;

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

- (void)onCameraSwitch:(id)sender {
    [_delegate videoCallViewDidSwitchCamera:self];
}

- (void)onRouteChange:(id)sender {
    [_delegate videoCallViewDidSwitchToVoice:self];
}

- (void)onHangup:(id)sender {
    [_delegate videoCallViewDidHangup:self];
}

- (void)onAnswer:(id)sender {
    [_delegate videoCallViewDidAnswer:self];
}

@end
