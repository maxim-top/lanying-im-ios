//
//  VideoManager.h
//  MaxIM
//
//  Created by 韩雨桐 on 2019/6/26.
//  Copyright © 2019 hyt. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^RecordingFinished)(NSString *path);

@interface VideoManager : NSObject

+ (instancetype)shareManager;

- (void)setVideoPreviewLayer:(UIView *)videoLayerView;


- (void)startRecordingVideoWithFileName:(NSString *)videoName;

// 录制权限
- (BOOL)canRecordViedo;

// stop recording
- (void)stopRecordingVideo:(RecordingFinished)finished;

- (void)cancelRecordingVideoWithFileName:(NSString *)videoName;

// 退出
- (void)exit;

// 接收到的视频保存路径(文件以fileKey为名字)
- (NSString *)receiveVideoPathWithFileKey:(NSString *)fileKey;

- (NSString *)videoPathWithFileName:(NSString *)videoName;

- (NSString *)videoPathForMP4:(NSString *)namePath;
// 自定义路径
- (NSString *)videoPathWithFileName:(NSString *)videoName fileDir:(NSString *)fileDir;

//获取第一帧
- (UIImage*) getVideoPreViewImage:(NSURL *)path;

//获取文件size
- (CGFloat)getFileSize:(NSString *)path;

//获取文件时间
- (int)getVideoTimeByUrlString:(NSString*)urlString;




@end

NS_ASSUME_NONNULL_END
