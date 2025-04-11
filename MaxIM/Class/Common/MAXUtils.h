//
//  MAXUtils.h
//  MaxIMDemo
//
//  Created by hyt on 2022/9/2.
//  ----------------------------------------------------------------------
//
//                    Copyright (C) 2018-2022   MaxIM.Top
//
// You may obtain a copy of the licence at http://www.maxim.top/LICENCE-MAXIM.md
//
//  ----------------------------------------------------------------------
//

#import <floo-ios/floo_proxy.h>

@interface MAXUtils : NSObject

// 获取好友ID列表
+ (void)getAllRosterIdsWithCompletion:(void (^)(ListOfLongLong *list)) resBlock;
// 获取好友ID数组
+ (void)getAllRosterWithCompletion:(void (^)(NSArray *arr)) resBlock;
// 获取群成员ID列表
+ (void)getMemberIdsWithGroup: (BMXGroup *) group completion:(void (^)(ListOfLongLong *list)) resBlock;
// 获取群成员ID数组
+ (void)getMemberIdArrayWithGroup: (BMXGroup *) group completion:(void (^)(NSArray *arr)) resBlock;
// 获取群成员详情
+ (void)getRostersByidArray:(ListOfLongLong *)idList completion:(void (^)(NSArray *arr)) resBlock;
// 获取字符串的MD5值
+ (NSString *)MD5Hash:(NSString *)input;
// 获取字符串的MD5值（base64格式）
+ (NSString *)MD5InBase64:(NSString *)input;
// 获取AppConfig开关
+ (bool)getAppSwitch:(NSString *)key;
@end
