


//
//  VideoTool.m
//  MaxIM
//
//  Created by 韩雨桐 on 2019/6/26.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "VideoTool.h"


#define kChildPath @"Chat/File"

@implementation VideoTool


+ (NSString *)cacheDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
}





+ (NSString *)createPathWithChildPath:(NSString *)childPath
{
    NSString *path = [[self cacheDirectory] stringByAppendingPathComponent:childPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirExist = [fileManager fileExistsAtPath:path];
    if (!isDirExist) {
        BOOL isCreatDir = [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        if (!isCreatDir) {
            NSLog(@"create folder failed");
            return nil;
        }
    }
    return path;
}


+ (BOOL)fileExistsAtPath:(NSString *)path
{
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}


+ (BOOL)removeFileAtPath:(NSString *)path
{
    return [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}


// 文件路径
+ (NSString *)filePathWithName:(NSString *)fileKey
                       orgName:(NSString *)name
                          type:(NSString *)type
{
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:kChildPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirExist = [fileManager fileExistsAtPath:path];
    if (!isDirExist) {
        BOOL isCreatDir = [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        if (!isCreatDir) {
            MAXLog(@"create folder failed");
            return nil;
        }
    }
    return [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@.%@",fileKey,name,type]];
}

// 文件主目录
+ (NSString *)fileMainPath
{
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:kChildPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirExist = [fileManager fileExistsAtPath:path];
    if (!isDirExist) {
        BOOL isCreatDir = [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        if (!isCreatDir) {
            MAXLog(@"create folder failed");
            return nil;
        }
    }
    return path;
}


// 返回字节
+ (CGFloat)fileSizeWithPath:(NSString *)path
{
    NSDictionary *outputFileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    return [outputFileAttributes fileSize]/1024.0;
}

// 小于1024显示KB，否则显示MB
+ (NSString *)filesize:(NSString *)path
{
    CGFloat size = [self fileSizeWithPath:path];
    if ( size > 1000.0) { // 1000kb不好看，所以我就以1000为标准了
        return [NSString stringWithFormat:@"%.1fMB",size/1024.0];
    } else {
        return [NSString stringWithFormat:@"%.1fKB",size];
    }
}

+ (NSString *)fileSizeWithInteger:(NSUInteger)integer
{
    CGFloat size = integer/1024.0;
    if ( size > 1000.0) { // 1000kb不好看，所以我就以1000为标准了
        return [NSString stringWithFormat:@"%.1fMB",size/1024.0];
    } else {
        return [NSString stringWithFormat:@"%.1fKB",size];
    }
}

+ (void)clearUserDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dic        = [defaults dictionaryRepresentation];
    for (NSString *key in [dic allKeys]) {
        if ([key hasSuffix:@"unread"] || [key hasSuffix:@"current"])
            [defaults removeObjectForKey:key];
        [defaults synchronize];
    }
    [defaults removeObjectForKey:@"chatViewController"];
    [defaults synchronize];
}


// copy file
+ (BOOL)copyFileAtPath:(NSString *)path
                toPath:(NSString *)toPath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    BOOL result = [fileManager copyItemAtPath:path toPath:toPath error:&error];
    if (error) {
        MAXLog(@"copy file error:%@",error);
    }
    return result;
}





@end
