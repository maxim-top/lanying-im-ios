//
//  MAXLauchVideoViewController.m
//  MaxIM
//
//  Created by 韩雨桐 on 2019/11/14.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "MAXLauchVideoViewController.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

@interface AnimationDelegate : NSObject  <CAAnimationDelegate>

@property (nonatomic, strong) AVPlayer *player;

@end

@implementation AnimationDelegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    [self.player play];
}

@end


@interface MAXLauchVideoViewController ()

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, weak) UIButton *enterMainButton;
@property (nonatomic, weak) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) CABasicAnimation *scaleAnimation;

@end

@implementation MAXLauchVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // 加载一个启动图，防止白屏
    [self addLauchImage];
    
    [self setupPlayer];
    //    [self addEnterButton];
    [self startPlay];
    
    // 添加检测app进入后台的观察者
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnterBackground) name: UIApplicationDidEnterBackgroundNotification object:nil];
    // app从后台进入前台都会调用这个方法
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationBecomeActive) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)addLauchImage {
    
    CALayer *backLayer = [CALayer layer];
    backLayer.frame = [UIScreen mainScreen].bounds;
    backLayer.contents = (__bridge id _Nullable)([self getLauchImage].CGImage);
    backLayer.backgroundColor = [UIColor whiteColor].CGColor;
    [self.view.layer addSublayer:backLayer];
    
}

- (void)setupPlayer {
    
    NSString *videoName = @"lauchVideo_1125"; // 1125 * 632 750 * 422 375 * 210
    CGSize videoSize = CGSizeMake(1124, 632);
    if (!MAXIsFullScreen) {

        if (IS_iPhone_Plus) {
            videoName = @"lauchVideo_750";
            videoSize = CGSizeMake(750, 422);
        }else {
            videoName = @"lauchVideo_374";
            videoSize = CGSizeMake(374, 210);
        }
    }

    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:videoName ofType:@"mp4"]];
    AVPlayer *player = [[AVPlayer alloc] initWithURL:url];
    self.player = player;
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    //使playerLayer光栅化(即位图化)，关闭了图层的blending。
    playerLayer.shouldRasterize = YES;
    //显式指定光栅化的范围，这样能保证视频的显示质量，不然容易出现视频质量显示不佳。
    playerLayer.rasterizationScale = UIScreen.mainScreen.scale;
    self.playerLayer = playerLayer;
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    playerLayer.frame = CGRectMake(0, 150, MAXScreenW, videoSize.height / videoSize.width * MAXScreenW);
    [self.view.layer addSublayer:playerLayer];
    
    // 监听播放完成的通知，重复播放
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
  
}

- (void)addEnterButton {
    
    UIButton *enterMainButton = [[UIButton alloc] init];
    self.enterMainButton = enterMainButton;
    enterMainButton.frame = CGRectMake(100, [UIScreen mainScreen].bounds.size.height - 32 - 48 - 150 , [UIScreen mainScreen].bounds.size.width - 200, 48);
    [self.view addSubview:enterMainButton];
    enterMainButton.layer.borderWidth = 1;
    enterMainButton.layer.cornerRadius = 24;
    enterMainButton.layer.borderColor = [UIColor blueColor].CGColor;
    [enterMainButton setTitle:@"进入应用" forState:UIControlStateNormal];
    [enterMainButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    enterMainButton.alpha = 0.0;
    
    [enterMainButton addTarget:self action:@selector(enterMainAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)startPlay {
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    self.scaleAnimation = scaleAnimation;
    scaleAnimation.fromValue = [NSNumber numberWithFloat:0.0];
    scaleAnimation.toValue = [NSNumber numberWithFloat:1.0];
    scaleAnimation.duration = 3.0f;
    scaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    AnimationDelegate *animationDelegate = [[AnimationDelegate alloc] init];
    animationDelegate.player = self.player;
    scaleAnimation.delegate = animationDelegate;
    [self.playerLayer addAnimation:scaleAnimation forKey:nil];
    [UIView animateWithDuration:3.0 animations:^{
        self.enterMainButton.alpha = 1.0;
    }];
    
}

- (UIImage *)getLauchImage {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    NSString *orientation = @"Portrait";
    NSString *launchImageName = nil;
    NSArray *imagesDict = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchImages"];
    for (NSDictionary *dic in imagesDict) {
        CGSize imageSize = CGSizeFromString(dic[@"UILaunchImageSize"]);
        if (CGSizeEqualToSize(screenSize, imageSize) && [dic[@"UILaunchImageOrientation"] isEqualToString:orientation]) {
            launchImageName = dic[@"UILaunchImageName"];
            break;
        }
    }
    return [UIImage imageNamed:launchImageName];
}

- (void)playbackFinished:(NSNotification *)notifation {
    //    // 回到视频的播放起点
    //    [self.player seekToTime:kCMTimeZero];
    //    [self.player play];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self enterMainAction:nil];
    });
    
}

- (void)stop {
    
    [self.player pause];
    self.player = nil;
    self.scaleAnimation.delegate = nil;
    self.scaleAnimation = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)enterMainAction:(UIButton *)btn {
    [self stop];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LauchVideoPlayeFinish" object:nil];
}

- (void)applicationEnterBackground {
    MAXLog(@"进入后台");
    [self.player pause];
}

- (void)applicationBecomeActive {
    
    MAXLog(@"进入前台");
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.player play];
    });
}




/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
