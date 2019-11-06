//
//  RecoderTools.m
//  MaxIM
//
//  Created by hyt on 2018/12/22.
//  Copyright © 2018年 hyt. All rights reserved.
//

#import "BMXRecoderTools.h"
#import "BMXClient.h"
#import "VoiceConverter.h"

#define kChildPath @"Recoder"
#define kAmrType @"amr"
#define kRecoderType @".wav"
#define kMinRecordDuration 1.0

typedef void(^RecordFinishBlock)(NSString *recordPath, int duration);

@interface BMXRecoderTools ()<AVAudioRecorderDelegate, AVAudioPlayerDelegate>

@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, strong) NSDictionary *recordSetting;
@property (nonatomic, copy) RecordFinishBlock recordFinish;

@end

@implementation BMXRecoderTools

+ (id)shareManager
{
    static id _instance ;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (void)addRecoderDelegate:(id<BMXRecoderToolsProtocol>)delegate {
    
    self.delegate = delegate;
}


// here also need to limit recording time
- (void)startRecordingWithFileName:(NSString *)fileName completion:(void(^)(NSError *error))completion {
    NSError *error = nil;
    if (![[BMXRecoderTools shareManager] canRecord]) {
        
        if (completion) {
            error = [NSError errorWithDomain:NSLocalizedString(@"error", @"没权限") code:201 userInfo:nil];
            completion(error);
        }
        return;
    }
    if ([self.recorder isRecording]) {
        [_recorder stop];
        [self cancelCurrentRecording];
        return;
    } else {
        NSString *wavFilePath = [self recorderPathWithFileName:fileName];
        NSURL *wavUrl = [[NSURL alloc] initFileURLWithPath:wavFilePath];
        
        AVAudioSession *session = [AVAudioSession sharedInstance];
        NSError *setCategoryError = nil;
        [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&setCategoryError];
        if(setCategoryError){
            MAXLog(@"%@", [setCategoryError description]);
        }
        
       
       if (@available(iOS 10.0, *)) {
           
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord mode:AVAudioSessionModeSpokenAudio options:AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];
            
        }
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setActive:NO error:nil];
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        [audioSession setActive:YES error:nil];
        

        _recorder = [[AVAudioRecorder alloc] initWithURL:wavUrl settings:self.recordSetting error:&error];
        _recorder.meteringEnabled = YES;
        if (!_recorder || error) {
            _recorder = nil;
            if (completion) {
                error = [NSError errorWithDomain:NSLocalizedString(@"error.initRecorderFail", @"Failed to initialize AVAudioRecorder") code:123 userInfo:nil];
                completion(error);
            }
            return;
        }
        _startDate = [NSDate date];
        _recorder.meteringEnabled = YES;
        _recorder.delegate = self;
        [self.recorder prepareToRecord];
        [_recorder record];
        if (completion) {
            completion(error);
        }
    }
}


- (void)stopRecordingWithCompletion:(void(^)(NSString *recordPath, int duration))completion
{
    
    _endDate = [NSDate date];
    if ([_recorder isRecording]) {
        if ([_endDate timeIntervalSinceDate:_startDate] < [self recordMinDuration]) {
            if (completion) {
                completion(shortRecord, [self.endDate timeIntervalSinceDate:self.startDate]);
            }
            [self.recorder stop];
            [self cancelCurrentRecording];
            sleep(1.0);
            MAXLog(@"record time duration is too short");
            return;
        }
        self.recordFinish = completion;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.recorder stop];
            MAXLog(@"record time duration :%f",[self.endDate timeIntervalSinceDate:self.startDate]);
        });
    }
}

- (void)cancelCurrentRecording
{
    _recorder.delegate = nil;
    if (_recorder.recording) {
        [_recorder stop];
    }
    _recorder = nil;
    _recordFinish = nil;
}


- (BOOL)canRecord
{
    __block BOOL bCanRecord = YES;
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
        [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
            bCanRecord = granted;
        }];
    }
    
    return bCanRecord;
}

- (NSTimeInterval)recordMinDuration
{
    return kMinRecordDuration;
}

// 移除音频
- (void)removeCurrentRecordFile:(NSString *)fileName
{
    [self cancelCurrentRecording];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = [self recorderPathWithFileName:fileName];
    BOOL isDirExist = [fileManager fileExistsAtPath:path];
    if (isDirExist) {
        [fileManager removeItemAtPath:path error:nil];
    }
}

// 录音文件主路径
- (NSString *)recorderMainPath
{
    NSString *path = [[[[BMXClient sharedClient] chatService] getAttachmentDir] stringByAppendingPathComponent:kChildPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path]) {
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
//    [RecoderTools createPathWithChildPath:kChildPath];
}

- (NSString *)recorderPathWithFileName:(NSString *)fileName
{
    NSString *path = [self recorderMainPath];
    return [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@",fileName,kRecoderType]];
}


#pragma mark - Getter

- (NSDictionary *)recordSetting
{
    if (!_recordSetting) {
        _recordSetting = [[NSDictionary alloc] initWithObjectsAndKeys:
                          [NSNumber numberWithFloat:8000.0],AVSampleRateKey,
                          [NSNumber numberWithInt:kAudioFormatLinearPCM],AVFormatIDKey,
                          [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,
                          [NSNumber numberWithInt:1],AVNumberOfChannelsKey,
                          nil];
    }
    return _recordSetting;
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder
                           successfully:(BOOL)flag
{
    NSString *recordPath = [[_recorder url] path];
    // 音频转换
    NSString *amrPath = [[recordPath stringByDeletingPathExtension] stringByAppendingPathExtension:kAmrType];
    [VoiceConverter ConvertWavToAmr:recordPath amrSavePath:amrPath];
    if (self.recordFinish) {
        if (!flag) {
            recordPath = nil;
        }
        self.recordFinish(amrPath,[self.endDate timeIntervalSinceDate:self.startDate]);
    }
    _recorder = nil;
    self.recordFinish = nil;
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError * __nullable)error {
    MAXLog(@"%@",error);
}


#pragma mark - Player

- (void)startPlayRecorder:(NSString *)recorderPath
{
    [self.player stop];
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err = nil;
    [audioSession setCategory :AVAudioSessionCategoryPlayback error:&err];
    
    NSString *wavPath = [[recorderPath stringByDeletingPathExtension] stringByAppendingPathExtension:kRecoderType];
    [VoiceConverter ConvertAmrToWav:recorderPath wavSavePath:wavPath];
    
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:wavPath] error:nil];
    self.player.numberOfLoops = 0;
    [self.player prepareToPlay];
    self.player.delegate = self;
    [self.player play];
}

- (void)stopPlayRecorder:(NSString *)recorderPath
{
    [self.player stop];
    self.player.delegate = nil;
}

- (void)pause
{
    [self.player pause];
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player
                       successfully:(BOOL)flag
{
    [self.player stop];
    if (self.delegate && [self.delegate respondsToSelector:@selector(audioPlayerDidFinishPlaying)]) {
        [self.delegate audioPlayerDidFinishPlaying];
    }

}



// 获取语音时长
- (NSUInteger)durationWithVideo:(NSURL *)voiceUrl{
    
    NSDictionary *opts = [NSDictionary dictionaryWithObject:@(NO) forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:voiceUrl options:opts]; // 初始化视频媒体文件
    NSUInteger second = 0;
    second = urlAsset.duration.value / urlAsset.duration.timescale; // 获取视频总时长,单位秒
    return second;
}

- (void)dealloc {
    
    _delegate = nil;
}



@end
