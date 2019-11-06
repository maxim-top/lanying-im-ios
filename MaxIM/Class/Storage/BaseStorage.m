//
//  BaseStorage.m
//  BlockMessage
//
//  Created by hyt on 2018/8/1.
//  Copyright © 2018年 HYT. All rights reserved.
//

#import "BaseStorage.h"

@implementation BaseStorage

+ (NSString *)modelPath {
    return @"";
}

+ (void)saveObject:(nonnull id)object {
    if (object == nil) {
        return;
    }
    NSString *filePathString = [NSString stringWithFormat:@"Documents/%@.archiver",[self modelPath]];
    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:filePathString];
    [NSKeyedArchiver archiveRootObject:object toFile:filePath];
}

+ (id)loadObject {
    NSString *filePathString = [NSString stringWithFormat:@"Documents/%@.archiver",[self modelPath]];
    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:filePathString];
    return  [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
}

+ (void)clearObject {
    NSString *filePathString = [NSString stringWithFormat:@"Documents/%@.archiver",[self modelPath]];
    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:filePathString];
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    [defaultManager removeItemAtPath:filePath error:nil];
}

@end
