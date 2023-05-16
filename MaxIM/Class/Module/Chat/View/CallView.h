/*
 *  Copyright 2015 The WebRTC Project Authors. All rights reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import <UIKit/UIKit.h>

#import <floo-ios/floo_proxy.h>

@class CallView;
@protocol CallViewDelegate <NSObject>

- (void)videoCallViewDidSwitchCamera:(CallView *)view;

- (void)videoCallViewDidSwitchToVoice:(CallView *)view;

- (void)videoCallViewDidHangup:(CallView *)view;

- (void)videoCallViewDidAnswer:(CallView *)view;

@end

// Video call view that shows local and remote video, provides a label to
// display status, and also a hangup button.
@interface CallView : UIView

@property(nonatomic, readonly) UILabel *statusLabel;
@property(nonatomic, readonly) UIView *localVideoView;
@property(nonatomic, readonly) UIView *remoteVideoView;
@property(nonatomic, weak) id<CallViewDelegate> delegate;
@property(nonatomic, assign) BOOL isCaller;
@property(nonatomic, assign) BOOL hasVideo;
@property(nonatomic, assign) BOOL isConnected;
- (instancetype)initWithFrame:(CGRect)frame
                     isCaller:(BOOL)isCaller
                     hasVideo:(BOOL)hasVideo
                currentRoster:(BMXRosterItem *)roster;
@end
