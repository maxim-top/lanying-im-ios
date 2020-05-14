//
//  AppDelegate.m
//  MaxIM
//
//  Created by hyt on 2018/11/14.
//  Copyright © 2018年 hyt. All rights reserved.
//

#import "AppDelegate.h"
#import "MAXTabBarController.h"
#import <floo-ios/BMXClient.h>
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

#import <floo-ios/BMXHostConfig.h>
#import <Bugly/Bugly.h>
#import "HostConfigManager.h"



@interface AppDelegate ()<UNUserNotificationCenterDelegate, BMXUserServiceProtocol, WXApiDelegate>

@property (nonatomic, strong) MAXTabBarController *maintabController;
@end

@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [NSThread sleepForTimeInterval:2];
    
    [self configProperties];
    [self initializeBMX];
    [self initBugly];
    [self initialWechat];
    [self setupMainViewController];
    
    [self autologin];
    [self configapnsWithapplication:application didFinishLaunchingWithOptions:launchOptions];
  
//    if (application.applicationIconBadgeNumber > 0) {
//        application.applicationIconBadgeNumber = 0;
//    }
    return YES;
}

- (void)initBugly  {
    [Bugly startWithAppId:@"62419d2a9f"];
}

- (void)initialWechat {
    [WXApi registerApp:@"wx96edf8b1e48af083"];
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

- (void)signByName:(NSString *)name password:(NSString *)password {
    [[BMXClient sharedClient] fastSignInByName:name password:password  completion:^(BMXError *error) {
        if (!error) {
            MAXLog(@"登录成功 username = %@ , password = %@",name, password);
            [self.maintabController addIMListener];
            UINavigationController *navigation = (UINavigationController *)[self.maintabController.childViewControllers firstObject];
            if ([NSStringFromClass([navigation.childViewControllers firstObject].class) isEqualToString:@"MainViewController"] ) {
                
                MainViewController *mainVC = [navigation.childViewControllers firstObject];
                    [mainVC getAllConversations];
            }
            [self getProfile];
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
    
    [[[BMXClient sharedClient] userService] getProfileForceRefresh:NO completion:^(BMXUserProfile *profile, BMXError *aError) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshProfile" object:profile];
        
        NSString *appid = [[BMXClient sharedClient] sdkConfig].appID;
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
    [[[BMXClient sharedClient] rosterService] getRosterListforceRefresh:YES completion:^(NSArray *rostIdList, BMXError *error) {
    
    }];
}

- (void)configapnsWithapplication:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    if (@available(iOS 10.0, *)) {
        UNUserNotificationCenter * center = [UNUserNotificationCenter currentNotificationCenter];
        [center setDelegate:self];
        UNAuthorizationOptions type = UNAuthorizationOptionBadge|UNAuthorizationOptionSound|UNAuthorizationOptionAlert;
        [center requestAuthorizationWithOptions:type completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                MAXLog(@"注册成功");

            }else{
                MAXLog(@"注册失败");
            }
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // 注册获得device Token
                [application registerForRemoteNotifications];
                
            });
            

        }];
    }else if (@available(iOS 8.0, *)){
        UIUserNotificationType notificationTypes = UIUserNotificationTypeBadge |
        UIUserNotificationTypeSound |
        UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
        [application registerUserNotificationSettings:settings];
        
        // 注册获得device Token
        [application registerForRemoteNotifications];
    }
    
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error API_AVAILABLE(ios(3.0)) {
    MAXLog(@"%@", error);
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    if (![deviceToken isKindOfClass:[NSData class]]) return;
    const unsigned *tokenBytes = [deviceToken bytes];
    NSString *hexToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                          ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                          ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                          ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
    MAXLog(@"deviceToken:%@", hexToken);
    
    
//    NSString *deviceTokenStr = [[[[deviceToken description]
//                                  stringByReplacingOccurrencesOfString:@"<" withString:@""]
//                                 stringByReplacingOccurrencesOfString:@">" withString:@""]
//                                stringByReplacingOccurrencesOfString:@" " withString:@""];
//    MAXLog(@"deviceTokenStr:\n%@",deviceTokenStr);
    [[NSUserDefaults standardUserDefaults] setObject:hexToken forKey:@"deviceToken"];
    
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
    NSString* dataDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"ChatData"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:dataDir]) {
        [fileManager createDirectoryAtPath:dataDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString* cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject stringByAppendingString:@"UserCache"];
    if (![fileManager fileExistsAtPath:cacheDir]) {
        [fileManager createDirectoryAtPath:cacheDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSLog(@"dataDir = %@", dataDir);
    NSLog(@"cacheDir = %@", cacheDir);
  
    NSString* phoneName = [[UIDevice currentDevice] name];
    NSString* localizedModel = [[UIDevice currentDevice] localizedModel];
    NSString* systemName = [[UIDevice currentDevice] systemName];
    NSString* phoneVersion = [[UIDevice currentDevice] systemVersion];
  
    NSString *phone = [NSString stringWithFormat:@"设备名称:%@;%@;%@;%@", phoneName,localizedModel,systemName,phoneVersion];
    BMXSDKConfig *config  = [[BMXSDKConfig alloc] initConfigWithDataDir:dataDir cacheDir:cacheDir pushCertName:@"NotiCer_Product" userAgent:phone];
    config.appID = [AppIDManager sharedManager].appid.appId;
    config.loadAllServerConversations = YES;
    
    IMAcount *accout = [IMAcountInfoStorage loadObject];
    if (accout.isLogin) {
        if ([HostConfigManager checkLocalConfig]) {
            
            BMXHostConfig *hostConfig = [[BMXHostConfig alloc] initWithRestHostConfig:[HostConfigManager sharedManager].restServer imPort:[[HostConfigManager sharedManager].IMPort intValue] imHost:[HostConfigManager sharedManager].IMServer];
            config.hostConfig = hostConfig;
            config.enableDNS = NO;

        } else {
            config.enableDNS = YES;
        }
    } else {
        config.enableDNS = YES;

    }
    [[BMXClient sharedClient] registerWithSDKConfig:config];
}

- (void)reloadAppID:(NSString *)appid {
    
    [AppIDManager changeAppid:appid isSave:NO];
    [[BMXClient sharedClient] changeAppID:appid completion:^(BMXError * _Nonnull error) {
        
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
    
    BOOL firstLauch = [[NSUserDefaults standardUserDefaults] boolForKey:@"MAXFirstLauch"];
    if (!firstLauch) {
    
        MAXLauchVideoViewController *lauchVideoViewController = [[MAXLauchVideoViewController alloc] init];
        self.window.rootViewController = lauchVideoViewController;
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"MAXFirstLauch"];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeRootViewController) name:@"LauchVideoPlayeFinish" object:nil];
        
    }else {
    
        if (![IMAcountInfoStorage isHaveLocalData]) {
            self.window.rootViewController = [LoginViewController loginViewWithViewControllerWithNavigation];
        }else {
            self.window.rootViewController = self.maintabController;
        }
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

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [WXApi handleOpenURL:url delegate:self];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    return [WXApi handleOpenURL:url delegate:self];
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    
    if ([options[UIApplicationOpenURLOptionsSourceApplicationKey] isEqualToString:@"com.tencent.xin"] && [url.absoluteString containsString:@"login"]) {
        [WXApi handleOpenURL:url delegate:self];
    }else{
        if ([url.absoluteString hasPrefix:@"MaxIMExtension://Roster"]) {
            //        NSString *imageUrl = [[url.absoluteString componentsSeparatedByString:@"MaxIMExtension://Roster&url="] lastObject];
            
            if(self.maintabController) {
                UINavigationController *nav = [self.maintabController.childViewControllers firstObject];
                RosterListViewController *roster =   [[RosterListViewController alloc] init];
                roster.hidesBottomBarWhenPushed = YES;
                [nav pushViewController:roster animated:YES];
            }
            
        } else {
            
            if(self.maintabController) {
                UINavigationController *nav = [self.maintabController.childViewControllers firstObject];
                GroupListSelectViewController *group =   [[GroupListSelectViewController alloc] init];
                group.hidesBottomBarWhenPushed = YES;
                [nav pushViewController:group animated:YES];
            }
    }

    }
    return YES;
}

- (void)onResp:(BaseResp *)resp{
    //判断是否是微信认证的处理结果
    if ([resp isKindOfClass:[SendAuthResp class]]) {
        SendAuthResp *temp = (SendAuthResp *)resp;
        //如果你点击了取消，这里的temp.code 就是空值
        if (temp.code != NULL) {
            
            WechatLoginApi *api = [[WechatLoginApi alloc] initWithCode:temp.code];
            [api startWithSuccessBlock:^(ApiResult * _Nullable result) {
                if ( result.isOK) {
                    if (!result.resultData[@"password"] ) {
                       //  注册登录
                        [HQCustomToast showDialog:@"请登录注册绑定微信"];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"wechatloginsuccess_newuser" object:result.resultData];
                    } else {
                        
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

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary * _Nonnull)userInfo fetchCompletionHandler:(void (^ _Nonnull)(UIBackgroundFetchResult))completionHandler{
    MAXLog(@"didReceiveRemoteNotification:%@",userInfo);
}

- (void)applicationWillResignActive:(UIApplication *)application {

}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    //进入后台
    [[BMXClient sharedClient] disConnect];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // app从后台进入前台都会调用这个方法
    //    if (application.applicationIconBadgeNumber > 0) {
    //        application.applicationIconBadgeNumber = 0;
    //    }
    
    IMAcount *accout = [IMAcountInfoStorage loadObject];
    if (accout) {
        [[BMXClient sharedClient]  reconnect];
        MAXLog(@"reconnect");
        
    }
}



- (void)applicationWillTerminate:(UIApplication *)application {
    MAXLog(@"程序被杀死，applicationWillTerminate");
    [[BMXClient sharedClient] disConnect];
}


@end
