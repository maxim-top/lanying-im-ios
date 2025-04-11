//
//  ScanViewController.m
//  NewSkyEyes
//
//  Created by hyt on 15/11/30.
//  Copyright © 2015年 jindidata. All rights reserved.
//

#import "ScanViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "SearchRosterProfileViewController.h"
#import "GroupBasicInfoViewController.h"
#import <floo-ios/floo_proxy.h>

#import "QRCodeLoginViewController.h"
#import "NotifierUploadPushInfoApi.h"
#import "AppDelegate.h"
#import "AppIDManager.h"
#import "IMAcountInfoStorage.h"
#import "UIViewController+CustomNavigationBar.h"
#import "UIView+BMXframe.h"
#import "LHTools.h"
#import "IMAcount.h"
#import "IMAcountInfoStorage.h"
#import "AllowLoginWithQRCodeApi.h"

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHigh [UIScreen mainScreen].bounds.size.height - 64

@interface ScanViewController ()<AVCaptureMetadataOutputObjectsDelegate,
    UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    int num;
    BOOL upOrdown;
    NSTimer * timer;
}
@property (strong,nonatomic)AVCaptureDevice *device;
@property (strong,nonatomic)AVCaptureDeviceInput *input;
@property (strong,nonatomic)AVCaptureMetadataOutput *output;
@property (strong,nonatomic)AVCaptureSession *session;
@property (strong,nonatomic)AVCaptureVideoPreviewLayer *preview;
@property (strong,nonatomic)UIImageView *line;
@property (strong,nonatomic)UIImageView *imageView;
@property (strong,nonatomic) UIImageView *bgroundimageview;
//@property (strong, nonatomic)MBProgressHUD *mbHUD;


@end


@implementation ScanViewController


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    self.mbHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    self.mbHUD.delegate = self;
//    self.mbHUD.mode =MBProgressHUDModeIndeterminate;
//    self.mbHUD.labelText = @"准备中...";
//    [MobClick beginLogPageView:NSStringFromClass([self class])];
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    if (_session && ![_session isRunning]) {
        [_session startRunning];
    }
    timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(animation1) userInfo:nil repeats:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setupCamera];
    [self addSubView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)addSubView {
    self.bgroundimageview = [[UIImageView alloc] initWithFrame:self.view.frame];
    self.bgroundimageview.image = [self backImage];
    self.bgroundimageview.userInteractionEnabled = YES;
    [self.view addSubview:self.bgroundimageview];

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(40/3.0, 114/3.0+15, 300, 20)];
    label.font = [UIFont systemFontOfSize:17];
    label.text = NSLocalizedString(@"scan_QR_Code", @"请扫描二维码");
    label.textColor = [UIColor whiteColor];
    [self.bgroundimageview addSubview:label];
    
    UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(MAXScreenW /2.0 - 230/2,460, 230, 30) ];
    label3.text = NSLocalizedString(@"the_QR_Code_in_box_to_scan_it_automatically", @"请将二维码置于框内，即可自动扫描");
    label3.font = [UIFont systemFontOfSize:14];
    label3.textColor = [UIColor whiteColor];
    [self.bgroundimageview addSubview:label3];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(MAXScreenW - 42/3.0-50, 30+15, 50, 30)];
    [btn setTitle:NSLocalizedString(@"Close", @"关闭") forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(closeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.bgroundimageview addSubview:btn];
    
    UIImage *image = [UIImage imageNamed:@"scan_picture"];
    UIButton *btnPicture = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnPicture setImage:image forState:UIControlStateNormal];
    btnPicture.frame = CGRectMake(0, 0, 60, 60);
    btnPicture.centerX = MAXScreenW/2.0;
    btnPicture.bmx_top = 550;
    [btnPicture addTarget:self action:@selector(onAlbum) forControlEvents:UIControlEventTouchUpInside];
    [self.bgroundimageview addSubview:btnPicture];
    
    UILabel *labelAlbum = [[UILabel alloc] initWithFrame:CGRectMake(0, 620, 300, 20)];
    labelAlbum.font = [UIFont systemFontOfSize:17];
    labelAlbum.text = NSLocalizedString(@"album", @"相册");
    labelAlbum.textColor = [UIColor whiteColor];
    [labelAlbum sizeToFit];
    labelAlbum.bmx_centerX = MAXScreenW /2.0;

    [self.bgroundimageview addSubview:labelAlbum];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *pickedImage = info[UIImagePickerControllerEditedImage] ?: info[UIImagePickerControllerOriginalImage];
    CIImage *detectImage = [CIImage imageWithData:UIImagePNGRepresentation(pickedImage)];
    
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy: CIDetectorAccuracyLow}];
    CIQRCodeFeature *feature = (CIQRCodeFeature *)[detector featuresInImage:detectImage options:nil].firstObject;
    
    [picker dismissViewControllerAnimated:YES completion:^{
        if (feature.messageString) {
            NSDictionary *configDic = [self dictionaryWithJsonString:feature.messageString];
            [self dealWithCodeJson:configDic];
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}


- (void)onAlbum {
    if (![LHTools photoLimit]) {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"allow_LHChatUI_to_access_your_photos", @"请在iPhone的设置-隐私-照片选项中,允许LHChatUI访问你的照片") delegate:nil cancelButtonTitle:NSLocalizedString(@"Confirm", @"确定") otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    [picker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [picker setModalPresentationStyle:UIModalPresentationFullScreen];
    [picker setAllowsEditing:YES];
    [picker setDelegate:self];
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)closeBtnClick {
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)dealWithCodeJson:(NSDictionary *)dic {
    NSString *source = dic[@"source"];
    if ([source isEqualToString:@"app"]) {
        [self p_dealWithAppQRcodeWithAction:dic[@"action"] infoDic:dic[@"info"] ];
    } else if ([source isEqualToString:@"web"]){
        [self p_dealWithWebQRcodeWithAction:dic[@"action"] infoDic:dic[@"info"] ];
    } else{
        [self p_dealWithConsoleQRcodeWithAction:dic[@"action"] infoDic:dic[@"info"]];
    }
}



- (void)p_dealWithAppQRcodeWithAction:(NSString *)action infoDic:(NSDictionary *)dic {
    if ([action isEqualToString:@"profile"] && [self isLogin]) {
        NSString *rosterID = dic[@"uid"];
        [self searchRosterById:[rosterID integerValue]];
        
    } else if ([action isEqualToString:@"group"] && [self isLogin]) {
        NSString *groupID = dic[@"group_id"];
        [self searcGroupById:[groupID integerValue] WithInfo:dic[@"info"]];
        
    } else {
        [HQCustomToast showDialog:NSLocalizedString(@"use_the_correct_device_to_scan", @"请使用正确设备扫描")];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)p_dealWithWebQRcodeWithAction:(NSString *)action infoDic:(NSDictionary *)dic {
    if (![self isLogin]) {
        [HQCustomToast showDialog:NSLocalizedString(@"login_pls", @"请登录")];
        [self.navigationController popToRootViewControllerAnimated:YES];
        return;
    }
    if ([action isEqualToString:@"login"] ) {
        NSString *qrcode = dic[@"qrcode"];
        NSString *appId = dic[@"app_id"];
        NSString *currentAppId = [AppIDManager sharedManager].appid.appId;
        if (![currentAppId isEqualToString:appId]){
            [self showPCLoginAlertWithQrCode:(NSString*)qrcode];
        }else {
            NSString *alert = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"change_app_id_to", @"请退出当前账号并切换到App ID到"), appId];
            [HQCustomToast showDialog:alert];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }

    } else {
        [HQCustomToast showDialog:NSLocalizedString(@"use_the_correct_device_to_scan", @"请使用正确设备扫描")];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)dealWithLogoutWithAction:(NSString *)actionString infoDic:(NSDictionary *)dic {
    [AppIDManager clearAppid];
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    NSString *appId = [NSString stringWithFormat:@"%@", dic[@"appId"]];
    [appDelegate reloadAppID:appId];
    [IMAcountInfoStorage clearObject];
    [appDelegate userLogout];

    [self closeBtnClick];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)),
                   dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ScanConsule" object:dic];
    });
}

- (void)logoutWithAction:(NSString *)actionString infoDic:(NSDictionary *)dic{
    [HQCustomToast showWating];
    IMAcount *account = [IMAcountInfoStorage loadObject];
    
    [[BMXClient sharedClient] signOutWithUid:(NSInteger)account.usedId ignoreUnbindDevice:NO completion:^(BMXError * _Nonnull error) {

        if (!error) {
            [HQCustomToast hideWating];
            
            [self dealWithLogoutWithAction:actionString infoDic:dic];
        } else {
            
            [[BMXClient sharedClient] signOutWithUid:(NSInteger)account.usedId ignoreUnbindDevice:YES completion:^(BMXError * _Nonnull error) {
                [self dealWithLogoutWithAction:actionString infoDic:dic];
            }];
            
            [HQCustomToast hideWating];
        }
    }];

}

- (void)p_dealWithConsoleQRcodeWithAction:(NSString *)action infoDic:(NSDictionary *)dic {
    if ([action isEqualToString:@"login"]) {
        NSString *appId = [NSString stringWithFormat:@"%@", dic[@"app_id"]];
        NSString *uid = [NSString stringWithFormat:@"%@",dic[@"uid"]];
        NSString *userName = [NSString stringWithFormat:@"%@", dic[@"username"]];
        NSString *password = [NSString stringWithFormat:@"%@", dic[@"password"]];
        NSDictionary *dic = @{@"appId": appId,
                              @"uid": uid,
                              @"userName": userName,
                              @"password": password};
        if (![self isLogin]){
            [self reloadAppID:appId];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ScanConsule" object:dic];
            [self closeBtnClick];
        }else{
            NSString *currentAppId = [AppIDManager sharedManager].appid.appId;
            if (![currentAppId isEqualToString:appId]){
                [self showAlertWithAction:action infoDic:dic];
            }else {
                [HQCustomToast showDialog:NSLocalizedString(@"logout_first", @"请先登出当前账号，再扫码登录")];
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        }
        
    } else if ([action isEqualToString:@"upload_device_token"] && [self isLogin]) {
        [self configUploadDeviceTokenWithInfo:dic];
        
    } else if ([action isEqualToString:@"app"]) {
        if (![self isLogin]){
            NSString *appId = [NSString stringWithFormat:@"%@", dic[@"app_id"]];
            NSDictionary *dic = @{@"appId": appId};
            [self reloadAppID:appId];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ScanConsule" object:dic];
            [self closeBtnClick];
            NSString *tip = [NSString stringWithFormat:@"%@%@",
                             NSLocalizedString(@"appid_changed", @"成功切换Appid为："), appId];
            [HQCustomToast showDialog:tip];
        }else{
            [HQCustomToast showDialog:NSLocalizedString(@"logout_first", @"请先登出当前账号，再扫码登录")];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    } else {
        [HQCustomToast showDialog:NSLocalizedString(@"QR_Code_is_not_recognized", @"未识别该二维码")];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

-(void)showAlertWithAction:(NSString *)actionString infoDic:(NSDictionary *)dic {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Whether_to_switch_AppID", @"是否切换AppID?") message:NSLocalizedString(@"quit_current_account_to_switch_AppID", @"切换AppID，需要退出当前账号") preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"取消") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", @"确定") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self logoutWithAction:actionString infoDic:dic];
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)showPCLoginAlertWithQrCode:(NSString*)qrcode{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"webim_login_ack_title", @"Web IM登录确认") message:NSLocalizedString(@"webim_login_ack_body", @"您正在请求在Web版蓝莺IM登录，请确认是您本人登录以免信息泄漏。") preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"取消") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", @"确定") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self allowPCLoginWithQrCode:qrcode];
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)allowPCLoginWithQrCode:(NSString*)qrcode {
    AllowLoginWithQRCodeApi *api = [[AllowLoginWithQRCodeApi alloc] initWithQrCode:qrcode];
    [api startWithSuccessBlock:^(ApiResult * _Nullable result) {
//        if ([result isOK]) {
            [self closeBtnClick];
//        }
    } failureBlock:^(NSError * _Nullable error) {
        [HQCustomToast showDialog:NSLocalizedString(@"Network_exception", @"网路异常")];
    }];
}

- (void)setupCamera {
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied){
        // @"请在iPhone的设置-隐私-相机选项中，允许微信访问你的相机"
        
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"allow_Maximtop_to_access_your_camera", @"请在iPhone的设置-隐私-相机选项中，允许蓝莺IM拓扑访问你的相机") preferredStyle:UIAlertControllerStyleAlert];
        [alertVC addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Good", @"好") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [self.navigationController presentViewController:alertVC animated:true completion:nil];
    }else{
    // Device
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Input
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    // Output
    self.output = [[AVCaptureMetadataOutput alloc]init];
    [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // Session
    self.session = [[AVCaptureSession alloc]init];
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([self.session canAddInput:self.input])
    {
        [self.session addInput:self.input];
    }
    if ([self.session canAddOutput:self.output])
    {
        [self.session addOutput:self.output];
    }
    
    // 条码类型
    self.output.metadataObjectTypes =@[AVMetadataObjectTypeQRCode];
    
    // Preview
    self.preview = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.preview.videoGravity =AVLayerVideoGravityResizeAspectFill;
    self.preview.frame = self.view.frame;
    [self.view.layer addSublayer:self.preview];

    
    UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake(self.view.bounds.size.width /2 - 279 / 2.0, 510/3, 280 , 280 )];
    imageView.image = [UIImage imageNamed:@"box"];
    [self.view addSubview:imageView];
  
    upOrdown = NO;
    num = 0;
    _line = [[UIImageView alloc] initWithFrame:imageView.frame];
    _line.image = [UIImage imageNamed:@"scan_line"];
    [self.view addSubview:self.line];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(animation1) userInfo:nil repeats:YES];
    // Start
    [self.session startRunning];

    }
}

- (UIImage *)backImage {
    UIGraphicsBeginImageContext(self.view.frame.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(ctx, 0,0,0,0.6);
    CGSize screenSize =[UIScreen mainScreen].bounds.size;
    CGRect drawRect =CGRectMake(0, 0, screenSize.width,screenSize.height);
    
    CGContextFillRect(ctx, drawRect);   //draw the transparent layer
    
    CGRect _cropRect = CGRectMake(self.view.bounds.size.width /2 - 279 / 2.0, 510/3, 280 , 280 );
    drawRect = CGRectMake(_cropRect.origin.x-self.view.frame.origin.x, _cropRect.origin.y-self.view.frame.origin.y, _cropRect.size.width,_cropRect.size.height);
    CGContextClearRect(ctx, drawRect);  //clear the center rect  of the layer
    
    
    UIImage* returnimage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return returnimage;
    
}

#pragma mark - LineAnimation
- (void)animation1 {
    if (upOrdown == NO) {
        num ++;
        _line.frame = CGRectMake(self.view.bounds.size.width /2 - 279/2-1, 2*num+155, 280  ,6);
        if (2 * num == 290) {
            upOrdown = YES;
        }
    }
    else {
        num ++;

        if (num == 170)
        {
            
            num = 0;
            upOrdown = NO;
        }
    }
}

- (void)searchRosterById:(NSInteger)rosterid {
    [HQCustomToast showWating];
    [[[BMXClient sharedClient] rosterService] searchWithRosterId:rosterid forceRefresh:YES completion:^(BMXRosterItem *rosterItem, BMXError *error) {
        [HQCustomToast hideWating];

        if (!error){
            SearchRosterProfileViewController *vc = [[SearchRosterProfileViewController alloc] initWithRoster:rosterItem];
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            [HQCustomToast showDialog: @"Unknow error."];
            [self.navigationController popViewControllerAnimated:YES];

        }
    }];
}



- (void)searcGroupById:(NSInteger)groupId WithInfo:(NSString *)info{
    [HQCustomToast showWating];
    [[[BMXClient sharedClient] groupService]  fetchGroupByIdWithGroupId:groupId forceRefresh:YES completion:^(BMXGroup *group, BMXError *error) {
        [HQCustomToast hideWating];
        if (error == nil) {
            GroupBasicInfoViewController *vc = [[GroupBasicInfoViewController alloc] initWithGroup:group info:info];
            [self.navigationController pushViewController:vc animated:YES];

        } else {
            [HQCustomToast showDialog:[error description]];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

- (void)jumpToQRCodeLoginVCWithInfo:(NSString *)info {
    [self.navigationController popViewControllerAnimated:YES];
    QRCodeLoginViewController *vc = [[QRCodeLoginViewController alloc] initWithInfo:info];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:vc animated:YES completion:^{
        
    }];
}

- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

#pragma mark AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {

    NSString *stringValue;
    MAXLog(@"%@", stringValue);
    
    if ([metadataObjects count] >0) {
        AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects objectAtIndex:0];
        stringValue = metadataObject.stringValue;
    }
//     if ([stringValue containsString:@"L_"] && [self isLogin]) {
//        NSArray *array = [stringValue componentsSeparatedByString:@"_"];
//        NSString *info = array[1];
//        [self jumpToQRCodeLoginVCWithInfo:info];
//     } else {
         NSDictionary *configDic = [self dictionaryWithJsonString:stringValue];
         [_session stopRunning];
         
         [self dealWithCodeJson:configDic];
//     }
}

- (BOOL)isLogin {
    if ([IMAcountInfoStorage isHaveLocalData]) {
        return YES;
    } else {
        return NO;
    }
}

- (void)reloadAppID:(NSString *)appid {
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate reloadAppID:appid];
}

- (void)configUploadDeviceTokenWithInfo:(NSDictionary *)info {
    if (info == nil) {
        return;
    }
    NSString *type = [NSString stringWithFormat:@"%@", info[@"platform_type"]];
    NSString *random = [NSString stringWithFormat:@"%@", info[@"info"]];
    
    if ([type isEqualToString:@"1"]) {
        NSString *deviceToken = [[NSUserDefaults standardUserDefaults] valueForKey:@"deviceToken"];
        NotifierUploadPushInfoApi *api = [[NotifierUploadPushInfoApi alloc] initWithDeviceToken:deviceToken uuid:random];
        [api startWithSuccessBlock:^(ApiResult * _Nullable result) {
            MAXLog(@"上传成功");
            [HQCustomToast showDialog:NSLocalizedString(@"Upload_successfully", @"上传成功")];
            [self.navigationController popToRootViewControllerAnimated:YES];

        } failureBlock:^(NSError * _Nullable error) {
            [HQCustomToast showDialog:NSLocalizedString(@"Upload_falied", @"上传失败")];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }];
        
    } else {
        [HQCustomToast showDialog:NSLocalizedString(@"use_the_correct_device_to_scan", @"请使用正确设备扫描")];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
