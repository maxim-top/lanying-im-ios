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
// 认证列表集合
@property (class, nonatomic, strong) NSSet *requiredVerifications;
@property (class, nonatomic, strong) NSSet *optionalVerifications;
@property (class, nonatomic, strong) NSSet *finishedVerifications;

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
// 获取AppConfig字符串类型值
+ (NSString *)getAppConfigString:(NSString *)key;
+ (NSString *)getAppConfigStringFromLocal:(NSString *)key;
// 获取好友名称
+ (NSString *)getRosterDisplayName:(BMXRosterItem *)item;
// 获取认证信息中的公司名
+ (NSString *)getCompanyName;
+ (NSString *)getCompanyNameFromLocal;
// 获取认证信息中的公司名加认证状态
+ (NSString *)getCompanyNameWithVerifyStatus;
+ (NSString *)getCompanyNameWithVerifyStatusFromLocal;
// 获取认证状态
+ (NSString *)getVerificationStatusText;
+ (NSString *)getVerificationStatusTextFromLocal;
// 获取认证状态符号
+ (NSString *)getVerificationStatusChar;
+ (NSString *)getVerificationStatusCharFromLocal;
// 添加好友
+(void)addContact:(UIViewController *)vc andRosterItem:(BMXRosterItem *)roster;

/**
 * 手机号脱敏处理
 * @param phone 原始手机号
 * @return 脱敏后的手机号
 */
+ (NSString *)replacePhoneNumber:(NSString *)phone;

/**
 * 判断是否需要显示验证页面
 * @param verificationName 验证名称
 * @return 是否需要显示
 */
+ (BOOL)needShowVerificationPage:(NSString *)verificationName;

/**
 * 设置必须认证页面
 */
+ (void)setRequiredVerificationsWithArray:(NSArray *)array;

/**
 * 设置可选认证页面
 */
+ (void)setOptionalVerificationsWithArray:(NSArray *)array;

/**
 * 设置已完成认证列表（从JSON数组字符串解析）
 */
+ (void)setFinishedVerificationsWithArray:(NSArray *)array;

/**
 * 检查所有必须认证是否已完成
 * @return 是否全部完成
 */
+ (BOOL)didAllRequiredFinished;

/**
 * 判断是否为可选认证
 * @param verificationName 验证名称
 * @return 是否为可选认证
 */
+ (BOOL)isOptionalVerification:(NSString *)verificationName;

@end
