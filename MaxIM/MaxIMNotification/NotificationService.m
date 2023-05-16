//
//  NotificationService.m
//  MaxIMNotification
//
//  Created by lhr on 2023/3/16.
//  Copyright © 2023 hyt. All rights reserved.
//

#import "NotificationService.h"
#import "AVFoundation/AVFoundation.h"
//#import <WebRTC/RTCDispatcher.h>

@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;
//振动计时器
@property (nonatomic, strong, nullable) dispatch_source_t vibrationTimer;
@property (nonatomic , strong) AVAudioPlayer *player;
@property(nonatomic, assign) int ringTimes;
@end

@implementation NotificationService

- (void)ring{
    self.ringTimes = 10;
    SystemSoundID soundID;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"bell.mp3" ofType:nil];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &soundID);

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    if (self.vibrationTimer) {
        dispatch_cancel(self.vibrationTimer);
        self.vibrationTimer = nil;
    }
    self.vibrationTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, 0 * NSEC_PER_SEC);
    uint64_t interval = 2 * NSEC_PER_SEC;
    dispatch_source_set_timer(self.vibrationTimer, start, interval, 0);
    //最多响铃震动ringTimes次
    dispatch_source_set_event_handler(self.vibrationTimer, ^{
        if(self.ringTimes <= 0){
            dispatch_cancel(self.vibrationTimer);
            NSLog(@"ringring end");
        }else{
            if (self.ringTimes > 7) {
                AudioServicesPlaySystemSound(soundID);
            }
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            NSLog(@"ringring");
            self.ringTimes--;
        }
    });
    dispatch_resume(self.vibrationTimer);
}

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];

    NSDictionary *pushDictionary = request.content.userInfo;
    if([pushDictionary.allKeys containsObject:@"content_type"]){
        NSString *ct = pushDictionary[@"content_type"];
        //判断是否是需要持续震动的通知类型
        if([ct isEqualToString:@"RTC"]){
            NSLog(@"didReceiveNotificationRequest2:%@", ct);
            self.contentHandler(self.bestAttemptContent);
            [self ring];
        } else {
            self.contentHandler(self.bestAttemptContent);
        }
    } else {
        self.contentHandler(self.bestAttemptContent);
    }
}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    if (self.vibrationTimer) {
        dispatch_cancel(self.vibrationTimer);
        self.vibrationTimer = nil;
    }
    self.contentHandler(self.bestAttemptContent);
}

@end
