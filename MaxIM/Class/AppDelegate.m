//
//  AppDelegate.m
//  MaxIM
//
//  Created by hyt on 2018/11/14.
//  Copyright © 2018年 hyt. All rights reserved.
//

#import "AppDelegate.h"
#import "MAXTabBarController.h"
#import "MainViewController.h"
#import "IMAcount.h"
#import "IMAcountInfoStorage.h"
#import "MAXGlobalTool.h"
#import <UserNotifications/UserNotifications.h>
#import "GetTokenApi.h"
#import <WXApi.h>
#import "WechatApi.h"
#import "WechatLoginApi.h"
#import "RosterListViewController.h"
#import "GroupListSelectViewController.h"
#import "AppIDManager.h"
#import "MAXLauchVideoViewController.h"
#import "LoginViewController.h"
#import "AccountListStorage.h"
#import "AccountManagementManager.h"

#import <Bugly/Bugly.h>
#import "HostConfigManager.h"
#import "RosterDetailViewController.h"

#import <floo-ios/floo_proxy.h>
#import "AppDelegate+PushService.h"
#import <floo-rtc-ios/RTCEngineManager.h>
#import "BindOpenIdApi.h"
#import "AppIDViewController.h"
#import "LHChatVC.h"
#import "SchemURIStorage.h"
#import "LanyingLinkInfoAPI.h"
#import "SecretInfoAPI.h"
#import "NSString+Extention.h"
#import <objc/runtime.h>

@interface AppDelegate ()<UNUserNotificationCenterDelegate, BMXUserServiceProtocol, WXApiDelegate, BMXPushServiceProtocol>

@property (nonatomic, strong) MAXTabBarController *maintabController;
@end

@implementation AppDelegate
@synthesize isDisconnected = _isDisconnected;

+ (void)hookOldOpenUrl:(Class)targetCls {
    Class cls = [UIApplication class];
    if (cls) {
        Method originalMethod =class_getInstanceMethod(cls, @selector(openURL:));
        Method swizzledMethod =class_getInstanceMethod(targetCls, @selector(g_openURL:));
        if (!originalMethod || !swizzledMethod) {
            return;
        }
        IMP originalIMP = method_getImplementation(originalMethod);
        IMP swizzledIMP = method_getImplementation(swizzledMethod);
        const char *originalType = method_getTypeEncoding(originalMethod);
        const char *swizzledType = method_getTypeEncoding(swizzledMethod);
        class_replaceMethod(cls,@selector(openURL:),swizzledIMP,swizzledType);
        class_replaceMethod(cls,@selector(g_openURL:),originalIMP,originalType);
    }
}

- (BOOL)g_openURL:(NSURL*)url
{
    [UIApplication.sharedApplication openURL:url options:nil completionHandler:nil];
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    _isDisconnected = NO;
    
    if (@available(iOS 13.0, *)) {
        _statusBarHeight = [UIApplication sharedApplication].windows.firstObject.windowScene.statusBarManager.statusBarFrame.size.height;
    } else {
        _statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    }
//    [NSThread sleepForTimeInterval:2];
    
    [self configapnsWithapplication:application didFinishLaunchingWithOptions:launchOptions];
    [self configProperties];
    [self initializeBMX];
    [self registerAPNs];
    [self initBugly];
    [self initTingYunApp];
    [self initialWechat];
    [self setupMainViewController];
    
    [self autologin];
    if (@available(iOS 10.0, *)) {
        [DDLog addLogger:[DDOSLogger sharedInstance]];
    } else {
        [DDLog addLogger:[DDTTYLogger sharedInstance]];
    }
    
    NSString *logPath =  [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:[NSString stringWithFormat:@"ChatData/logs"]];

    DDLogFileManagerDefault *fm = [[DDLogFileManagerDefault alloc] initWithLogsDirectory:logPath];
    DDFileLogger *fileLogger = [[DDFileLogger alloc] initWithLogFileManager: fm];
    fileLogger.rollingFrequency = 0;
    fileLogger.maximumFileSize = 10 * 1024 * 1024; //10M
    fileLogger.logFileManager.maximumNumberOfLogFiles = 5; // 最多允许创建7个文件
    [DDLog addLogger:fileLogger];
    
//    if (application.applicationIconBadgeNumber > 0) {
//        application.applicationIconBadgeNumber = 0;
//    }
    [AppDelegate hookOldOpenUrl:AppDelegate.class];
    return YES;
}

- (void)initTingYunApp {
    [NBSAppAgent startWithAppID:@"abe2265adc9144bf810f056610e621ab"];
}

- (void)initBugly  {
    [Bugly startWithAppId:@"b54d3afda3"];
}

- (void)initialWechat {
    [WXApi registerApp:@"wx96edf8b1e48af083" universalLink:@"https://package.maximtop.com/apple-app-site-association/"];
}


- (void)autologin {
    IMAcount *accout = [IMAcountInfoStorage loadObject];
    if (accout) {
        [self signByName:accout.userName password:accout.password];
    }
}

- (void)userSignIn:(BMXUserProfile *)userProflie {
    [self.maintabController addIMListener];
}

- (void)bindDeviceToken {
    NSString *deviceToken = [[NSUserDefaults standardUserDefaults] valueForKey:@"deviceToken"];
    if ([deviceToken length]) {
        [[[BMXClient sharedClient] userService] bindDeviceWithToken:deviceToken completion:^(BMXError *error) {
            MAXLog(@"绑定成功%@", deviceToken);
        }];
    }
}

- (void)signByName:(NSString *)name password:(NSString *)password {
    [[BMXClient sharedClient] fastSignInByNameWithName:name password:password completion:^(BMXError *error) {
        if (!error) {
            MAXLog(@"登录成功 username = %@ , password = %@",name, password);
            [self.maintabController addIMListener];
            [self getProfile];
            [self bindDeviceToken];
            [self getRosterList];
            [self getAppTokenWithName:name password:password];
        }else {
            MAXLog(@"失败 errorCode = %ld ", error.errorCode);
            self.window.rootViewController = [LoginViewController loginViewWithViewControllerWithNavigation];
        }
    }];
}

- (void)saveLastLoginAppid {
    BMXSDKConfig *sdkconfig = [[BMXClient sharedClient] getSDKConfig];
    [AppIDManager changeAppid:sdkconfig.getAppID isSave:YES];
    [[NetWorkingManager netWorkingManager] resetHeaderWithAppID:sdkconfig.getAppID];
}

- (void)saveIMAcountName:(NSString *)name password:(NSString *)password {
    IMAcount *a = [[IMAcount alloc] init];
    a.isLogin = YES;
    a.password = password;
    a.userName = [NSString stringWithFormat:@"%@", name];
    [IMAcountInfoStorage saveObject: a];
}

- (void)loginByName:(NSString *)userName
        password:(NSString *)password {
    [HQCustomToast showWating];
    
    [[BMXClient sharedClient] signInByNameWithName:userName password:password completion:^(BMXError * _Nonnull error) {
        [HQCustomToast hideWating];
            if (!error) {
                [self saveLastLoginAppid];
                [self getAppTokenWithName:userName password:password];
                [self getProfile];
                [self bindDeviceToken];
                [self saveIMAcountName:userName password:password];
                IMAcount *account = [IMAcountInfoStorage loadObject];
                account.isLogin = YES;
                [IMAcountInfoStorage saveObject:account];
                [UIApplication sharedApplication].delegate.window.rootViewController = [MAXGlobalTool share].rootViewController;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"loginSuccess" object:nil];
                
                [[MAXGlobalTool share].rootViewController removeIMListener];
                
                AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                [appDelegate userLogout];
                [[MAXGlobalTool share].rootViewController addIMListener];
            }
        }];

}

- (void)getAppTokenWithName:(NSString *)name password:(NSString *)password {
    GetTokenApi *api = [[GetTokenApi alloc] initWithName:name password:password];
    [api startWithSuccessBlock:^(ApiResult * _Nullable result) {
        if (result.isOK) {
            IMAcount *account = [IMAcountInfoStorage loadObject];
            NSDictionary *dic = result.resultData;
            account.token = dic[@"token"];
            [IMAcountInfoStorage saveObject:account];
        }
    } failureBlock:^(NSError * _Nullable error) {
        
    }];
}

- (void)getProfile {
    
    [[[BMXClient sharedClient] userService] getProfile:NO completion:^(BMXUserProfile *profile, BMXError *aError) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshProfile" object:profile];
        
        NSString *appid = [[BMXClient sharedClient] getSDKConfig].getAppID;
        IMAcount *account = [IMAcountInfoStorage loadObject];
        account.usedId = [NSString stringWithFormat:@"%lld", profile.userId];
        [IMAcountInfoStorage saveObject:account];
        
        NSArray *accountlist  = [NSArray arrayWithArray:[AccountListStorage loadObject]];
        if (accountlist.count == 0) {
            [[AccountManagementManager sharedAccountManagementManager] addAccountUserName:account.userName
                                                                                 password:account.password
                                                                                   userid:account.usedId
                                                                                    appid:appid];
        }
    }];
}

- (void)getRosterList {
    [[[BMXClient sharedClient] rosterService] get:YES completion:^(ListOfLongLong *rostIdList, BMXError *error) {
    }];
}

- (void)configapnsWithapplication:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0){
            if (@available(iOS 10.0, *)) {
                UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
                [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
                    if (granted) {
                        [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
                            if (settings.authorizationStatus == UNAuthorizationStatusAuthorized){
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [[UIApplication sharedApplication] registerForRemoteNotifications];
                                });
                            }
                        }];
                    }
                }];
            }
        } else if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0){
            if (@available(iOS 8.0, *)) {
                if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
                    UIUserNotificationSettings* notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
                    [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
                    [[UIApplication sharedApplication] registerForRemoteNotifications];
                } else {
                    [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
                }
            }
        }
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(nonnull NSError *)error {
    MAXLog(@"%@", error);
    
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(nonnull NSData *)deviceToken {
    //Xcode11打的包，iOS13获取Token有变化
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 13) {
        if (![deviceToken isKindOfClass:[NSData class]]) {
            //记录获取token失败的描述
            return;
        }
        const unsigned *tokenBytes = (const unsigned *)[deviceToken bytes];
        NSString *strToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                              ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                              ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                              ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
        NSLog(@"deviceToken1:%@", strToken);
        [[NSUserDefaults standardUserDefaults] setObject:strToken forKey:@"deviceToken"];

        return;
    } else {
        NSString *token = [NSString
                       stringWithFormat:@"%@",deviceToken];
        token = [token stringByReplacingOccurrencesOfString:@"<" withString:@""];
        token = [token stringByReplacingOccurrencesOfString:@">" withString:@""];
        token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSLog(@"deviceToken2 is: %@", token);
        [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"deviceToken"];

    }


}


- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler {
    NSString *url = userActivity.webpageURL.absoluteString;
    NSString *package = @"https://package.maximtop.com/";
    if ([url hasPrefix:package]) {
        if ([url containsString:@"state=login"] || [url containsString:@"state=bindInProfile"]) {
            [WXApi handleOpenURL:userActivity.webpageURL delegate:self];
        }else{
            if(![IMAcountInfoStorage isHaveLocalData]) {
                [SchemURIStorage saveObject:url];
            }
            NSString *path = [url substringFromIndex:package.length];
            return [self processExternalLinkWithPath: path];
        }
    }
    return [WXApi handleOpenUniversalLink:userActivity delegate:self];
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updatedeviceToken" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updatePushId)
                                                 name:@"updatedeviceToken"
                                               object:nil];
}

- (void)updatePushId {
    
}

- (void)initializeBMX {
    //设置数据和缓存目录路径
    NSString* dataDir = [NSString pathWithComponents:@[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject, @"ChatData"]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:dataDir]) {
        [fileManager createDirectoryAtPath:dataDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString* cacheDir = [NSString pathWithComponents:@[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject,@"UserCache"]];
    if (![fileManager fileExistsAtPath:cacheDir]) {
        [fileManager createDirectoryAtPath:cacheDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSLog(@"dataDir = %@", dataDir);
    NSLog(@"cacheDir = %@", cacheDir);
  
    //User agent信息
    NSString* phoneName = [[UIDevice currentDevice] name];
    NSString* localizedModel = [[UIDevice currentDevice] localizedModel];
    NSString* systemName = [[UIDevice currentDevice] systemName];
    NSString* phoneVersion = [[UIDevice currentDevice] systemVersion];
  
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *main_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *build_Version = [infoDictionary objectForKey:@"CFBundleVersion"];
    NSString *app_Version = [NSString stringWithFormat:@"AppVer:%@.%@", main_Version, build_Version];

    NSString *bundleIdentifier = [NSString stringWithFormat:@"PackName:%@", [[NSBundle mainBundle] bundleIdentifier]];
    
    NSString *userAgent = [NSString stringWithFormat:NSLocalizedString(@"Device_name_name", @"设备名称:%@;%@;%@;%@;%@;%@"), phoneName,localizedModel,systemName,phoneVersion,app_Version,bundleIdentifier];
    // pushCertName: DEV: apns_maximtop_dev_2022_11; DIST: apns_maximtop_distribution_2022_11
    //创建SDK配置
    BMXSDKConfig *config  = [[BMXSDKConfig alloc] initWithType:BMXClientType_iOS vsn:@"1" dataDir:dataDir
        cacheDir:cacheDir sDKVersion:@"1" pushCertName:@"apns_maximtop_distribution_2022_11" userAgent:userAgent
        appId:[AppIDManager sharedManager].appid.appId appSecret:@"47B13PBIAPDARZKD" deliveryAck:false];
    config.appID = [AppIDManager sharedManager].appid.appId;
    config.appSecret = @"47B13PBIAPDARZKD";
    config.loadAllServerConversations = YES;
    [config setLogLevel: BMXLogLevel_Debug];
    
    IMAcount *accout = [IMAcountInfoStorage loadObject];
    if (accout.isLogin) {
        if ([HostConfigManager checkLocalConfig]) {
            BMXSDKConfigHostConfig * hostConfig = [[BMXSDKConfigHostConfig alloc]initWithIm:[HostConfigManager sharedManager].IMServer port:[[HostConfigManager sharedManager].IMPort intValue] rest:[HostConfigManager sharedManager].restServer];
            config.hostConfig = hostConfig;
            config.enableDNS = NO;

        } else {
            config.enableDNS = YES;
        }
    } else {
        config.enableDNS = YES;
    }
    
    config.verifyCertificate = NO;
    //创建客户端实例
    [BMXClient createWithConfig: config];
}

- (void)reloadAppID:(NSString *)appid {
    
    [AppIDManager changeAppid:appid isSave:NO];
    [[BMXClient sharedClient] changeAppIdWithAppId:appid completion:^(BMXError * _Nonnull error) {
        
    }];
    [[NetWorkingManager netWorkingManager] resetHeaderWithAppID:appid];
}

- (void)configProperties {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
}

- (void)userLogout {
    [self setupMainViewController];
}

- (void)setupMainViewController {
    
    self.maintabController = [[MAXTabBarController alloc] initWithNibName:nil bundle:nil];
    [MAXGlobalTool share].rootViewController = self.maintabController;
    
    if (![IMAcountInfoStorage isHaveLocalData]) {
        UIViewController *vc = [[AppIDViewController alloc] initWithNibName:nil bundle:nil];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        self.window.rootViewController = nav;
    }else {
        self.window.rootViewController = self.maintabController;
    }
}
- (void)changeRootViewController {
    
    if (![IMAcountInfoStorage isHaveLocalData]) {
        self.window.rootViewController = [LoginViewController loginViewWithViewControllerWithNavigation];
    }else {
        self.window.rootViewController = self.maintabController;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LauchVideoPlayeFinish" object:nil];
}

- (void)pushViewControllerWithVC:(UIViewController*) popVC{
    UIViewController *currVC = [self getCurrentViewController];
    UINavigationController *nav = [currVC navigationController];
    BMXSignInStatus status = [[BMXClient sharedClient] signInStatus];
    if(status != BMXSignInStatus_SignIn){
        nav = [self.maintabController.childViewControllers firstObject];
    }
    popVC.hidesBottomBarWhenPushed = YES;
    [nav pushViewController:popVC animated:YES];
}

// https://lanying.link/info?link=kloyx7 {"data":{"uid":6765036047296,"type":"user","text":"","app_id":"eajzxtgmgets"},"code":200}
- (void)getLinkInfoAndUserPasswordWithLink:(NSString *)link andCode:(NSString *)code andTarget:(NSString *)target{
    LanyingLinkInfoAPI *api = [[LanyingLinkInfoAPI alloc] initWithLink:link];
    [HQCustomToast showWating];
    [api startWithSuccessBlock:^(ApiResult * _Nullable result) {
        [HQCustomToast hideWating];
        if (result.isOK) {
            NSNumber *userId = (NSNumber* )result.resultData[@"uid"];
            long long uid = [userId longLongValue];
            NSString *appId = result.resultData[@"app_id"];
            
            if([IMAcountInfoStorage isHaveLocalData]) {
                if(appId.length == 0 ){
                    [HQCustomToast showDialog:NSLocalizedString(@"app_id_required", @"缺少App ID")];
                    return;
                }
                NSString *currAppId = [[BMXClient sharedClient] getSDKConfig].getAppID;
                if(![appId isEqualToString:currAppId]){
                    NSString *alert = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"change_app_id_to", @"请退出当前账号并切换到App ID到"), appId];
                    [HQCustomToast showDialog:alert];
                    return;
                }
                
                if([target isEqualToString:@"sc"]){
                    [[[BMXClient sharedClient] rosterService] searchWithRosterId:uid forceRefresh:NO completion:^(BMXRosterItem *item, BMXError *error) {
                        if (!error) {
                            UIViewController *popVC = [[LHChatVC alloc] initWithRoster:item messageType:BMXMessage_MessageType_Single];
                            [self pushViewControllerWithVC:popVC];
                        }
                    }];
                }else if([target isEqualToString:@"gc"]){
                    [[[BMXClient sharedClient] groupService] fetchGroupByIdWithGroupId:uid forceRefresh:NO completion:^(BMXGroup *group, BMXError *error) {
                        if (!error) {
                            UIViewController *popVC = [[LHChatVC alloc] initWithGroupChat:group messageType:BMXMessage_MessageType_Group];
                            [self pushViewControllerWithVC:popVC];
                        }
                    }];
                }

            }else{
                SecretInfoAPI *api = [[SecretInfoAPI alloc] initWithCode:code];
                [HQCustomToast showWating];
                [api startWithSuccessBlock:^(ApiResult * _Nullable result) {
                    [HQCustomToast hideWating];
                    if (result.isOK) {
                        NSString *secret_text = result.resultData[@"secret_text"];
                        NSDictionary *dic = [NSString dictionaryWithJsonString:secret_text];
                        NSString *username = dic[@"username"];
                        NSString *password = dic[@"password"];
                        
                        [AppIDManager changeAppid:appId isSave:YES];
                        [[BMXClient sharedClient] changeAppIdWithAppId:appId completion:nil];
                        [[NetWorkingManager netWorkingManager] resetHeaderWithAppID:appId];
                        [self loginByName:username password:password];
                    }
                } failureBlock:^(NSError * _Nullable error) {
                    [HQCustomToast hideWating];
                }];
            }
        }
    } failureBlock:^(NSError * _Nullable error) {
        [HQCustomToast hideWating];
    }];
}

- (BOOL)processExternalLinkWithPath:(NSString *)path{
    NSArray *words = [path componentsSeparatedByString:@"?"];
    if(words.count != 2){
        return YES;
    }
    NSString *target = words[0];
    NSString *wechat = @"apple-app-site-association/wx96edf8b1e48af083/";
    if([target hasPrefix:wechat]){
        return YES;
    }
    NSString *parameters = words[1];
    NSArray *paramArray = [parameters componentsSeparatedByString:@"&"];
    NSMutableDictionary *kvDict = [[NSMutableDictionary alloc] init];
    for (NSString *param in paramArray) {
        NSArray *kv = [param componentsSeparatedByString:@"="];
        if(kv.count != 2){
            continue;
        }
        kvDict[kv[0]] = kv[1];
    }
    
    NSString *link = kvDict[@"link"];
    NSString *code = kvDict[@"code"];
    if(link.length == 0 || code.length == 0){
        [HQCustomToast showDialog:NSLocalizedString(@"param_error", @"参数缺失")];
        return YES;
    }

    [self getLinkInfoAndUserPasswordWithLink:link andCode:code andTarget:target];
    
    return YES;
}

- (BOOL)processSchemeWithURL:(NSString *)url{
    NSString *maxIMExtersion = @"maximextension://";
    NSString *lanying = @"lanying:";
    if ([url hasPrefix:maxIMExtersion]) {
        UIViewController *popVC;
        NSString *path = [url substringFromIndex:maxIMExtersion.length];
        if([path isEqualToString:@"Roster"]){
            popVC = [[RosterListViewController alloc] init];
        }else {
            popVC = [[GroupListSelectViewController alloc] init];
        }
        [self pushViewControllerWithVC:popVC];
    } else if ([url hasPrefix:lanying]) {
        NSString *path = [url substringFromIndex:lanying.length];
        return [self processExternalLinkWithPath: path];
    }
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    
    if ([url.absoluteString containsString:@"login"] || [url.absoluteString containsString:@"bindInProfile"]) {
        [WXApi handleOpenURL:url delegate:self];
    }else{
        if([IMAcountInfoStorage isHaveLocalData]) {
            return [self processSchemeWithURL:url.absoluteString];
        }else{
            // 解析 URL 中的查询参数
            NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
            NSArray<NSURLQueryItem *> *queryItems = components.queryItems;
            
            // 提取微信小程序传递的 extraData
            BOOL official_account_followed = NO;
            for (NSURLQueryItem *item in queryItems) {
                if ([item.name isEqualToString:@"_wechat_sdk_biz_data"]) {
                    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:item.value options:NSDataBase64DecodingIgnoreUnknownCharacters];
                    NSString *extra = [[NSString alloc] initWithData:decodedData encoding:NSISOLatin1StringEncoding];
                    NSRange range = [extra rangeOfString:@"official_account_followed=true"];
                    if (range.location != NSNotFound) {
                        official_account_followed = YES;
                    }
                    break;
                }
            }
            if (official_account_followed) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"wechatloginsuccess" object:nil];
            }else{
                [SchemURIStorage saveObject:url.absoluteString];
            }
        }
    }
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return  [WXApi handleOpenURL:url delegate:self];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if ([url.absoluteString containsString:@"login"] || [url.absoluteString containsString:@"bindInProfile"]) {
        [WXApi handleOpenURL:url delegate:self];
    }else{
        if([IMAcountInfoStorage isHaveLocalData]) {
            return [self processSchemeWithURL:url.absoluteString];
        }else{
            [SchemURIStorage saveObject:url.absoluteString];
        }
    }
    return YES;
}


- (void)onResp:(BaseResp *)resp{
    //判断是否是微信认证的处理结果
    MAXLog(@"WXAPI:onResp");
    if ([resp isKindOfClass:[SendAuthResp class]]) {
        MAXLog(@"WXAPI:onResp1");
        SendAuthResp *temp = (SendAuthResp *)resp;
        //如果你点击了取消，这里的temp.code 就是空值
        if (temp.code != NULL) {
            MAXLog(@"WXAPI:onResp2 %@", temp.code);

            WechatLoginApi *api = [[WechatLoginApi alloc] initWithCode:temp.code];
            [api startWithSuccessBlock:^(ApiResult * _Nullable result) {
                MAXLog(@"WXAPI:onResp3");
                if ( result.isOK) {
                    MAXLog(@"WXAPI:onResp4");
                    if ([temp.state isEqualToString:@"bindInProfile"]){
                        NSString *openId = [result.resultData objectForKey:@"openid"];
                        IMAcount *account = [IMAcountInfoStorage loadObject];
                        GetTokenApi *api = [[GetTokenApi alloc] initWithName:account.userName password:account.password];
                        [api startWithSuccessBlock:^(ApiResult * _Nullable result) {
                            if (result.isOK) {
                                IMAcount *account = [IMAcountInfoStorage loadObject];
                                NSDictionary *dic = result.resultData;
                                account.token = dic[@"token"];
                                [IMAcountInfoStorage saveObject:account];
                                
                                BindOpenIdApi *api = [[BindOpenIdApi alloc] initWithopenId:openId];
                                [api startWithSuccessBlock:^(ApiResult * _Nullable result) {
                                    if (result.isOK) {
                                        [HQCustomToast showDialog:NSLocalizedString(@"Bind_successfully", @"绑定成功")];
                                    } else {
                                        [HQCustomToast showDialog:result.errmsg];
                                    }
                                    [[NSNotificationCenter defaultCenter] postNotificationName:@"wechatBound" object:nil];
                                } failureBlock:^(NSError * _Nullable error) {
                                    [HQCustomToast showDialog:NSLocalizedString(@"Failed_to_bind", @"绑定失败")];
                                    [[NSNotificationCenter defaultCenter] postNotificationName:@"wechatBound" object:nil];
                                }];

                            }
                        } failureBlock:^(NSError * _Nullable error) {
                            
                        }];
                    }else{
                        if (!result.resultData[@"password"] ) {
                           //  注册登录
                            [HQCustomToast showDialog:NSLocalizedString(@"login_with_your_registered_WeChat_account", @"请登录注册绑定微信")];
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"wechatloginsuccess_newuser" object:result.resultData];
                        } else {
                            MAXLog(@"WXAPI:onResp5 %@ %@", result.resultData[@"user_id"], result.resultData[@"username"]);
//                            BOOL official_account_followed = [result.resultData objectForKey:@"official_account_followed"]; //todo 等待联调；修改launchMiniProgramReq.path；弹出小程序；引导关注公众号
                            IMAcount *account = [[IMAcount alloc] init];
                            account.usedId  = [NSString stringWithFormat:@"%@",result.resultData[@"user_id"]];
                            account.password = result.resultData[@"password"];
                            account.userName = result.resultData[@"username"];
                            [IMAcountInfoStorage saveObject:account];
                            BOOL official_account_followed = [result.resultData[@"official_account_followed"] boolValue];
                            if(!official_account_followed){
                                NSString *appId = [[BMXClient sharedClient] getSDKConfig].getAppID;
                                WXLaunchMiniProgramReq *launchMiniProgramReq = [WXLaunchMiniProgramReq object];
                                launchMiniProgramReq.userName = @"gh_11b8debeb062";
                                launchMiniProgramReq.path =[NSString stringWithFormat: @"pages/profile/official_account/index?app_id=%@&user_id=%@",appId, result.resultData[@"user_id"]];
                                launchMiniProgramReq.miniProgramType = WXMiniProgramTypeRelease;
                                [WXApi sendReq:launchMiniProgramReq completion:^(BOOL success) {
                                }];
                                MAXLog(@"xxmini");
                            }else{
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"wechatloginsuccess" object:nil];
                            }
                        }
                    }
                }

            } failureBlock:^(NSError * _Nullable error) {

            }];
        }
    }
}


/**
 网络请求成功
 
 @param dic 网络请求数据
 */
- (void)p_successedWeiChatLogin:(NSDictionary *)dic  {
    NSDictionary *returnObject = [NSDictionary dictionary];
    returnObject = dic;
    
//    WechatLoginApi *api = [[WechatLoginApi alloc] initWithCode:dic[@""]]
    
    //成功返回
    //                {
    //                    "access_token" = "fdpTn5awAnJ7g-RAjLjMT7DAFInXhbIjmLZzmrLea8jQtJm2VyEEIB3NKdvnV6gHXPo76ki0z4kiQ1CXA62SnneKZI";  接口调用凭证
    //                    "expires_in" = 7200;//接口调用凭证超时时间，单位（秒）
    //                    openid = ovMVmwh0TzOnVQX62R5zXg;//授权用户唯一标识
    //                    "refresh_token" = "4GjXOOIAOBYuxO7wfjimyB1d_H6xLeCeUeng8bKDCzv5-N3yZSueJnz6UTkh9_j6l0tuS4Dlcs6c3ZC1xTmCUe0M0";//用户刷新access_token
    //                    scope = "snsapi_userinfo";//用户授权的作用域，使用逗号（,）分隔
    //                    unionid = oTlu3wJzgi6iVVb8txvU;//当且仅当该移动应用已获得该用户的userinfo授权时，才会出现该字段
    //                }
}

- (UIViewController *)getCurrentViewController {
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    UIViewController *topViewController = [window rootViewController];
        
    while (true) {
        if (topViewController.presentedViewController) {
            topViewController = topViewController.presentedViewController;
        } else if ([topViewController isKindOfClass:[UINavigationController class]] && [(UINavigationController*)topViewController topViewController]) {
            topViewController = [(UINavigationController *)topViewController topViewController];
        } else if ([topViewController isKindOfClass:[UITabBarController class]]) {
            UITabBarController *tab = (UITabBarController *)topViewController;
            topViewController = tab.selectedViewController;
        } else {
            break;
        }
    }
    return topViewController;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary * _Nonnull)userInfo fetchCompletionHandler:(void (^ _Nonnull)(UIBackgroundFetchResult))completionHandler{
    NSString *msg_type = userInfo[@"msg_type"];
    if ([msg_type isEqualToString:@"APPLIED"]) {
        UIViewController *curr = [self getCurrentViewController];
        UINavigationController *nav = [curr navigationController];
        RosterDetailViewController *vc = [[RosterDetailViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        [nav pushViewController:vc animated:YES];
    }
    MAXLog(@"didReceiveRemoteNotification:%@",userInfo);
}

- (void)applicationWillResignActive:(UIApplication *)application {

}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    //进入后台
    if (![[RTCEngineManager engineWithType:kMaxEngine] isOnCall]) {
        [[BMXClient sharedClient] disconnect];
        _isDisconnected = YES;
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // app从后台进入前台都会调用这个方法
    //    if (application.applicationIconBadgeNumber > 0) {
    //        application.applicationIconBadgeNumber = 0;
    //    }
    if (_isDisconnected) {
        IMAcount *accout = [IMAcountInfoStorage loadObject];
        if (accout) {
            [[BMXClient sharedClient]  reconnect];
            MAXLog(@"reconnect");
            _isDisconnected = NO;
        }
    }
}



- (void)applicationWillTerminate:(UIApplication *)application {
    MAXLog(@"程序被杀死，applicationWillTerminate");
    [[BMXClient sharedClient] disconnect];
}


@end
