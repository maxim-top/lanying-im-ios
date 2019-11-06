//
//  PlayerManager.h
//  MaxIM
//
//  Created by 韩雨桐 on 2019/7/4.
//  Copyright © 2019 hyt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VideoPlayerOperation.h"


NS_ASSUME_NONNULL_BEGIN

@interface PlayerManager : NSObject
{
    NSOperationQueue *videoQueue;
    NSMutableDictionary *videoDecode;    
}

@property(nonatomic,strong)NSMutableDictionary *videoDecode;
@property(nonatomic,strong)NSOperationQueue *videoQueue;

+ (PlayerManager*) sharedInstance;
// 本地 videoPath   block中播放的imageview
- (void)startWithLocalPath:(NSString *)filePath WithVideoBlock:(VideoCode)videoImage;
- (void)reloadVideo:(VideoStop) stop withFile:(NSString *)filePath;
- (void)cancelVideo:(NSString *)filePath;
- (void)cancelAllVideo;


@end

NS_ASSUME_NONNULL_END
