//  ************************************************************************
//
//  MAXUtils.m
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

#import "MAXUtils.h"
#import <CommonCrypto/CommonCrypto.h>
#import "LHChatVC.h"

@interface MAXUtils ()
@end

@implementation MAXUtils
// 静态变量实现
static NSSet *_requiredVerifications = nil;
static NSMutableSet<NSString *> *_optionalVerifications = nil;
static NSMutableSet<NSString *> *_finishedVerifications = nil;

+ (void)getAllRosterIdsWithCompletion:(void (^)(ListOfLongLong *list)) resBlock {
    if (resBlock) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            ListOfLongLong *ids = [[ListOfLongLong alloc] init];
            [[[BMXClient sharedClient] rosterService] get: ids forceRefresh:YES];
            dispatch_async(dispatch_get_main_queue(), ^{
                resBlock(ids);
            });
        });
    }
}

+ (void)getAllRosterWithCompletion:(void (^)(NSArray *arr)) resBlock {
    if (resBlock) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSMutableArray *arr = [[NSMutableArray alloc] init];
            BMXRosterItemList* list = [[BMXRosterItemList alloc] init];
            ListOfLongLong *ids = [[ListOfLongLong alloc] init];
            BMXErrorCode err = [[[BMXClient sharedClient] rosterService] get: ids forceRefresh:YES];
            if (!err) {
                err = [[[BMXClient sharedClient] rosterService] searchWithRosterIdList:ids list:list forceRefresh:YES];
                if (!err) {
                    unsigned long sz = list.size;
                    MAXLog(@"%ld", sz);
                    for (int i=0; i<sz; i++) {
                        [arr addObject:[list get: i]];
                    }
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                resBlock(arr);
            });
        });
    }
}

+ (void)getMemberIdsWithGroup: (BMXGroup *) group completion:(void (^)(ListOfLongLong *list)) resBlock {
    if (resBlock) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            BMXGroupMemberList* list = [[BMXGroupMemberList alloc] init];
            ListOfLongLong *res = [[ListOfLongLong alloc] init];
            BMXErrorCode err = [[[BMXClient sharedClient] groupService] getMembers:group list:list forceRefresh:YES];
            if (!err){
                unsigned long sz = list.size;
                MAXLog(@"%ld", sz);
                for (int i=0; i<sz; i++) {
                    BMXGroupMember *member = [list get: i];
                    long long uid = [member getMUid];
                    [res addWithX: &uid];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                resBlock(res);
            });
        });
    }
}

+ (void)getMemberIdArrayWithGroup: (BMXGroup *) group completion:(void (^)(NSArray *arr)) resBlock {
    if (resBlock) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            BMXGroupMemberList* list = [[BMXGroupMemberList alloc] init];
            NSMutableArray * arr = [[NSMutableArray alloc] init];
            BMXErrorCode err = [[[BMXClient sharedClient] groupService] getMembers:group list:list forceRefresh:YES];
            if (!err){
                unsigned long sz = list.size;
                MAXLog(@"%ld", sz);
                for (int i=0; i<sz; i++) {
                    BMXGroupMember *member = [list get: i];
                    long long uid = [member getMUid];
                    NSString* sUid = [NSString stringWithFormat:@"%lld", uid];
                    [arr addObject:sUid];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                resBlock(arr);
            });
        });
    }
}

+ (void)getRostersByidArray:(ListOfLongLong *)idList completion:(void (^)(NSArray *arr)) resBlock {
    if (resBlock) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            BMXRosterItemList* rosterItems = [[BMXRosterItemList alloc] init];
            NSMutableArray* arr = [NSMutableArray array];
            BMXErrorCode err = [[[BMXClient sharedClient] rosterService] searchWithRosterIdList:idList list:rosterItems forceRefresh:NO];
            if (!err){
                unsigned long sz = rosterItems.size;
                MAXLog(@"%ld", sz);
                for (int i=0; i<sz; i++) {
                    BMXRosterItem *item = [rosterItems get: i];
                    [arr addObject:item];
                }
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                resBlock(arr);
            });
        });
    }
}

NSString *HEXStringFromData(NSData *data) {
    const unsigned char *dataBuffer = (const unsigned char *)[data bytes];
    NSMutableString *hexString = [NSMutableString stringWithCapacity:[data length] * 2];
    for (NSUInteger i = 0; i < [data length]; ++i) {
        [hexString appendFormat:@"%02x", dataBuffer[i]];
    }
    return hexString;
}

// 计算字符串的MD5值
+ (NSString *)MD5Hash:(NSString *)input {
    const char *cStr = [input UTF8String];
    unsigned char digest[16];
    CC_MD5(cStr, (unsigned int)strlen(cStr), digest); // 进行MD5加密
    
    NSData *digestData = [NSData dataWithBytes:digest length:sizeof(digest)];
    return HEXStringFromData(digestData);
}

// 计算字符串的MD5值
+ (NSString *)MD5InBase64:(NSString *)input {
    const char *cStr = [input UTF8String];
    unsigned char digest[16];
    CC_MD5(cStr, (unsigned int)strlen(cStr), digest); // 进行MD5加密
    
    NSData *digestData = [NSData dataWithBytes:digest length:sizeof(digest)];
    return [digestData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

+ (bool)getAppSwitch:(NSString *)key {
    BMXSDKConfig *sdkconfig = [[BMXClient sharedClient] getSDKConfig];
    NSString *appConfig = sdkconfig.getAppConfig;
    if (appConfig.length == 0) {
        return false;
    }
    
    NSString *appId = [[BMXClient sharedClient] getSDKConfig].getAppID;
    NSString *appConfigKey = [NSString stringWithFormat:@"AppConfig_%@", appId];
    [[NSUserDefaults standardUserDefaults] setValue:appConfig forKey:appConfigKey];

    NSData *data = [appConfig dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *configDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    bool value = [[configDic objectForKey:key] boolValue];
    return value;
}

+ (NSString *)getAppConfigString:(NSString *)key {
    BMXSDKConfig *sdkconfig = [[BMXClient sharedClient] getSDKConfig];
    NSString *appConfig = sdkconfig.getAppConfig;
    if (appConfig.length == 0) {
        return nil;
    }
    
    NSString *appId = [[BMXClient sharedClient] getSDKConfig].getAppID;
    NSString *appConfigKey = [NSString stringWithFormat:@"AppConfig_%@", appId];
    [[NSUserDefaults standardUserDefaults] setValue:appConfig forKey:appConfigKey];
    
    NSData *data = [appConfig dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *configDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    NSString *value = [configDic objectForKey:key];
    return value;
}

+ (NSString *)getAppConfigStringFromLocal:(NSString *)key {
    NSString *appId = [[BMXClient sharedClient] getSDKConfig].getAppID;
    NSString *appConfigKey = [NSString stringWithFormat:@"AppConfig_%@", appId];
    NSString *appConfig = [[NSUserDefaults standardUserDefaults] valueForKey:appConfigKey];
    if (appConfig.length == 0) {
        return nil;
    }
    NSData *data = [appConfig dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *configDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    NSString *value = [configDic objectForKey:key];
    return value;
}

+ (NSString *)getRosterDisplayName:(BMXRosterItem *)item {
    NSString *name = @"";
    if (item != nil) {
        if (item.alias.length > 0) {
            name = item.alias;
        }else if (item.nickname.length > 0) {
            name = item.nickname;
        }else if (item.username.length > 0) {
            name = item.username;
        }
    }
    return name;
}

+ (NSString *)getCompanyName {
    NSString *companyName = [MAXUtils getAppConfigString:@"account_verification_name"];
    NSString *verificationType = [MAXUtils getAppConfigString:@"account_verification_type"];
    if ([verificationType isEqualToString:@"personal"] && companyName.length != 0) {
        companyName = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"about_us_individual_developer", @"个人开发者:"), companyName];
    }
    return companyName;
}

+ (NSString *)getCompanyNameFromLocal {
    NSString *companyName = [MAXUtils getAppConfigStringFromLocal:@"account_verification_name"];
    NSString *verificationType = [MAXUtils getAppConfigStringFromLocal:@"account_verification_type"];
    if ([verificationType isEqualToString:@"personal"] && companyName.length != 0) {
        companyName = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"about_us_individual_developer", @"个人开发者:"), companyName];
    }
    return companyName;
}

+ (NSString *)getCompanyNameWithVerifyStatus {
    NSString *companyName = [MAXUtils getCompanyName];
    NSString * vsc = [MAXUtils getVerificationStatusChar];
    if (companyName == nil || vsc == nil) {
        return nil;
    }
    return [NSString stringWithFormat:@"%@ %@", companyName, vsc];
}

+ (NSString *)getCompanyNameWithVerifyStatusFromLocal {
    NSString *companyName = [MAXUtils getCompanyNameFromLocal];
    NSString * vsc = [MAXUtils getVerificationStatusCharFromLocal];
    if (companyName == nil || vsc == nil) {
        return nil;
    }
    return [NSString stringWithFormat:@"%@ %@", companyName, vsc];
}

+ (NSString *)getVerificationStatusText {
    NSString *verificationStatus = [MAXUtils getAppConfigString:@"account_verification_status"];
    NSDictionary *map= @{@"verified":[NSString stringWithFormat:@"%@",NSLocalizedString(@"about_us_verified", @"✅已认证")],
                         @"unverified":[NSString stringWithFormat:@"%@",NSLocalizedString(@"about_us_unverified", @"❓未认证")],
                         @"expired":[NSString stringWithFormat:@"%@",NSLocalizedString(@"about_us_expired", @"❗认证失败")]};
    NSString *verifyString = map[verificationStatus];
    return verifyString;
}

+ (NSString *)getVerificationStatusTextFromLocal {
    NSString *verificationStatus = [MAXUtils getAppConfigStringFromLocal:@"account_verification_status"];
    NSDictionary *map= @{@"verified":[NSString stringWithFormat:@"%@",NSLocalizedString(@"about_us_verified", @"✅已认证")],
                         @"unverified":[NSString stringWithFormat:@"%@",NSLocalizedString(@"about_us_unverified", @"❓未认证")],
                         @"expired":[NSString stringWithFormat:@"%@",NSLocalizedString(@"about_us_expired", @"❗认证失败")]};
    NSString *verifyString = map[verificationStatus];
    return verifyString;
}

+ (NSString *)getVerificationStatusChar {
    NSString *verificationStatus = [MAXUtils getAppConfigString:@"account_verification_status"];
    NSDictionary *map= @{@"verified":@"✅",
                         @"unverified":@"❓",
                         @"expired":@"❗"};
    NSString *verifyString = map[verificationStatus];
    return verifyString;
}

+ (NSString *)getVerificationStatusCharFromLocal {
    NSString *verificationStatus = [MAXUtils getAppConfigStringFromLocal:@"account_verification_status"];
    NSDictionary *map= @{@"verified":@"✅",
                         @"unverified":@"❓",
                         @"expired":@"❗"};
    NSString *verifyString = map[verificationStatus];
    return verifyString;
}

+ (void)addContact:(UIViewController *)vc andRosterItem:(BMXRosterItem *)roster {
    NSString *authQuestion = roster.addFriendAuthMode==BMXRosterItem_AddFriendAuthMode_AnswerQuestion? roster.authQuestion:@"";
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:authQuestion.length>0 ? NSLocalizedString(@"Friend_verification_question", @"好友验证问题") : NSLocalizedString(@"Add_friend", @"添加好友")
                                                                   message:authQuestion
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", @"确定") style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
                                                         //响应事件
                                                         //得到文本信息
                                                         for(UITextField *text in alert.textFields){
                                                             MAXLog(@"text = %@", text.text);
                                                             if (authQuestion.length>0){
                                                                 [MAXUtils addRoster:roster authAnswer:[text.text length] ? text.text : @"" vc:vc];
                                                             }else{
                                                                 [MAXUtils addRoster:roster reason:[text.text length] ? text.text : @"" vc:vc];
                                                             }
                                                         }
                                                     }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"取消") style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {
                                                             //响应事件
                                                             MAXLog(@"action = %@", alert.textFields);
                                                         }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = authQuestion.length>0 ? NSLocalizedString(@"enter_answer", @"请输入答案") : NSLocalizedString(@"enter_message_for_group_application", @"请输入申请的留言信息");
    }];
    
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    [vc presentViewController:alert animated:YES completion:nil];
}

// 添加好友
+ (void)addRoster:(BMXRosterItem *)roster reason:(NSString *)reason vc:(UIViewController *)vc{
    [[[BMXClient sharedClient] rosterService] applyWithRosterId:roster.rosterId message:reason completion:^(BMXError *error) {
        [MAXUtils addContactResult:error vc:vc roster:roster];
    }];
}

// 添加好友
+ (void)addRoster:(BMXRosterItem *)roster authAnswer:(NSString *)authAnswer vc:(UIViewController *)vc {
    [[[BMXClient sharedClient] rosterService] applyWithRosterId:roster.rosterId message:@"" authAnswer:authAnswer completion:^(BMXError *error) {
        [MAXUtils addContactResult:error vc:vc roster:roster];
    }];
}
+ (void)addContactResult:(BMXError *)error vc:(UIViewController *)vc roster:(BMXRosterItem *)roster{
    MAXLog(@"%lld", roster.rosterId);
    if (!error) {
        [HQCustomToast showDialog:NSLocalizedString(@"Request_sent", @"已发出请求")];
        [vc.navigationController popToRootViewControllerAnimated:YES];
        
    } else if (error.errorCode == BMXErrorCode_CurrentUserIsInRoster){
        [vc.navigationController  popToRootViewControllerAnimated:NO];
        
        UITabBarController *bar =  (UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        UINavigationController *currentNav =  (UINavigationController *)bar.selectedViewController;
        
        LHChatVC *vc = [[LHChatVC alloc] initWithRoster:roster messageType:BMXMessage_MessageType_Single];
        vc.hidesBottomBarWhenPushed = YES;
        [currentNav pushViewController:vc animated:YES];
    } else {
        [HQCustomToast showDialog:[error description]];
    }
}

+ (NSSet *)requiredVerifications {
    return _requiredVerifications;
}

+ (NSMutableSet<NSString *> *)optionalVerifications {
    if (!_optionalVerifications) {
        _optionalVerifications = [[NSMutableSet alloc] init];
    }
    return _optionalVerifications;
}

+ (NSMutableSet<NSString *> *)finishedVerifications {
    if (!_finishedVerifications) {
        _finishedVerifications = [[NSMutableSet alloc] init];
    }
    return _finishedVerifications;
}

+ (NSString *)replacePhoneNumber:(NSString *)phone {
    if (!phone || phone.length < 5) {
        return phone;
    }
    
    // 第一种脱敏模式：匹配 前3位-中间4位-后4位 的模式
    NSString *pattern1 = @".*\\d{3}\\d{4}\\d{4}";
    NSRegularExpression *regex1 = [NSRegularExpression regularExpressionWithPattern:pattern1 options:0 error:nil];
    NSTextCheckingResult *match1 = [regex1 firstMatchInString:phone options:0 range:NSMakeRange(0, phone.length)];
    
    if (match1) {
        // 使用正则表达式替换：将中间4位替换为****
        NSString *pattern2 = @"(.*\\d{3})\\d{4}(\\d{4})";
        NSString *replacement = @"$1****$2";
        NSString *masked = [phone stringByReplacingOccurrencesOfString:pattern2
                                                            withString:replacement
                                                               options:NSRegularExpressionSearch
                                                                 range:NSMakeRange(0, phone.length)];
        
        if (![masked isEqualToString:phone]) {
            return masked;
        }
    }
    
    // 第二种脱敏模式：通用脱敏，保留前3位，后面全部替换为*
    if (phone.length >= 3) {
        NSString *firstThree = [phone substringToIndex:3];
        NSInteger starCount = phone.length - 3;
        NSString *stars = [@"" stringByPaddingToLength:starCount withString:@"*" startingAtIndex:0];
        return [firstThree stringByAppendingString:stars];
    }
    
    return phone;
}

+ (BOOL)needShowVerificationPage:(NSString *)verificationName {
    if (!verificationName) return NO;
    
    BOOL isRequiredOrOptional = [_requiredVerifications containsObject:verificationName] ||
                               [_optionalVerifications containsObject:verificationName];
    BOOL isNotFinished = ![_finishedVerifications containsObject:verificationName];
    
    return isRequiredOrOptional && isNotFinished;
}

+ (void)setRequiredVerificationsWithArray:(NSArray *)array {
    _requiredVerifications = [NSSet setWithArray: array];
}

+ (void)setOptionalVerificationsWithArray:(NSArray *)array {
    _optionalVerifications = [NSSet setWithArray: array];
}

+ (void)setFinishedVerificationsWithArray:(NSArray *)array {
    _finishedVerifications = [NSSet setWithArray: array];
}

+ (BOOL)didAllRequiredFinished {
    for (NSString *required in _requiredVerifications) {
        if (![_finishedVerifications containsObject:required]) {
            return NO;
        }
    }
    return YES;
}

+ (BOOL)isOptionalVerification:(NSString *)verificationName {
    if (!verificationName) return NO;
    return [_optionalVerifications containsObject:verificationName];
}

@end
