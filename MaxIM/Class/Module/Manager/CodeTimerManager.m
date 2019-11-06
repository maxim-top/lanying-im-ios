//  ************************************************************************
//
//  CodeTimerManager.m
//  USchool
//
//  Created by hanyutong on 17/2/6.
//  Copyright © 2017年 topglobaledu. All rights reserved.
//
//  Main function:
//
//  Other specifications:
//
//  ************************************************************************

#import "CodeTimerManager.h"

@interface CodeTimerManager ()

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSTimeInterval totalTime;
@property (nonatomic, assign) NSTimeInterval currentTime;
@property (nonatomic, assign) NSTimeInterval lastTime;

@end

@implementation CodeTimerManager

+ (id)sharedTimeManager {
    static CodeTimerManager *timeManger;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        timeManger = [[CodeTimerManager alloc] init];
    });
    
    return timeManger;
    
}
- (void)beginTimeWithTotalTime:(NSTimeInterval)totalTime {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timegoing) userInfo:nil repeats:YES];
    self.totalTime = totalTime;
    self.currentTime = 1;
    // 记录开始的时间戳
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    [[NSUserDefaults standardUserDefaults] setDouble:timeInterval forKey:@"BeginTime"];
    [[NSUserDefaults standardUserDefaults] setFloat:totalTime forKey:@"LastTime"];
    [[NSUserDefaults standardUserDefaults] setFloat:totalTime forKey:@"TotalTime"];
}

- (void)timeStop {
    [self.timer invalidate];
    //    self.lastTime = self.totalTime - self.currentTime++;
    [[NSUserDefaults standardUserDefaults] setFloat:self.lastTime forKey:@"LastTime"];
}

- (void)timegoing {
    self.lastTime = self.totalTime - self.currentTime;
    MAXLog(@"lastTime:%f", self.lastTime);
    self.currentTime++;
    [[NSUserDefaults standardUserDefaults] setFloat:self.lastTime forKey:@"LastTime"];
    if (self.lastTime > 0.0f) {
        [self.timeDelegate timeLast:self.lastTime];
    } else {
        [self.timer invalidate];
        [self.timeDelegate timeFinish];
    }
}

- (BOOL)lastTimeIsFinish {
    if ([self getLastTime] <= 0) {
        return YES;
    }
    return NO;
}

- (NSTimeInterval)getLastTime {
    NSTimeInterval oldTimeInterval = [[NSUserDefaults standardUserDefaults] doubleForKey:@"BeginTime"];
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval time = timeInterval  - oldTimeInterval ;
    CGFloat total = [[NSUserDefaults standardUserDefaults] floatForKey:@"TotalTime"];
    MAXLog(@"time%ld", (long)time);
    if (time >= total) {
        return 0;  // 隔了60S
    }
    NSTimeInterval lastTime = [[NSUserDefaults standardUserDefaults] floatForKey:@"LastTime"];
    return  lastTime;
}

- (NSTimeInterval)resultTime {
    NSTimeInterval oldTimeInterval = [[NSUserDefaults standardUserDefaults] doubleForKey:@"BeginTime"];
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval time = timeInterval  - oldTimeInterval ;
    CGFloat total = [[NSUserDefaults standardUserDefaults] floatForKey:@"TotalTime"];
    return total - time;
}
@end
