//
//  ICAVPlayer.m
//  XZ_WeChat
//
//  Created by guoxianzhuang on 16/7/6.
//  Copyright © 2016年 gxz All rights reserved.
//

#import "ICAVPlayer.h"
#import "VideoTool.h"

@interface ICAVPlayer ()

@property (nonatomic, weak) UIView *fromView;
@property (nonatomic, weak) UIView *toContainerView;
@property (nonatomic, assign) BOOL fromNavigationBarHidden;

@end

@implementation ICAVPlayer

- (instancetype)initWithPlayerURL:(NSURL *)URL {
    
    
    self = [super init];
    if (self){
        self.backgroundColor = [UIColor blackColor];
        
        //设置player的参数
        self.currentItem = [AVPlayerItem playerItemWithURL:URL];
         self.player = [AVPlayer playerWithPlayerItem:self.currentItem];
        self.player.usesExternalPlaybackWhileExternalScreenIsActive=YES;
        //AVPlayerLayer
        self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        self.playerLayer.videoGravity = AVLayerVideoGravityResize;
        [self.layer addSublayer:self.playerLayer];
//        self.player.del
//        [self.player per]
        [self.player play];

        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissView)];
        [self addGestureRecognizer:tap];

        // 循环播放
        _player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
        [[NSNotificationCenter defaultCenter]addObserver:self
                                                selector:@selector(playerItemDidPlayToEndTimeNotification:)
                                                    name:AVPlayerItemDidPlayToEndTimeNotification
                                                  object:nil];
        [self addNotificatonForPlayer];
        
//        [self paly];
        
        }
    return self;
}

- (void)paly {
    [self.player play];

}

- (void)addNotificatonForPlayer {
    
    [self.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(videoPlayError:) name:AVPlayerItemPlaybackStalledNotification object:nil];
    [center addObserver:self selector:@selector(videoPlayEnterBack:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [center addObserver:self selector:@selector(videoPlayBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}
/** 移除 通知 */
- (void)removeNotification {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    //    [center removeObserver:self name:AVPlayerItemTimeJumpedNotification object:nil];
    [center removeObserver:self name:AVPlayerItemPlaybackStalledNotification object:nil];
    [center removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [center removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [center removeObserver:self];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItem * item = (AVPlayerItem *)object;
        if (item.status == AVPlayerItemStatusReadyToPlay) {
            [self.player play];
        }else if (item.status == AVPlayerItemStatusFailed){
            NSLog(@"failed");
        } else {
            MAXLog(@"unknow");
        }
    }
}


/** 视频播放结束 */
- (void)videoPlayEnd:(NSNotification *)notic
{
    NSLog(@"视频播放结束");
    [self.player seekToTime:kCMTimeZero];
}
///** 视频进行跳转 */ 没有意义的方法 会被莫名的多次调动，不清楚机制
//- (void)videoPlayToJump:(NSNotification *)notic
//{
//    NSLog(@"视频进行跳转");
//}
/** 视频异常中断 */
- (void)videoPlayError:(NSNotification *)notic
{
    NSLog(@"视频异常中断");
//    [self useDelegateWith:LPAVPlayerStatusPlayStop];
}
/** 进入后台 */
- (void)videoPlayEnterBack:(NSNotification *)notic
{
    NSLog(@"进入后台");
//    [self useDelegateWith:LPAVPlayerStatusEnterBack];
}
/** 返回前台 */
- (void)videoPlayBecomeActive:(NSNotification *)notic
{
    NSLog(@"返回前台");
//    [self useDelegateWith:LPAVPlayerStatusBecomeActive];
}



- (void)dismissView {
    
    [self dismissAnimated:YES completion:nil];
}

- (void)dismissAnimated:(BOOL)animated completion:(void (^)(void))completion {
    [UIView setAnimationsEnabled:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:_fromNavigationBarHidden withAnimation:animated ? UIStatusBarAnimationFade : UIStatusBarAnimationNone];
    if ([self.delegate respondsToSelector:@selector(closePlayerViewAction)]) {
        [self.delegate closePlayerViewAction];
    }
    float oneTime = animated ? 0.5 : 0;
    
    [UIView animateWithDuration:oneTime delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self releasePlayer];
        if (completion) completion();
    }];
    
}

- (void)presentFromVideoView:(UIView *)fromView
                 toContainer:(UIView *)toContainer
                    animated:(BOOL)animated
                  completion:(void (^)(void))completion{
    
    _toContainerView = toContainer == nil ? MaxRootVC.view : toContainer;
    _fromView = fromView;
    [_toContainerView addSubview:self];
    
    CGFloat height = fromView.size.height * MAXScreenW / fromView.size.width;
    
    self.frame = CGRectMake(0, 0, MAXScreenW, MAXScreenH);
    
    self.alpha = 0;
    
    float oneTime = animated ? 0.5 : 0;
    
    [UIView animateWithDuration:oneTime animations:^{
        self.playerLayer.frame = CGRectMake(0, MAXScreenH / 2 - height / 2, MAXScreenW, height);
        self.alpha = 1;
    }];
    _fromNavigationBarHidden = [UIApplication sharedApplication].statusBarHidden;
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:animated ? UIStatusBarAnimationFade : UIStatusBarAnimationNone];
    if (completion) completion();
}

- (void)playerItemDidPlayToEndTimeNotification:(NSNotification *)sender {
    [self.player seekToTime:kCMTimeZero]; // seek to zero
}
-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self releasePlayer];
}

- (void)releasePlayer {
    [self.player.currentItem cancelPendingSeeks];
    [self.player.currentItem.asset cancelLoading];
    [self.player pause];
    [self removeFromSuperview];
    [self.playerLayer removeFromSuperlayer];
    [self.player replaceCurrentItemWithPlayerItem:nil];
    self.player = nil;
    self.currentItem = nil;
    self.playerLayer = nil;
}

@end
