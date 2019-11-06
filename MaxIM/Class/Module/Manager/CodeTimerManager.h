//
//  CodeTimerManager.h
//  USchool
//
//  Created by hanyutong on 17/2/6.
//  Copyright © 2017年 topglobaledu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TimeProtocol <NSObject>

- (void)timeLast:(NSTimeInterval)lastTime;
- (void)timeFinish;

@end

@interface CodeTimerManager : NSObject

@property (nonatomic, weak) id<TimeProtocol> timeDelegate;

+ (id)sharedTimeManager;
- (void)beginTimeWithTotalTime:(NSTimeInterval)totalTime;
- (void)timeStop;
- (BOOL)lastTimeIsFinish;
- (NSTimeInterval)getLastTime;
- (NSTimeInterval)resultTime;

@end
