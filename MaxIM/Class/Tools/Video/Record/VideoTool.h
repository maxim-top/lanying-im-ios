//
//  VideoTool.h
//  MaxIM
//
//  Created by 韩雨桐 on 2019/6/26.
//  Copyright © 2019 hyt. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface VideoTool : NSObject


+ (NSString *)cacheDirectory;

// 根据子路径创建路径
+ (NSString *)createPathWithChildPath:(NSString *)childPath;

// 是否存在该路径
+ (BOOL)fileExistsAtPath:(NSString *)path;

// 删除路径下的文件
+ (BOOL)removeFileAtPath:(NSString *)path;

// 文件路径
+ (NSString *)filePathWithName:(NSString *)fileKey
                       orgName:(NSString *)name
                          type:(NSString *)type;

// 文件主目录
+ (NSString *)fileMainPath;

// 文件大小
+ (CGFloat)fileSizeWithPath:(NSString *)path;

// 小于1024显示KB，否则显示MB
+ (NSString *)filesize:(NSString *)path;
+ (NSString *)fileSizeWithInteger:(NSUInteger)integer;

// 清除NSUserDefaults
+ (void)clearUserDefaults;

// copy file
+ (BOOL)copyFileAtPath:(NSString *)path
                toPath:(NSString *)toPath;




@end

NS_ASSUME_NONNULL_END
