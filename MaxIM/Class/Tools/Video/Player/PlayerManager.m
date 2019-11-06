//
//  PlayerManager.m
//  MaxIM
//
//  Created by 韩雨桐 on 2019/7/4.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "PlayerManager.h"
#import "VideoPlayerOperation.h"

@implementation PlayerManager
@synthesize videoDecode;
@synthesize videoQueue;


+ (PlayerManager*) sharedInstance {
    static PlayerManager *sharedAccountManagerInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedAccountManagerInstance = [[self alloc] init];
        sharedAccountManagerInstance.videoDecode=[[NSMutableDictionary alloc]init];
        sharedAccountManagerInstance.videoQueue=[[NSOperationQueue alloc]init];
        sharedAccountManagerInstance.videoQueue.maxConcurrentOperationCount=10;
        
    });
    return sharedAccountManagerInstance;
}


-(void)startWithLocalPath:(NSString *)filePath WithVideoBlock:(VideoCode)videoImage{
    [self checkVideoPath:filePath wihtBlock:videoImage];
}


-(VideoPlayerOperation *)checkVideoPath:(NSString *)filePath wihtBlock:(VideoCode)videoBlock
{
    if (!videoQueue) {
        videoQueue=[[NSOperationQueue alloc]init];
        videoQueue.maxConcurrentOperationCount=10000;
    }
    if (!videoDecode) {
        videoDecode=[[NSMutableDictionary alloc]init];
    }
    VideoPlayerOperation *videoView=nil;
    //    NSLog(@"%lu",(unsigned long)videoQueue.operationCount);
    
    [self cancelVideo:filePath];
    videoView=[[VideoPlayerOperation alloc]init];
    //    videoView.name=filePath;
    __weak VideoPlayerOperation *weakplay=videoView;
    videoView.videoBlock=videoBlock;
    [videoView addExecutionBlock:^{
        [weakplay  videoPlayTask:filePath];
    }];
    [videoView setCompletionBlock:^{
        [videoDecode removeObjectForKey:filePath];
        if (weakplay.stopBlock) {
            weakplay.stopBlock(filePath);
        }
    }];
    [videoDecode setObject:videoView forKey:filePath];
    [videoQueue addOperation:videoView];
    return videoView;
}


-(void)reloadVideo:(VideoStop) stop withFile:(NSString *)filePath {
    VideoPlayerOperation *videoView=nil;
    if ([videoDecode objectForKey:filePath]) {
        videoView=[videoDecode objectForKey:filePath];
        videoView.stopBlock=stop;
    }
}

-(void)cancelVideo:(NSString *)filePath
{
    VideoPlayerOperation *videoView=nil;
    if ([videoDecode objectForKey:filePath]) {
        videoView=[videoDecode objectForKey:filePath];
        if (videoView.isCancelled) {
            return;
        }
        [videoView setCompletionBlock:nil];
        
        videoView.stopBlock=nil;
        videoView.videoBlock=nil;
        [videoView cancel];
        if (videoView.isCancelled) {
            [videoDecode removeObjectForKey:filePath];
        }
    }
}

-(void)cancelAllVideo
{
    if (videoQueue) {
        NSMutableDictionary *tpDict=[NSMutableDictionary dictionaryWithDictionary:videoDecode];
        for (NSString *key in tpDict) {
            [self cancelVideo:key];
        }
        [videoDecode removeAllObjects];
        [videoQueue cancelAllOperations];
    }
}



@end



