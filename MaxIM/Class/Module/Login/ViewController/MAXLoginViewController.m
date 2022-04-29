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
#import "BMXClient.h"
#import "IMAcountInfoStorage.h"
#import "IMAcount.h"
#import "MAXGlobalTool.h"
#import "BMXUserProfile.h"
#import "BMXHostConfig.h"
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
        
        [self.contentView addTransformButtonWithTitle:NSLocalizedString(@"Register", @"注册") buttonClick:^{
            MAXRegiesterViewController *regiesterViewController = [[MAXRegiesterViewController alloc] init];
            [weakSelf presentViewController:regiesterViewController animated:YES completion:nil];
        }];
        
        
        
        if ([WXApi isWXAppInstalled]) {
            [self.contentView addOtherLoginButtonWithTitle:NSLocalizedString(@"Login_with_WeChat_account", @"微信登录") buttonClick:^{
                [weakSelf weChatLogin];
            }];
        }
        
        
        [self.contentView addScanConsuleButtonClickWithTitle:nil buttonClick:^{
            [weakSelf jumpToScanViewController];
        }];
        
//
//        [self.contentView addscanLoginButtonWithTitle:NSLocalizedString(@"Scan_QR_Code_to_login", @"扫描二维码登录") buttonClick:^{
//            [weakSelf presentViewController:[LoginCodeImageViewController alloc] animated:YES completion:nil];
//        }];
        
    }else {

        [self.contentView addCloseButtonWithbuttonClick:^{
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        }];
        [self.contentView changeCommitBtnName:@"" confirmButtonName:NSLocalizedString(@"Login_and_bind", @"登录并绑定") closeBtnName:NSLocalizedString(@"Register_a_new_account", @"注册新账号")];
        
    }
}

- (void)jumpToScanViewController {

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
 
}




- (void)weChatLogin {
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
    
    NSString *phone = [NSString stringWithFormat:NSLocalizedString(@"Device_name_name", @"设备名称:%@;%@;%@;%@"), phoneName,localizedModel,systemName,phoneVersion];
    BMXSDKConfig *config  = [[BMXSDKConfig alloc] initConfigWithDataDir:dataDir cacheDir:cacheDir pushCertName:@"NotiCer_Product" userAgent:phone];
    
    
    if (dic != nil) {
        BMXHostConfig *hostconfig = [[BMXHostConfig alloc] initWithRestHostConfig:dic[@"hostconfig"]
                                                                           imPort:[dic[@"import"] intValue]
                                                                           imHost:dic[@"imhost"]];
        config.hostConfig = hostconfig;
        
    }
    config.loadAllServerConversations = YES;
    [[BMXClient sharedClient] registerWithSDKConfig:config];
    [HQCustomToast showDialog:NSLocalizedString(@"Switch_successfully", @"切换成功")];
}

- (MAXLoginView *)contentView {
    if (!_contentView) {
        _contentView = [MAXLoginView createLoginVieWithTitle:NSLocalizedString(@"Login_with_password", @"密码登录") buttonClick:^(NSString *username,NSString *password){
            [self signByName:username password:password];
        }];
        [self.view addSubview:_contentView];
    }
    return _contentView;
}


- (void)signById:(NSInteger)userid
        password:(NSString *)password {
}

- (void)signByName:(NSString *)name password:(NSString *)password {
}


- (void)uploadAppIdIfNeededWithUserName:(NSString *)userName {
}


- (void)bindToken {
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
}

- (void)reloadAppID:(NSString *)appid {
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
//    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"取消") style:UIAlertActionStyleCancel
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
        _configButton.titleLabel.text = NSLocalizedString(@"Switch_environment", @"切换环境");
        
        [_configButton addTarget:self action:@selector(showAlert) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_configButton];
    }
    return _configButton;
}
- (void)bindWechat {
    
    
    BindOpenIdApi *api = [[BindOpenIdApi alloc] initWithopenId:self.openId];
    [api startWithSuccessBlock:^(ApiResult * _Nullable result) {
        if (result.isOK) {
//            [HQCustomToast showDialog:NSLocalizedString(@"Bind_successfully", @"绑定成功")];
        } else {
            [HQCustomToast showDialog:NSLocalizedString(@"Failed_to_bind", @"绑定失败")];

        }
    } failureBlock:^(NSError * _Nullable error) {
        [HQCustomToast showDialog:NSLocalizedString(@"Failed_to_bind", @"绑定失败")];
    }];
}

@end
