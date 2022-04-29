//
//  MAXRegiesterViewController.m
//  MaxIM
//
//  Created by hyt on 2018/12/1.
//  Copyright © 2018 hyt. All rights reserved.
//

#import "MAXRegiesterViewController.h"
#import "MAXLoginViewController.h"
#import "MAXLoginView.h"
#import "BMXClient.h"
#import "BMXUserProfile.h"
#import "BindOpenIdApi.h"
#import "PravitcyViewController.h"
#import <WebKit/WebKit.h>
#import "AppDelegate.h"

@interface MAXRegiesterViewController ()

@property (nonatomic, strong) MAXLoginView *contentView;

@end

@implementation MAXRegiesterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupContentView];
    
}


- (UIModalPresentationStyle)modalPresentationStyle {
    return UIModalPresentationFullScreen;
} 


- (void)checkTime {
    
}


- (void)setupContentView {
    
    __weak MAXRegiesterViewController *weakSelf = self;
    
    [self.contentView addappIDLabelButtonClickWithTitle:@"welovemaxim" buttonClick:^{
           [weakSelf showAppIDEditAlert];
       }];
       
    [self.contentView addCloseButtonWithbuttonClick:^{
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    }];


    [self.contentView addPhoneTextfieldWithSmsbuttonClick:^{

    } commitClicke:^(NSString *username, NSString *password, NSString *phone, NSString *vertifyCode) {

        MAXLog(@"username = %@, password = %@ , phone = %@, vertify = %@", username,  password, phone, vertifyCode);
        [weakSelf userRegiesterMobile:phone username:username ? username : @"" password:password vertifyCode:vertifyCode];
    }];

    [self.contentView addSmsButtonWithbuttonClick:^{
        [weakSelf.contentView smsButtonhighlight:YES];

    }];


    [self.contentView addPrivateLabelWithTitle:@"" buttonClick:^{

        [weakSelf presentViewController:[[PravitcyViewController alloc] init] animated:YES completion:^{

        }];
    }];

    if (self.openId.length > 0) {
        [self.contentView changeCommitBtnName:NSLocalizedString(@"Register_and_bind", @"注册并绑定") confirmButtonName:@"" closeBtnName:NSLocalizedString(@"Login_with_account", @"账号登录")];
        [self.contentView addWechatTransformButtonWithTitle:NSLocalizedString(@"Already_have_an_account", @"已有账号") buttonClick:^{
            MAXLoginViewController *loginVC = [[MAXLoginViewController alloc] init];
            loginVC.openId = weakSelf.openId;
            [weakSelf presentViewController:loginVC animated:YES completion:nil];
        }];
    }
}

- (MAXLoginView *)contentView {
    
    if (!_contentView) {
        _contentView = [MAXLoginView createLoginVieWithTitle:NSLocalizedString(@"Register", @"注册") buttonClick:nil];
        [self.view addSubview:_contentView];
    }
    return _contentView;
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
                                                             [self reloadAppID:text.text];
                                                             
                                                             [self.contentView addappIDLabelButtonClickWithTitle:text.text buttonClick:^{
                                                                 //            BMXAppID = dic[@"appId"];
                                                             }];
                                                             
                                                         }
                                                     }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"取消") style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {
                                                             //响应事件
                                                             MAXLog(@"action = %@", alert.textFields);
                                                         }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = NSLocalizedString(@"enter_AppID", @"请输入AppID");
    }];
    
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}


- (void)userRegiesterMobile:(NSString *)mobile
                   username:(NSString *)username
                     password:(NSString *)password
                  vertifyCode:(NSString *)vertifyCode {
    
    if (mobile.length == 0) {
        MAXLog(NSLocalizedString(@"enter_phone_number", @"请输入手机号"));
        return;
    }
    if (password.length == 0) {
        MAXLog(@"请输入密码");
        return;
    }
    if (vertifyCode.length == 0) {
        MAXLog(NSLocalizedString(@"enter_your_captcha", @"请输入验证码"));
        return;
    }
    
    MAXLog(@"开始注册");
    [HQCustomToast showWating];
    
#warning 1.1
//    [[BMXClient sharedClient] signUpMobile:mobile password:password vertifyCode:vertifyCode userName:username completion:^(BMXUserProfile *profile, BMXError *aError) {
//
//        [HQCustomToast hideWating];
//        if(!aError) {
//            [HQCustomToast hideWating];
//            [HQCustomToast showDialog:@"注册成功"];
//            if ([self.openId length] > 0) {
//                [self bindWechat];
//
//            }
//
//            [self dismissViewControllerAnimated:YES completion:^{
//
//            }];
//        }  else {
//            [HQCustomToast showDialog:aError.errorMessage];
//        }
//        MAXLog(@"%@", aError);
//
//    }];



}
- (void)bindWechat {
    BindOpenIdApi *api = [[BindOpenIdApi alloc] initWithopenId:self.openId];
    [api startWithSuccessBlock:^(ApiResult * _Nullable result) {
          [HQCustomToast showDialog:NSLocalizedString(@"Bind_successfully", @"绑定成功")];
    } failureBlock:^(NSError * _Nullable error) {
          [HQCustomToast showDialog:NSLocalizedString(@"Failed_to_bind", @"绑定失败")];
    }];
}
- (void)reloadAppID:(NSString *)appid {
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate reloadAppID:appid];
}

@end
