//
//  LoginViewController.m
//  MaxIM
//
//  Created by 韩雨桐 on 2019/11/16.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "LoginViewController.h"
#import "UIViewController+CustomNavigationBar.h"
#import <SafariServices/SFSafariViewController.h>
#import "ScanViewController.h"
#import "LoginView.h"
#import "AppDelegate.h"

#import "WXApi.h"
#import "WechatApi.h"
#import "IMAcountInfoStorage.h"
#import "IMAcount.h"
#import "MAXGlobalTool.h"
#import "GetTokenApi.h"
#import "AppIDManager.h"
#import "NotifierBindApi.h"
#import "BindOpenIdApi.h"
#import "UserMobileBindApi.h"
#import "AppUserInfoPwdApi.h"
#import "UserMobileBindWithSignApi.h"

#import "TokenIdApi.h"
#import "AccountManagementManager.h"
#import "LogViewController.h"

#import "SDKConfigViewController.h"

#import <floo-ios/floo_proxy.h>
#import "PrivacyView.h"

@interface LoginViewController ()<LoginViewConfigProtocol, SDKConfigViewControllerProtocl, PrivacyProtocol>

@property (nonatomic, strong) LoginViewConfig *config;
@property (nonatomic,copy) NSString *scanConsuleUserName;
@property (nonatomic, strong) NSDictionary *scanConsuleResultDic;
@property (nonatomic, strong) LoginView *loginView_Password;
@property (nonatomic, strong) LoginView *loginView_Captcha;
@property (nonatomic, strong) LoginView *loginView_Register;
@property (nonatomic, strong) LoginView *loginView;
@property (nonatomic, assign) BOOL privacyChecked;

@end

@implementation LoginViewController

+ (UIViewController *)loginViewWithViewControllerWithNavigation{
    
    LoginViewController *loginViewController =  [[LoginViewController alloc] initWithViewType:LoginVCTypePasswordLogin];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginViewController];
    return nav;
}


- (instancetype)initWithViewType:(LoginVCType)viewType {
 
    self = [self init];
    if (self) {
        self.config = [[LoginViewConfig alloc] initWithViewType:viewType];
        self.config.delegate = self;
        [self setupUI];
    }
    return self;

}

- (void)setupUI {
    if(self.config.viewType == LoginVCTypeCaptchLogin ||
       self.config.viewType == LoginVCTypePasswordLogin ||
       self.config.viewType == LoginVCTypeRegister){
        self.config.viewType = LoginVCTypeRegister;
        self.loginView_Register = [self.config creteLoginView];
        
        self.config.viewType = LoginVCTypePasswordLogin;
        self.loginView_Password = [self.config creteLoginView];
        
        self.config.viewType = LoginVCTypeCaptchLogin;
        self.loginView_Captcha = [self.config creteLoginView];
        [self.view addSubview:self.loginView_Captcha];
        self.loginView = self.loginView_Captcha;
    }else{
        LoginView *loginView = [self.config creteLoginView];
        [self.view addSubview:loginView];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer*)gestureRecognizer {
    if(self.navigationController.viewControllers.count <=1) {
        return NO;
    }
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wechatSuccessloginIM) name:@"wechatloginsuccess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jumpToRegistVC:) name:@"wechatloginsuccess_newuser" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inputUserTextFeild:) name:@"ScanConsule" object:nil];
    
    [self.config setAppid:[AppIDManager sharedManager].appid.appId];

    UIWindow *keyWindow;
    if (@available(iOS 13.0, *)) {
        keyWindow = [UIApplication sharedApplication].windows.firstObject;
    }else {
        keyWindow = [UIApplication sharedApplication].keyWindow;
    }
    [PrivacyView showPrivacyWithMaxTimeInterval:-1 view:self.view staticKey:@"maxim_privacy" privacyUrl:NSLocalizedString(@"protocol_privacy", @"https://www.lanyingim.com/privacy") delegate:self];
    _privacyChecked = false;
}

#pragma mark - delegate

- (void)popViewController {
 
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)popRootViewController {
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)smsLogin{
    [UIView transitionFromView:self.loginView toView:self.loginView_Captcha duration:0.5 options:UIViewAnimationOptionTransitionFlipFromLeft completion:nil];
    self.loginView = self.loginView_Captcha;
    self.config.loginView = self.loginView;
    self.loginView.delegate = self.config;
    [self.config setAppid:[AppIDManager sharedManager].appid.appId];
    [self reloadLocalAppID:[AppIDManager sharedManager].appid.appId];
}

- (void)passwordLogin{
    [UIView transitionFromView:self.loginView toView:self.loginView_Password duration:0.5 options:UIViewAnimationOptionTransitionFlipFromLeft completion:nil];
    self.loginView = self.loginView_Password;
    self.config.loginView = self.loginView;
    self.loginView.delegate = self.config;
    [self.config setAppid:[AppIDManager sharedManager].appid.appId];
    [self reloadLocalAppID:[AppIDManager sharedManager].appid.appId];
}

- (void)signUp{
    [UIView transitionFromView:self.loginView toView:self.loginView_Register duration:0.5 options:UIViewAnimationOptionTransitionFlipFromLeft completion:nil];
    self.loginView = self.loginView_Register;
    self.config.loginView = self.loginView;
    self.loginView.delegate = self.config;
    [self.config setAppid:[AppIDManager sharedManager].appid.appId];
    [self reloadLocalAppID:[AppIDManager sharedManager].appid.appId];
}

- (void)pushToSmsLogin {
    
    LoginViewController *smsLoginViewController = [[LoginViewController alloc] initWithViewType:LoginVCTypeCaptchLogin];
    [self.navigationController pushViewController:smsLoginViewController animated:YES];
}

- (void)pushToRegister {
    
    LoginViewController *regiesterViewController = [[LoginViewController alloc] initWithViewType:LoginVCTypeRegister];
    [self.navigationController pushViewController:regiesterViewController animated:YES];
}

- (void)showWebViewWithUrl: (NSString*)target {
    @try{
        NSURL *url = [NSURL URLWithString:target];
        SFSafariViewController *safariViewController = [[SFSafariViewController alloc] initWithURL:url];
        safariViewController.delegate = self;
        [self presentViewController:safariViewController animated:YES completion:nil];
    }@catch (NSException *exception) {
        MAXLog(@"%@",exception.description);
    }
}

- (void)showUserPrivacy {
    [self showWebViewWithUrl:NSLocalizedString(@"protocol_privacy", @"https://www.lanyingim.com/privacy")];
}

- (void)privacyLinkClick:(NSString *)url{
    [self showWebViewWithUrl:url];
}

- (void)privacyCheckButtonClick {
    _privacyChecked = !_privacyChecked;
    _loginView_Captcha.privacyCheckButton.selected = _privacyChecked;
    _loginView_Password.privacyCheckButton.selected = _privacyChecked;
    _loginView_Register.privacyCheckButton.selected = _privacyChecked;
}

- (void)showUserTerms {
    [self showWebViewWithUrl:NSLocalizedString(@"protocol_terms", @"https://www.lanyingim.com/terms")];
}

- (void)beginScanQRCode {
    
    ScanViewController *vc = [[ScanViewController alloc] init];
    vc.modalPresentationStyle =  UIModalPresentationFullScreen;
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)showLogVC {
    MAXLog(@"show log vc");
    
    LogViewController *vc = [[LogViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    
}

// 微信登录
- (void)loginByWechat {
 
    //        方法一：只有手机安装了微信才能使用
    if ([WXApi isWXAppInstalled]) {
        SendAuthReq *req = [[SendAuthReq alloc] init];
        //这里是按照官方文档的说明来的此处我要获取的是个人信息内容
        req.scope = @"snsapi_userinfo";
        req.state = @"login";
        //向微信终端发起SendAuthReq消息
        [WXApi sendReq:req completion:^(BOOL success) {
            
        }];
    } else {
        [HQCustomToast showDialog:NSLocalizedString(@"install_WeChat_client", @"请安装微信客户端")];
        MAXLog(@"安装微信客户端");
    }
}

// 用户名登录
- (void)signByName:(NSString *)name password:(NSString *)password {
    [self loginAndEntryMainVCWithName:name password:password];
}

// 验证码登录
- (void)signByPhone:(NSString *)phone captch:(NSString *)captch {
    MAXLog(@"验证码登录");
    
    AppUserInfoPwdApi *api = [[AppUserInfoPwdApi alloc] initWithMobile:phone captcha:captch];
    [api startWithSuccessBlock:^(ApiResult * _Nullable result) {
        if (result.isOK) {
            
            if (result.resultData[@"sign"]) {
                LoginViewController *bindUserViewController = [[LoginViewController alloc] initWithViewType:LoginVCTypeRegisterAndBindPhone];
                bindUserViewController.config.sign = result.resultData[@"sign"];
                bindUserViewController.config.phone = phone;
                [self.navigationController pushViewController:bindUserViewController animated:YES];
            } else {
                // 直接登录
                NSString *userName = result.resultData[@"username"];
                NSString *password = result.resultData[@"password"];
                [self loginAndEntryMainVCWithName:userName password:password];
            }
            
        } else if ([result.code isEqualToString:@"10001"]) {
            [HQCustomToast showDialog:NSLocalizedString(@"Captcha_incorrect", @"验证码不正确")];
        }        
    } failureBlock:^(NSError * _Nullable error) {
        [HQCustomToast showNetworkError];
    }];
}



// 用户名注册
- (void)regiesterWithName:(NSString *)name password:(NSString *)password {
    [[BMXClient sharedClient] signUpNewUserWithUsername:name password:password completion:^(BMXUserProfile *profile, BMXError *error) {
        if (error.errorCode == BMXErrorCode_NoError){
            [self registerLoginByName:name password:password];
        } else if (error.errorCode == BMXErrorCode_UserAlreadyExist){
            [self.config showErrorText:NSLocalizedString(@"This_username_already_exists", @"该用户名已存在")];
        } else if (error.errorCode == BMXErrorCode_InvalidRequestParameter) {
            [HQCustomToast showDialog:NSLocalizedString(@"username_constraint", @"用户名仅支持字母数字下划线中文组合，且不能是纯数字，不能以maxim、mta开头") time:5.0f];
        } else {
            [HQCustomToast showDialog:[error description]];
        }
    }];
}


// 手机验证码首次登录，进入绑定已有号码页面
- (void)pushToBindUserWithPhone {
    
    LoginViewController *bindNameViewController = [[LoginViewController alloc] initWithViewType:LoginVCTypeBindUserWithPhone];
    bindNameViewController.config.phone = self.config.phone;
    bindNameViewController.config.sign = self.config.sign;
    [self.navigationController pushViewController:bindNameViewController animated:YES];
}


// 手机验证码首次登录，绑定新注册用户
- (void)registerAndBindPhoneUserName:(NSString *)userName
                    password:(NSString *)password {
    // 注册
//    [[BMXClient sharedClient] signUpNewUser:userName password:password completion:^(BMXUserProfile * _Nonnull profile, BMXError * _Nonnull error) {
//        if (!error) {
//            // 登录
//            [self registerLoginBindByName:userName password:password];
//        } else if (error.errorCode == BMXUserAlreadyExist){
//            [self.config showErrorText:NSLocalizedString(@"This_username_already_exists", @"该用户名已存在")];
//        }
//    }];
    BMXUserProfile * userProfile = [[BMXUserProfile alloc] init];
    BMXErrorCode error = [[BMXClient sharedClient] signUpNewUserWithUsername:userName password:password bmxUserProfilePtr:userProfile];
    if (!error){
        [self registerLoginBindByName:userName password:password];
    } else if (error == BMXErrorCode_UserAlreadyExist){
        [self.config showErrorText:NSLocalizedString(@"This_username_already_exists", @"该用户名已存在")];
    }
}
// 手机验证码首次登录，绑定已有账号
- (void)bindPhoneWithName:(NSString *)name
                 password:(NSString *)password {
      [self bindPhoneWithUserName:name password:password phone:self.config.phone sign:self.config.sign];
}


// 首次微信登录，绑定新注册用户
- (void)regiesterAndBindWechatWithName:(NSString *)name
                              password:(NSString *)password {
    // 注册
//    [[BMXClient sharedClient] signUpNewUser:name password:password completion:^(BMXUserProfile * _Nonnull profile, BMXError * _Nonnull error) {
//        if (!error) {
//            // 登录
//            [self registerLoginBindByName:name password:password];
//        } else if (error.errorCode == BMXUserAlreadyExist){
//            [self.config showErrorText:NSLocalizedString(@"This_username_already_exists", @"该用户名已存在")];
//        } else {
//            [HQCustomToast showDialog:error.errorMessage];
//        }
//    }];
    [[BMXClient sharedClient] signUpNewUserWithUsername:name password:password completion:^(BMXUserProfile *profile, BMXError *error) {
        if (error.errorCode == BMXErrorCode_NoError){
            [self registerLoginBindByName:name password:password];
        } else if (error.errorCode == BMXErrorCode_UserAlreadyExist){
            [self.config showErrorText:NSLocalizedString(@"This_username_already_exists", @"该用户名已存在")];
        } else {
            [HQCustomToast showDialog:[error description]];
        }
    }];
}

// 首次微信登录，绑定已有账号
- (void)bindWechatWithName:(NSString *)name password:(NSString *)password {
//    [self bindWechatWithUserName:name password:password];
    [self registerLoginBindByName:name password:password];
}



// 绑定手机号
- (void)bindPhone:(NSString *)phone captch:(NSString *)captch {
    UserMobileBindApi *api = [[UserMobileBindApi alloc] initWithMobile:phone captach:captch];
    [api startWithSuccessBlock:^(ApiResult * _Nullable result) {
        if (result.isOK) {
            
        } else if([result.code isEqualToString:@"10015"]) {
            [HQCustomToast showDialog:NSLocalizedString(@"This_phone_number_has_been_bound", @"该手机号已绑定")];
        } else if([result.code isEqualToString:@"10001"]) {
            [HQCustomToast showDialog:NSLocalizedString(@"Captcha_does_not_match", @"验证码不匹配")];
//        } else if([result.code isEqualToString:@"11012"]) {
//            [HQCustomToast showDialog:NSLocalizedString(@"Captcha_does_not_match", @"手机号已被绑定")];
//        } else{
//            [HQCustomToast showDialog:NSLocalizedString(@"Captcha_does_not_match", @"未知错误")];
        }
    } failureBlock:^(NSError * _Nullable error) {
        [HQCustomToast showNetworkError];
    }];
    [self loginBlockdismiss];

    
}



- (void)endLoginView {
    [self disMissViewController];
}

- (void)loginBlockdismiss {
    
    [self willMoveToParentViewController:nil];
    [self removeFromParentViewController];
    [self.view removeFromSuperview];
    
    [UIApplication sharedApplication].delegate.window.rootViewController = [MAXGlobalTool share].rootViewController;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"loginSuccess" object:nil];
    [[MAXGlobalTool share].rootViewController addIMListener];

}

- (void)editAppid {
       
    SDKConfigViewController *vc = [[SDKConfigViewController alloc] init];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
//    [self showAppIDEditAlert];
}

- (void)sdkconfigdidClickReturn {
    [self.config setAppid:[AppIDManager sharedManager].appid.appId];
}

- (void)pushToBindNickNameWithWechatOpenId:(NSString *)wechatOpenId {
    
    LoginViewController *bindNameViewController = [[LoginViewController alloc] initWithViewType:LoginVCTypeBindUserWithWechat];
    bindNameViewController.config.wechatOpenId = wechatOpenId;
    [self.navigationController pushViewController:bindNameViewController animated:YES];
    
}

- (void)disMissViewController {
    
     [UIApplication sharedApplication].delegate.window.rootViewController = [MAXGlobalTool share].rootViewController;
    
}
#pragma mark - private

- (void)wechatSuccessloginIM {
    IMAcount *account = [IMAcountInfoStorage loadObject];
//    [self signById:[account.usedId integerValue] password:account.password];
    
    [self loginByName:account.userName password:account.password];
}

- (void)loginByName:(NSString *)userName
        password:(NSString *)password {
    [HQCustomToast showWating];
    
    [[BMXClient sharedClient] signInByNameWithName:userName password:password completion:^(BMXError *error) {
        [HQCustomToast hideWating];
        if (!error){
            MAXLog(@"登录成功 username = %@ , password = %@", userName, password);
            [self getAppTokenWithName:userName password:password];
            [self getProfile];
            [self willMoveToParentViewController:nil];
            [self removeFromParentViewController];
            [self.view removeFromSuperview];
            [self saveIMAcountName:userName password:password];
            [UIApplication sharedApplication].delegate.window.rootViewController = [MAXGlobalTool share].rootViewController;
            [self bindDeviceToken];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"loginSuccess" object:nil];
            [[MAXGlobalTool share].rootViewController addIMListener];
        } else {
            [HQCustomToast showDialog:[NSString stringWithFormat:@"%@",[error description]]];
            MAXLog(@"失败 errorCode = %lu ", error.errorCode);
        }
    }];
}

- (void)jumpToRegistVC:(NSNotification *)notify {
    NSDictionary *dict = notify.object;
    if (dict) {
        MAXLogDebug(@"WXAPI:jumpToRegistVC");
        NSString *openId = [dict objectForKey:@"openid"];
        LoginViewController *regiestervc = [[LoginViewController alloc] initWithViewType:LoginVCTypeRegisterAndBindWechat];
        regiestervc.config.wechatOpenId = openId;
        [self.navigationController pushViewController:regiestervc animated:YES];
    }
}
- (void)inputUserTextFeild:(NSNotification *)noti {
    if (self.config.viewType != LoginVCTypePasswordLogin){
        [self passwordLogin];
        self.config.viewType = LoginVCTypePasswordLogin;
    }
    NSDictionary *dic = noti.object;
    if (dic) {
        NSString *username = dic[@"userName"];
        NSString *password = dic[@"password"];
        NSString *appId = dic[@"appId"];

        self.scanConsuleUserName = username;
        [self reloadLocalAppID:appId];
        [self.config setAppid:appId];
        [self.config setUserName:username];
        [self.config setPassword:password];
        if(username.length > 0 && password.length > 0){
            [self signByName:username password:password];
        }
    }
    self.scanConsuleResultDic = dic;
}

- (void)showAppIDEditAlert {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Modify_AppID", @"修改AppID")
                                                                   message:NSLocalizedString(@"restart_the_client_to_make_the_change", @"如果需要更改需要重启客户端")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", @"确定") style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
                                                         //响应事件
                                                         //得到文本信息
                                                         for(UITextField *text in alert.textFields){
                                                             MAXLog(@"text = %@", text.text);
                                                             [self reloadLocalAppID:text.text];
                                                             [self.config setAppid:text.text];
                                                             
                                                         }
                                                     }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"取消") style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {
                                                             //响应事件
                                                             MAXLog(@"action = %@", alert.textFields);
                                                         }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = NSLocalizedString(@"enter_AppID", @"请输入App ID");
        textField.text = [AppIDManager sharedManager].appid.appId;
    }];
    
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)reloadLocalAppID:(NSString *)appid {
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate reloadAppID:appid];
}


- (void)saveIMAcountName:(NSString *)name password:(NSString *)password {
    
    IMAcount *a = [[IMAcount alloc] init];
    a.isLogin = YES;
    a.password = password;
    a.userName = [NSString stringWithFormat:@"%@", name];
    [IMAcountInfoStorage saveObject: a];
    
}

- (void)bindDeviceToken {
    NSString *deviceToken = [[NSUserDefaults standardUserDefaults] valueForKey:@"deviceToken"];
    if ([deviceToken length]) {
        [[[BMXClient sharedClient] userService] bindDeviceWithToken:deviceToken completion:^(BMXError *error) {
            if (!error){
                MAXLog(@"绑定成功%@", deviceToken);
            }
        }];
    }
}

- (void)getProfile{
    [[[BMXClient sharedClient] userService] getProfile: YES completion:^(BMXUserProfile *userProfile, BMXError *error) {
        if (!error){
            IMAcount *account = [IMAcountInfoStorage loadObject];
            account.usedId = [NSString stringWithFormat:@"%lld", userProfile.userId];
            account.userName = userProfile.username;
            [IMAcountInfoStorage saveObject:account];
            account.appid = [[BMXClient sharedClient] getSDKConfig].getAppID;
            [self saveAccountToLoaclListWithaccount:account];
            
            [[[BMXClient sharedClient] userService] downloadAvatarWithProfile:userProfile thumbnail:YES callback:^(int progress) {
                
            } completion:nil];
        }
    } ];
}

- (void)getAppTokenWithName:(NSString *)name password:(NSString *)password {
    GetTokenApi *api = [[GetTokenApi alloc] initWithName:name password:password];
    [api startWithSuccessBlock:^(ApiResult * _Nullable result) {
        if (result.isOK) {
            IMAcount *account = [IMAcountInfoStorage loadObject];
            NSDictionary *dic = result.resultData;
            account.token = dic[@"token"];
            [IMAcountInfoStorage saveObject:account];
            MAXLog(@"已获取token");
    
        }
    } failureBlock:^(NSError * _Nullable error) {

    }];
}

// 注册登录之后绑定手机号
- (void)bindPhoneWithUserName:(NSString *)userName
                     password:(NSString *)password
                        phone:(NSString *)phone
                      sign:(NSString *)sign {
    
    GetTokenApi *api = [[GetTokenApi alloc] initWithName:userName password:password];
    [api startWithSuccessBlock:^(ApiResult * _Nullable result) {
        if (result.isOK) {
            IMAcount *account = [IMAcountInfoStorage loadObject];
            if(!account){
                account = [[IMAcount alloc] init];
                account.usedId  = [NSString stringWithFormat:@"%@",result.resultData[@"user_id"]];
                account.password = password;
                account.userName = userName;
            }
            NSDictionary *dic = result.resultData;
            account.token = dic[@"token"];
            [IMAcountInfoStorage saveObject:account];
            [self bindPhoneWithPhone:phone sign:sign];
            
        }
    } failureBlock:^(NSError * _Nullable error) {
        
    }];
}


// 注册登录之后绑定微信号
- (void)bindWechatWithUserName:(NSString *)userName
                     password:(NSString *)password {
    
    GetTokenApi *api = [[GetTokenApi alloc] initWithName:userName password:password];
    [api startWithSuccessBlock:^(ApiResult * _Nullable result) {
        if (result.isOK) {
            IMAcount *account = [IMAcountInfoStorage loadObject];
            NSDictionary *dic = result.resultData;
            account.token = dic[@"token"];
            [IMAcountInfoStorage saveObject:account];
            [self bindWechat];
            
        }
    } failureBlock:^(NSError * _Nullable error) {
        
    }];
}

// 绑定手机号
- (void)bindPhoneWithPhone:(NSString *)phone
                         sign:(NSString *)sign {
    [self loginBlockdismiss];

    UserMobileBindWithSignApi *bindApi =  [[UserMobileBindWithSignApi alloc ] initWithMobile:phone sign:sign];
    [bindApi startWithSuccessBlock:^(ApiResult * _Nullable result) {
        if (result.isOK) {
        } else {
            [HQCustomToast showDialog:result.errmsg];
        }
    } failureBlock:^(NSError * _Nullable error) {
        [HQCustomToast showNetworkError];
    }];
}

// 绑定微信
- (void)bindWechat {
    [self loginBlockdismiss];

    BindOpenIdApi *api = [[BindOpenIdApi alloc] initWithopenId:self.config.wechatOpenId];
    [api startWithSuccessBlock:^(ApiResult * _Nullable result) {
        if (result.isOK) {
            [HQCustomToast showDialog:NSLocalizedString(@"Bind_successfully", @"绑定成功")];
        } else {
            [HQCustomToast showDialog:result.errmsg];
        }
    } failureBlock:^(NSError * _Nullable error) {
        [HQCustomToast showDialog:NSLocalizedString(@"Failed_to_bind", @"绑定失败")];
    }];
}


- (void)p_getTokenByID:(NSString *)userID password:(NSString *)password {
    TokenIdApi *api = [[TokenIdApi alloc] initWithUserID:userID password:password];
    [api startWithSuccessBlock:^(ApiResult * _Nullable result) {
        if (result.isOK) {
            IMAcount *account = [IMAcountInfoStorage loadObject];
            NSDictionary *dic = result.resultData;
            account.token = dic[@"token"];
            [IMAcountInfoStorage saveObject:account];
            MAXLog(@"已获取token");
            
        }
    } failureBlock:^(NSError * _Nullable error) {
        
    }];
}

#pragma mark - loginApi

// 直接登录
- (void)loginAndEntryMainVCWithName:(NSString *)name password:(NSString *)password {
    
    MAXLog(@"%@", [[BMXClient sharedClient] getSDKConfig].getHostConfig.getRestHost);
    
    [HQCustomToast showWating];
    [[BMXClient sharedClient] signInByNameWithName:name password:password completion:^(BMXError *error) {
        [HQCustomToast hideWating];
        if (!error){
            MAXLog(@"登录成功 username = %@ , password = %@",name, password);
            [self saveLastLoginAppid];
            [self getAppTokenWithName:name password:password];
            [self getProfile];
            [self bindDeviceToken];
            [self saveIMAcountName:name password:password];
            [self willMoveToParentViewController:nil];
            [self removeFromParentViewController];
            [self.view removeFromSuperview];
            [UIApplication sharedApplication].delegate.window.rootViewController = [MAXGlobalTool share].rootViewController;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"loginSuccess" object:nil];
            //            [HQCustomToast showDialog:@"登录成功"];
            [[MAXGlobalTool share].rootViewController addIMListener];
        } else {
            MAXLog(@"失败 errorCode = %lu ", error.errorCode);
            [HQCustomToast showDialog:[NSString stringWithFormat:@"%@", [error description]]];
        }
    }];
}

- (void)saveAccountToLoaclListWithaccount:(IMAcount *)account {
    [[AccountManagementManager sharedAccountManagementManager] addAccountUserName:account.userName password:account.password userid:account.usedId appid:account.appid];
}

- (void)saveLastLoginAppid {
    BMXSDKConfig *sdkconfig = [[BMXClient sharedClient] getSDKConfig];
    [AppIDManager changeAppid:sdkconfig.getAppID isSave:YES];
}

// 注册后的登录
- (void)registerLoginByName:(NSString *)name password:(NSString *)password {
    [HQCustomToast showWating];
    [[BMXClient sharedClient] signInByNameWithName:name password:password completion:^(BMXError *error) {
        [HQCustomToast hideWating];
        if (!error){
            MAXLog(@"登录成功 username = %@ , password = %@",name, password);
            [self saveLastLoginAppid];
            [self getAppTokenWithName:name password:password];
            [self saveIMAcountName:name password:password];
            [self bindDeviceToken];
            [self getProfile];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"loginSuccess" object:nil];
            LoginViewController *bindPhoneViewController = [[LoginViewController alloc] initWithViewType:LoginVCTypeBindPhone];
            [self.navigationController pushViewController:bindPhoneViewController animated:YES];
        } else {
            MAXLog(@"失败 errorCode = %lu ", error);
            [HQCustomToast showDialog:[NSString stringWithFormat:@"%@", [[BMXError errorCode:error] description]]];
        }
    }];
}

// 登录后需要绑定
- (void)registerLoginBindByName:(NSString *)name password:(NSString *)password {
    [HQCustomToast showWating];
    [[BMXClient sharedClient] signInByNameWithName:name password:password completion:^(BMXError *error) {
        [HQCustomToast hideWating];
        if (!error){
            MAXLog(@"登录成功 username = %@ , password = %@",name, password);
            [self saveLastLoginAppid];
            [self getAppTokenWithName:name password:password];
            [self getProfile];
            [self bindDeviceToken];
            [self saveIMAcountName:name password:password];
            if (self.config.phone.length > 0 && self.config.sign.length > 0) {
                [self bindPhoneWithUserName:name password:password phone:self.config.phone sign:self.config.sign];
            }else if (self.config.wechatOpenId.length > 0) {
                [self bindWechatWithUserName:name password:password];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"loginSuccess" object:nil];
        } else {
            MAXLog(@"失败 errorCode = %lu ", error);
            [HQCustomToast showDialog:[NSString stringWithFormat:@"%@", [[BMXError errorCode:error] description]]];
        }
    }];
}

@end
