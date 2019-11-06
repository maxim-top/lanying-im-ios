//
//  RecoderTools.h
//  MaxIM
//
//  Created by hyt on 2018/12/22.
//  Copyright © 2018年 hyt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#define shortRecord @"shortRecord"

NS_ASSUME_NONNULL_BEGIN

@protocol BMXRecoderToolsProtocol <NSObject>

@optional

- (void)audioPlayerDidFinishPlaying;

@end


@interface BMXRecoderTools : NSObject


@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, weak) id<BMXRecoderToolsProtocol> delegate;

+ (id)shareManager;

- (void)addRecoderDelegate:(id<BMXRecoderToolsProtocol>)delegate;

// start recording
- (void)startRecordingWithFileName:(NSString *)fileName
                        completion:(void(^)(NSError *error))completion;
// stop recording
- (void)stopRecordingWithCompletion:(void(^)(NSString *recordPath, int duration))completion;

// 是否拥有权限
- (BOOL)canRecord;

// 取消当前录制
- (void)cancelCurrentRecording;

- (void)removeCurrentRecordFile:(NSString *)fileName;

#pragma mark -- 播放

- (void)startPlayRecorder:(NSString *)recorderPath;

- (void)stopPlayRecorder:(NSString *)recorderPath;

// 获取语音时长
- (NSUInteger)durationWithVideo:(NSURL *)voiceUrl;

@end

NS_ASSUME_NONNULL_END
