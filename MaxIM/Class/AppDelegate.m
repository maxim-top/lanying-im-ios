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

@interface AppDelegate ()<UNUserNotificationCenterDelegate, BMXUserServiceProtocol, WXApiDelegate, BMXPushServiceProtocol>

@property (nonatomic, strong) MAXTabBarController *maintabController;
@end

@implementation AppDelegate
@synthesize isDisconnected = _isDisconnected;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    _isDisconnected = NO;
    
    if (@available(iOS 13.0, *)) {
        _statusBarHeight = [UIApplication sharedApplication].windows.firstObject.windowScene.statusBarManager.statusBarFrame.size.height;
    } else {
        _statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    }
    [NSThread sleepForTimeInterval:2];
    
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
  
    NSString *userAgent = [NSString stringWithFormat:NSLocalizedString(@"Device_name_name", @"设备名称:%@;%@;%@;%@"), phoneName,localizedModel,systemName,phoneVersion];
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
    
//    BOOL firstLauch = [[NSUserDefaults standardUserDefaults] boolForKey:@"MAXFirstLauch"];
//    if (!firstLauch) {
//
//        MAXLauchVideoViewController *lauchVideoViewController = [[MAXLauchVideoViewController alloc] init];
//        self.window.rootViewController = lauchVideoViewController;
//        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"MAXFirstLauch"];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeRootViewController) name:@"LauchVideoPlayeFinish" object:nil];
//
//    }else {
    
        if (![IMAcountInfoStorage isHaveLocalData]) {
            self.window.rootViewController = [LoginViewController loginViewWithViewControllerWithNavigation];
        }else {
            self.window.rootViewController = self.maintabController;
        }
//    }
}
- (void)changeRootViewController {
    
    if (![IMAcountInfoStorage isHaveLocalData]) {
        self.window.rootViewController = [LoginViewController loginViewWithViewControllerWithNavigation];
    }else {
        self.window.rootViewController = self.maintabController;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LauchVideoPlayeFinish" object:nil];
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    
    if ([url.absoluteString containsString:@"login"]) {
        [WXApi handleOpenURL:url delegate:self];
    }else{
        UIViewController *currVC = [self getCurrentViewController];
        UINavigationController *nav = [currVC navigationController];
        UIViewController *popVC;
        if(self.maintabController) {
            if ([url.absoluteString hasPrefix:@"MaxIMExtension://Roster"]) {
                popVC = [[RosterListViewController alloc] init];
                popVC.hidesBottomBarWhenPushed = YES;
            } else {
                popVC = [[GroupListSelectViewController alloc] init];
                popVC.hidesBottomBarWhenPushed = YES;
            }
            [nav pushViewController:popVC animated:YES];
       }
    }
    return YES;
}

- (void)onResp:(BaseResp *)resp{
    //判断是否是微信认证的处理结果
    MAXLogDebug(@"WXAPI:onResp");
    if ([resp isKindOfClass:[SendAuthResp class]]) {
        MAXLogDebug(@"WXAPI:onResp1");
        SendAuthResp *temp = (SendAuthResp *)resp;
        //如果你点击了取消，这里的temp.code 就是空值
        if (temp.code != NULL) {
            MAXLogDebug(@"WXAPI:onResp2 %@", temp.code);

            WechatLoginApi *api = [[WechatLoginApi alloc] initWithCode:temp.code];
            [api startWithSuccessBlock:^(ApiResult * _Nullable result) {
                MAXLogDebug(@"WXAPI:onResp3");
                if ( result.isOK) {
                    MAXLogDebug(@"WXAPI:onResp4");
                    if (!result.resultData[@"password"] ) {
                       //  注册登录
                        [HQCustomToast showDialog:NSLocalizedString(@"login_with_your_registered_WeChat_account", @"请登录注册绑定微信")];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"wechatloginsuccess_newuser" object:result.resultData];
                    } else {
                        MAXLogDebug(@"WXAPI:onResp5 %@ %@", result.resultData[@"user_id"], result.resultData[@"username"]);
                        IMAcount *account = [[IMAcount alloc] init];
                        account.usedId  = [NSString stringWithFormat:@"%@",result.resultData[@"user_id"]];
                        account.password = result.resultData[@"password"];
                        account.userName = result.resultData[@"username"];
                        [IMAcountInfoStorage saveObject:account];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"wechatloginsuccess" object:nil];
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
