//
//  MAXLoginViewController.m
//  MaxIM
//
//  Created by hyt on 2018/12/1.
//  Copyright © 2018 hyt. All rights reserved.
//

#import "MAXLoginViewController.h"
#import "MAXRegiesterViewController.h"
#import "MAXLoginView.h"
#import <floo-ios/BMXClient.h>
#import "IMAcountInfoStorage.h"
#import "IMAcount.h"
#import "MAXGlobalTool.h"
#import <floo-ios/BMXUserProfile.h>
#import <floo-ios/BMXHostConfig.h>
#import "LoginCodeImageViewController.h"
#import "WXApi.h"
#import "WechatApi.h"
#import "BindOpenIdApi.h"
#import "GetTokenApi.h"
#import "ScanViewController.h"
#import "NotifierBindApi.h"
#import "ConsuleAppInfo.h"
#import "ConsuleAppInfoStorage.h"
#import "AppDelegate.h"

#import "ConsoleAppID.h"
#import "ConsoleAppIDStorage.h"


@interface MAXLoginViewController ()<WXApiDelegate>

@property (nonatomic, strong) MAXLoginView *contentView;

@property (nonatomic, strong) UIButton *configButton;

@property (nonatomic,copy) NSString *scanConsuleUserName;

@property (nonatomic, strong) NSDictionary *scanConsuleResultDic;

@end

@implementation MAXLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupContentView];
    [self configButton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(login) name:@"wechatloginsuccess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jumpToRegistVC:) name:@"wechatloginsuccess_newuser" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inputUserTextFeild:) name:@"ScanConsule" object:nil];

}

- (void)setupContentView {
     __weak MAXLoginViewController *weakSelf = self;
  
    if (self.openId.length <= 0 ) {
        
        [self.contentView addappIDLabelButtonClickWithTitle:@"welovemaxim" buttonClick:^{
            [weakSelf showAppIDEditAlert];
            
        }];
        
        [self.contentView addTransformButtonWithTitle:@"注册" buttonClick:^{
            MAXRegiesterViewController *regiesterViewController = [[MAXRegiesterViewController alloc] init];
            [weakSelf presentViewController:regiesterViewController animated:YES completion:nil];
        }];
        
        
        
        if ([WXApi isWXAppInstalled]) {
            [self.contentView addOtherLoginButtonWithTitle:@"微信登录" buttonClick:^{
                [weakSelf weChatLogin];
            }];
        }
        
        
        [self.contentView addScanConsuleButtonClickWithTitle:nil buttonClick:^{
            [weakSelf jumpToScanViewController];
        }];
        
//
//        [self.contentView addscanLoginButtonWithTitle:@"扫描二维码登录" buttonClick:^{
//            [weakSelf presentViewController:[LoginCodeImageViewController alloc] animated:YES completion:nil];
//        }];
        
    }else {

        [self.contentView addCloseButtonWithbuttonClick:^{
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        }];
        [self.contentView changeCommitBtnName:@"" confirmButtonName:@"登录并绑定" closeBtnName:@"注册新账号"];
        
    }
}

- (void)jumpToScanViewController {
    ScanViewController *vc = [[ScanViewController alloc] init];
    vc.modalPresentationStyle =  UIModalPresentationFullScreen;
    [self presentViewController:vc animated:YES completion:nil];
}


- (void)jumpToRegistVC:(NSNotification *)notify {
    NSDictionary *dict = notify.object;
    if (dict) {
        
        NSString *openId = [dict objectForKey:@"openid"];
        MAXRegiesterViewController *regiestervc = [[MAXRegiesterViewController alloc] init];
        regiestervc.openId = openId;
        [self presentViewController:regiestervc animated:YES completion:nil];
    }
}

- (void)inputUserTextFeild:(NSNotification *)noti {
    NSDictionary *dic = noti.object;
    if (dic) {
        self.scanConsuleUserName = dic[@"userName"];
        [self.contentView inputUserName:self.scanConsuleUserName];
        
        [self.contentView addappIDLabelButtonClickWithTitle:dic[@"appId"] buttonClick:^{
//            BMXAppID = dic[@"appId"];
        }];
    }
    self.scanConsuleResultDic = dic;
}

- (void)login {
    IMAcount *account = [IMAcountInfoStorage loadObject];
    [self signById:[account.usedId integerValue] password:account.password];
}




- (void)weChatLogin {
//        方法一：只有手机安装了微信才能使用
    if ([WXApi isWXAppInstalled]) {
        SendAuthReq *req = [[SendAuthReq alloc] init];
        //这里是按照官方文档的说明来的此处我要获取的是个人信息内容
        req.scope = @"snsapi_userinfo";
        req.state = @"login";
        //向微信终端发起SendAuthReq消息
        [WXApi sendReq:req];
    } else {
        [HQCustomToast showDialog:@"请安装微信客户端"];
        MAXLog(@"安装微信客户端");
    }
    
//        方法二：手机没有安装微信也可以使用，推荐使用这个
//    SendAuthReq *req = [[SendAuthReq alloc] init];
//    req.scope = @"snsapi_userinfo";
//    req.state = @"123";
//    [WXApi sendAuthReq:req viewController:self delegate:self];
}

- (void)initializeBMXWithHostDict:(NSDictionary *)dic {
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
    
    
    if (dic != nil) {
        BMXHostConfig *hostconfig = [[BMXHostConfig alloc] initWithRestHostConfig:dic[@"hostconfig"]
                                                                           imPort:[dic[@"import"] intValue]
                                                                           imHost:dic[@"imhost"]];
        config.hostConfig = hostconfig;
        
    }
    config.loadAllServerConversations = YES;
    [[BMXClient sharedClient] registerWithSDKConfig:config];
    [HQCustomToast showDialog:@"切换成功"];
}

- (MAXLoginView *)contentView {
    if (!_contentView) {
        _contentView = [MAXLoginView createLoginVieWithTitle:@"密码登录" buttonClick:^(NSString *username,NSString *password){
            [self signByName:username password:password];
        }];
        [self.view addSubview:_contentView];
    }
    return _contentView;
}


- (void)signById:(NSInteger)userid
        password:(NSString *)password {
    [HQCustomToast showWating];
    [[[BMXClient sharedClient] userService] signInById:userid password:password completion:^(BMXError *error) {
        [HQCustomToast hideWating];
        if (!error) {
            MAXLog(@"登录成功 username = %lld , password = %@",userid, password);
            
            [self willMoveToParentViewController:nil];
            [self removeFromParentViewController];
            [self.view removeFromSuperview];
            
            IMAcount *a = [IMAcountInfoStorage loadObject];
            a.isLogin = YES;
            a.password = password;
            a.usedId = [NSString stringWithFormat:@"%ld", (long)userid];
            //            a.userName = [NSString stringWithFormat:@"%@", name];
            [IMAcountInfoStorage saveObject: a];
            [UIApplication sharedApplication].delegate.window.rootViewController = [MAXGlobalTool share].rootViewController;
            [[MAXGlobalTool share].rootViewController addIMListener];
            [self bindToken];
            [self getProfile];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"loginSuccess" object:nil];
            [HQCustomToast showDialog:@"登录成功"];
            //            [self bindWechat];
            
            
            //            IMAcount *a = [[IMAcount alloc] init];
            //            a.isLogin = YES;
            //            a.password = password;
            //            a.usedId = [NSString stringWithFormat:@"%ld", (long)userid];
            //            [IMAcountInfoStorage saveObject: a];
            [[MAXGlobalTool share].rootViewController addIMListener];
        }else {
            [HQCustomToast showDialog:[NSString stringWithFormat:@"%@",error.errorMessage]];
            
            MAXLog(@"失败 errorCode = %lu ", error.errorCode);
        }
    }];
}

- (void)signByName:(NSString *)name password:(NSString *)password {
    [HQCustomToast showWating];
    [[[BMXClient sharedClient] userService] signInByName:name password:password completion:^(BMXError *error) {
        [HQCustomToast hideWating];
        if (!error) {
            MAXLog(@"登录成功 username = %@ , password = %@",name, password);

            [self willMoveToParentViewController:nil];
            [self removeFromParentViewController];
            [self.view removeFromSuperview];
            
            IMAcount *a = [[IMAcount alloc] init];
            a.isLogin = YES;
            a.password = password;
            a.userName = [NSString stringWithFormat:@"%@", name];
            [IMAcountInfoStorage saveObject: a];
            [UIApplication sharedApplication].delegate.window.rootViewController = [MAXGlobalTool share].rootViewController;
            [[MAXGlobalTool share].rootViewController addIMListener];
            [self bindToken];
            [self getProfile];
            
            [self uploadAppIdIfNeededWithUserName:name];
            
            ConsoleAppID *appidModel = [[ConsoleAppID alloc] init];
            BMXSDKConfig *sdkconfig = [[BMXClient sharedClient] sdkConfig];
            appidModel.appId = sdkconfig.appID;
            [ConsoleAppIDStorage saveObject:appidModel];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"loginSuccess" object:nil];
            [HQCustomToast showDialog:@"登录成功"];

        }else {
            MAXLog(@"失败 errorCode = %lu ", error.errorCode);
            [HQCustomToast showDialog:[NSString stringWithFormat:@"%@", error.errorMessage]];
        }
    }];
}


- (void)uploadAppIdIfNeededWithUserName:(NSString *)userName {
    if (!self.scanConsuleResultDic) {
        MAXLog(@"scanConsuleResultDic为空，异常");
        return;
    }
    if ([self.scanConsuleUserName isEqualToString:userName]) {
        NSString *deviceToken = [[NSUserDefaults standardUserDefaults] valueForKey:@"deviceToken"];
        
        NSString *appid = self.scanConsuleResultDic[@"appId"];
        NSString *userid = self.scanConsuleResultDic[@"uid"];
        
        NotifierBindApi *api = [[NotifierBindApi alloc] initWithAppID:appid
                                                          deviceToken:deviceToken
                                                         notifierName:@"NotiCer"
                                                               userID:userid];
        
        [api startWithSuccessBlock:^(ApiResult * _Nullable result) {
            if (result.isOK) {
                MAXLog(@"bind success");
                ConsuleAppInfo *appInfo = [[ConsuleAppInfo alloc] init];
                appInfo.appId = appid;
                appInfo.uuid = userid;
                appInfo.deviceToken = deviceToken;
                [ConsuleAppInfoStorage saveObject:appInfo];
            }
            
        } failureBlock:^(NSError * _Nullable error) {
            MAXLog(@"consule绑定失败");
        }];
        
    }
}


- (void)bindToken {
    NSString *deviceToken = [[NSUserDefaults standardUserDefaults] valueForKey:@"deviceToken"];
    if ([deviceToken length]) {
        [[[BMXClient sharedClient] userService] bindDevice:deviceToken completion:^(BMXError *error) {
            MAXLog(@"绑定成功");
        }];
    }
}

- (void)getProfile {
    [[[BMXClient sharedClient] userService] getProfileForceRefresh:NO completion:^(BMXUserProfile *profile, BMXError *aError) {
        if (!aError) {
            IMAcount *account = [IMAcountInfoStorage loadObject];
            account.usedId = [NSString stringWithFormat:@"%lld", profile.userId];
            account.userName = profile.userName;
            [IMAcountInfoStorage saveObject:account];
            
            [self getAppTokenWithName:profile.userName password:account.password];

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
            
            if (self.openId) {
                [self bindWechat];

            }

        }
    } failureBlock:^(NSError * _Nullable error) {
        
    }];
}

- (void)showAppIDEditAlert {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"修改AppID"
                                                                   message:@"如果需要更改需要重启客户端"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
                                                         //响应事件
                                                         //得到文本信息
                                                         for(UITextField *text in alert.textFields){
                                                             MAXLog(@"text = %@", text.text);
                                                             [self reloadAppID:text.text];
                                                             
                                                             [self.contentView addappIDLabelButtonClickWithTitle:text.text buttonClick:^{
                                                                 //            BMXAppID = dic[@"appId"];
                                                             }];
                                                             
                                                         }
                                                     }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {
                                                             //响应事件
                                                             MAXLog(@"action = %@", alert.textFields);
                                                         }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"请输入AppID";
    }];
    
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)reloadAppID:(NSString *)appid {
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate reloadAppID:appid];
}

//
- (void)showAlert {
//    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"更改host" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
//
//    UIAlertAction* action1 = [UIAlertAction actionWithTitle:@"核心集群" style:UIAlertActionStyleDefault
//                                                    handler:^(UIAlertAction * action) {
////                                                    HostConfig:@"xsync.zidanduanxin.com"
////                                                    imPort:443
////                                                    imHost:@"https://ratel.zidanduanxin.com"
//                                                        NSDictionary *dic = @{@"hostconfig":@"c1-sync.kube.maxim.top",
//                                                                              @"import":@"443",
//                                                                              @"imhost":@"https://c1-api.kube.maxim.top"};
//                                                        [self initializeBMXWithHostDict:dic];
//
//                                                    }];
//    UIAlertAction* action2 = [UIAlertAction actionWithTitle:@"从属集群1" style:UIAlertActionStyleDefault
//                                                    handler:^(UIAlertAction * action) {
//
//                                                        NSDictionary *dic = @{@"hostconfig":@"s1-sync.kube.maxim.top",
//                                                                              @"import":@"443",
//                                                                              @"imhost":@"https://s1-api.kube.maxim.top"};
//                                                        [self initializeBMXWithHostDict:dic];
//
//
//                                                    }];
//    UIAlertAction* action3 = [UIAlertAction actionWithTitle:@"从属集群2" style:UIAlertActionStyleDefault
//                                                    handler:^(UIAlertAction * action) {
//                                                        NSDictionary *dic = @{@"hostconfig":@"s2-sync.kube.maxim.top",
//                                                                              @"import":@"80",
//                                                                              @"imhost":@"https://s2-api.kube.maxim.top"};
//                                                        [self initializeBMXWithHostDict:dic];
//
//                                                    }];
//    UIAlertAction* action4 = [UIAlertAction actionWithTitle:@"恢复默认" style:UIAlertActionStyleDefault
//                                                    handler:^(UIAlertAction * action) {
//                                                        [self initializeBMXWithHostDict:nil];
//
//
//                                                    }];
//    UIAlertAction* action5 = [UIAlertAction actionWithTitle:@"切子弹的环境" style:UIAlertActionStyleDefault
//                                                    handler:^(UIAlertAction * action) {
////
//                                                        NSDictionary *dic = @{@"hostconfig":@"xsync.zidanduanxin.com",
//                                                                              @"import":@"443",
//                                                                              @"imhost":@"https://ratel.zidanduanxin.com"};
//                                                        [self initializeBMXWithHostDict:dic];
//
//
//                                                    }];
//    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel
//                                                         handler:^(UIAlertAction * action) {
//
//
//                                                         }];
//    [alert addAction:action1];
//    [alert addAction:action2];
//    [alert addAction:action3];
//    [alert addAction:action4];
//    [alert addAction:action5];
//    [alert addAction:cancelAction];
//    [self presentViewController:alert animated:YES completion:nil];
}
//

- (UIButton *)configButton {
    if (_configButton == nil) {
        _configButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _configButton.frame = CGRectMake(60, 60, 50, 50);
        _configButton.titleLabel.text = @"切换环境";
        
        [_configButton addTarget:self action:@selector(showAlert) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_configButton];
    }
    return _configButton;
}
- (void)bindWechat {
    
    
    BindOpenIdApi *api = [[BindOpenIdApi alloc] initWithopenId:self.openId];
    [api startWithSuccessBlock:^(ApiResult * _Nullable result) {
        if (result.isOK) {
//            [HQCustomToast showDialog:@"绑定成功"];
        } else {
            [HQCustomToast showDialog:@"绑定失败"];

        }
    } failureBlock:^(NSError * _Nullable error) {
        [HQCustomToast showDialog:@"绑定失败"];
    }];
}

@end
