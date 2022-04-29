//
//  VideoView.m
//  MaxIM
//
//  Created by 韩雨桐 on 2019/6/26.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "VideoView.h"
#import "VideoManager.h"
#import "UIView+BMXframe.h"
#import "NSString+Extention.h"
#import "UIResponder+Router.h"
#import <Masonry.h>
#define kDurationTime 10.0
#import "VideoConst.h"


@interface VideoView ()
{
    NSDate *_startDate;
    NSDate *_endDate;
}

@property (nonatomic, strong) UIView *videoLayerView;

@property (nonatomic, weak) UILabel *recordBtn;

// 提示label:上移取消
@property (nonatomic, weak) UILabel *promptLabel;

@property (nonatomic, weak) UIView *timeLine;
// 时钟
@property (nonatomic, strong) NSTimer *recordTimer;

@property (nonatomic, copy) NSString *videoName;

@end

@implementation VideoView


- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor blackColor];
        [self setupUIwithFrame:frame];
    }
    return self;
}

#pragma mark - UI

- (void)setupUIwithFrame:(CGRect)frame
{
    
    //    self.recordBtn.frame = CGRectMake(0, self.height-20-70, 70, 70);
    self.recordBtn.centerX = self.centerX;
    
    UIButton *exitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:exitBtn];
    [exitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).offset(-50);
        make.centerY.equalTo(_recordBtn.mas_centerY);
        make.width.mas_equalTo(70);
        make.height.mas_equalTo(40);
    }];
    [exitBtn setTitle:NSLocalizedString(@"Cancel", @"取消") forState:UIControlStateNormal];
    [exitBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [exitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [exitBtn addTarget:self action:@selector(exit) forControlEvents:UIControlEventTouchUpInside];
    
    self.videoLayerView.frame = CGRectMake(0, 10, MAXScreenW,self.recordBtn.bmx_top-20-10);
    
    // 占位图片,现写成label
    UILabel *label = [[UILabel alloc] init];
    label.tag = 1001;
    [self.videoLayerView addSubview:label];
    [self addTapGestureRecognizer];
    label.text = NSLocalizedString(@"Now_loading", @"正在加载...");
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_videoLayerView.mas_centerX);
        make.centerY.equalTo(_videoLayerView.mas_centerY);
    }];
    label.textColor = [UIColor whiteColor];
}



#pragma mark - Private Method

- (void)addTapGestureRecognizer
{
    UITapGestureRecognizer *tapTecoginzer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap)];
    tapTecoginzer.numberOfTapsRequired = 1;
    tapTecoginzer.delaysTouchesBegan = YES;
    [self.videoLayerView addGestureRecognizer:tapTecoginzer];
}

- (void)singleTap
{
}

- (void)recordVideoStarted
{
    self.recordBtn.hidden = YES;
    self.timeLine.frame = CGRectMake(0,self.videoLayerView.bottom , MAXScreenW, 1);
    _startDate = [NSDate date];
    self.timeLine.hidden = NO;
    self.promptLabel.hidden = NO;
    [UIView animateWithDuration:kDurationTime animations:^{
        _timeLine.frame = CGRectMake(_timeLine.centerX, _timeLine.bmx_top, 0, 1);
    } completion:^(BOOL finished) {
        
    }];
    self.recordTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(recordTimeOver) userInfo:nil repeats:NO];
    self.videoName = [NSString currentName];
    [[VideoManager shareManager] startRecordingVideoWithFileName:self.videoName];
}

- (void)recordVideoFinished
{
    _endDate = [NSDate date];
    [self destroyTimer];
    self.promptLabel.hidden = YES;
    NSTimeInterval timeInterval = [_endDate timeIntervalSinceDate:_startDate];
    if ((double)timeInterval <= kDurationTime) { //小于或等于规定时间
        self.recordBtn.hidden = YES; // 录制完了就隐藏,录制页面直接下去
        self.timeLine.hidden = YES;
        [[VideoManager shareManager] stopRecordingVideo:^(NSString *path) {
            NSDictionary *userInfo = @{VideoPathKey : path};
            [self routerEventWithName:GXRouterEventVideoRecordFinish userInfo:userInfo];
        }];
    } else {
        return;
    }
}

- (void)recordVideoCanceled
{
    // 这里如果以后出问题，就直接让videoView下去
    [self destroyTimer];
    self.timeLine.hidden = YES;
    self.timeLine = nil;
    self.recordBtn.hidden = YES;
    self.promptLabel.hidden = YES;
    [[VideoManager shareManager] stopRecordingVideo:^(NSString *path) {
        _recordBtn.hidden = NO;
        // 删除已经录制的文件
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[VideoManager shareManager] cancelRecordingVideoWithFileName:_videoName];
        });
    }];
}

- (void)exit
{
    [self destroyTimer];
    [[VideoManager shareManager] exit]; // 防止内存泄露
    [self routerEventWithName:GXRouterEventVideoRecordExit userInfo:nil];
    [self removeFromSuperview];
    
}

// 提示信息
- (void)setTimeLineAndPromptView
{
    self.promptLabel.text = NSLocalizedString(@"Move_up_canceled", @"↑上移取消");
    self.promptLabel.bottom = self.timeLine.bottom-40;
    [self.promptLabel sizeToFit];
    self.promptLabel.center = CGPointMake(self.width*0.5, _promptLabel.centerY);
    self.promptLabel.textColor = [UIColor greenColor];
    self.promptLabel.backgroundColor = [UIColor clearColor];
}

// time is over
- (void)recordTimeOver
{
    self.promptLabel.hidden = YES;
    [self destroyTimer];
    // 结束录制
    [[VideoManager shareManager] stopRecordingVideo:^(NSString *path) {
        NSDictionary *userInfo = @{VideoPathKey : path};
        [self routerEventWithName:GXRouterEventVideoRecordFinish userInfo:userInfo];
    }];
}

// 销毁定时器
- (void)destroyTimer
{
    [self.recordTimer invalidate];
    self.recordTimer = nil;
}

// 手指相对位置
- (BOOL)touchInButtonWithPoint:(CGPoint)point
{
    CGFloat x = point.x;
    CGFloat y = point.y;
    return (x>=self.recordBtn.bmx_left-80&&x<=self.recordBtn.right+50)&&(y<=self.recordBtn.bottom&&y>=self.recordBtn.bmx_top);
}

- (void)promptStatuesChanged:(BOOL)status
{
    if (status) {
        self.promptLabel.text = NSLocalizedString(@"Move_up_canceled", @"↑上移取消");
        self.promptLabel.textColor = [UIColor greenColor];
    } else {
        self.promptLabel.text = NSLocalizedString(@"Release_to_cancel_recording", @"松开取消录制");
        self.promptLabel.textColor = [UIColor redColor];
    }
    [self.promptLabel sizeToFit];
}

- (BOOL)isMoveToTop:(CGPoint)point
{
    CGFloat y = point.y;
    return y<self.recordBtn.bmx_top-10;
}


- (void)dealloc
{
    [self destroyTimer];
    //    [[VideoManager shareManager] exit];// 预防直接返回的情况,但是目前还不行
    //    ICLog(@"ICVideoView------dealloc");
}


#pragma mark - touch

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint  point = [touch locationInView:self];
    BOOL touchResult = [self touchInButtonWithPoint:point];
    if (touchResult) {
        [self recordVideoStarted]; // 开始录制
        [self setTimeLineAndPromptView];
        [self promptStatuesChanged:touchResult];
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch   = [touches anyObject];
    CGPoint  point   = [touch locationInView:self];
    BOOL isTopStatus = [self isMoveToTop:point];
    [self promptStatuesChanged:!isTopStatus];
    if (isTopStatus) {
        
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint  point = [touch locationInView:self];
    BOOL isTopStatus = [self isMoveToTop:point];
    if (isTopStatus) { // 取消录制
        [self recordVideoCanceled];
    } else { // 结束录制
        [self recordVideoFinished];
    }
}

#pragma mark - Getter

- (UIView *)timeLine
{
    if (!_timeLine) {
        UIView *timeLine = [[UIView alloc] init];
        [self addSubview:timeLine];
        timeLine.backgroundColor = [UIColor greenColor];
        _timeLine = timeLine;
    }
    return _timeLine;
}

- (UILabel *)promptLabel
{
    if (!_promptLabel) {
        UILabel *label = [[UILabel alloc] init];
        [self addSubview:label];
        label.font = [UIFont systemFontOfSize:15];
        _promptLabel = label;
    }
    return _promptLabel;
}

- (UIView *)videoLayerView
{
    if (!_videoLayerView) {
        UIView *videoLayerView = [[UIView alloc] init];
        videoLayerView.backgroundColor = [UIColor blackColor];
        videoLayerView.tag = 1000;
        [self addSubview:videoLayerView];
        _videoLayerView = videoLayerView;
    }
    return _videoLayerView;
}

- (UILabel *)recordBtn
{
    if (!_recordBtn) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, self.height-20-70-64, 70, 70)];
        [self addSubview:label];
        _recordBtn = label;
        _recordBtn.layer.cornerRadius = 70/2.0;
        _recordBtn.layer.masksToBounds = YES;
        _recordBtn.layer.borderWidth = 2;
        _recordBtn.layer.borderColor = [UIColor greenColor].CGColor;
    }
    return _recordBtn;
}




@end
