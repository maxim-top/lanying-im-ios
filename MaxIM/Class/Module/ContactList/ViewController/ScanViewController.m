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
#import <floo-ios/BMXClient.h>
#import "QRCodeLoginViewController.h"
#import "NotifierUploadPushInfoApi.h"
#import "ConsuleAppInfoStorage.h"
#import "ConsuleAppInfo.h"
#import "AppDelegate.h"
#import "ConsoleAppIDStorage.h"
#import "ConsoleAppID.h"
#import "IMAcountInfoStorage.h"
#import "UIViewController+CustomNavigationBar.h"

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHigh [UIScreen mainScreen].bounds.size.height - 64

@interface ScanViewController ()<AVCaptureMetadataOutputObjectsDelegate>
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

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(40/3.0, 114/3.0, 300, 20)];
    label.font = [UIFont systemFontOfSize:17];
    label.text = @"请扫描二维码";
    label.textColor = [UIColor whiteColor];
    [self.bgroundimageview addSubview:label];
    
    UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(MAXScreenW /2.0 - 230/2,460, 230, 30) ];
    label3.text = @"请将二维码置于框内，即可自动扫描";
    label3.font = [UIFont systemFontOfSize:14];
    label3.textColor = [UIColor whiteColor];
    [self.bgroundimageview addSubview:label3];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(MAXScreenW - 42/3.0-50, 30, 50, 30)];
    [btn setTitle:@"关闭" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(closwBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.bgroundimageview addSubview:btn];
}

- (void)closwBtnClick {
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
    } else {
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
        [HQCustomToast showDialog:@"请使用正确设备扫描"];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)p_dealWithConsoleQRcodeWithAction:(NSString *)action infoDic:(NSDictionary *)dic {
    if ([action isEqualToString:@"login"]) {
        NSString *appId = [NSString stringWithFormat:@"%@", dic[@"app_id"]];
        NSString *uid = [NSString stringWithFormat:@"%@",dic[@"uid"]];
        NSString *userName = [NSString stringWithFormat:@"%@", dic[@"username"]];
        NSDictionary *dic = @{@"appId": appId,
                              @"uid": uid,
                              @"userName": userName};
        [self reloadAppID:appId];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ScanConsule" object:dic];
        [self closwBtnClick];
        
    } else if ([action isEqualToString:@"upload_device_token"] && [self isLogin]) {
        [self configUploadDeviceTokenWithInfo:dic];
        
    } else if ([action isEqualToString:@"app"]) {
        NSString *appId = [NSString stringWithFormat:@"%@", dic[@"app_id"]];
        NSDictionary *dic = @{@"appId": appId};
        [self reloadAppID:appId];
        ConsoleAppID *appidModel = [[ConsoleAppID alloc] init];
        appidModel.appId = appId;
        [ConsoleAppIDStorage saveObject:appidModel];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ScanConsule" object:dic];
        [self closwBtnClick];
        
    } else {
        [HQCustomToast showDialog:@"请使用正确设备扫描"];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)setupCamera {
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied){
        // @"请在iPhone的“设置-隐私-相机”选项中，允许微信访问你的相机"
        
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:@"请在iPhone的“设置-隐私-相机”选项中，允许美信拓扑访问你的相机" preferredStyle:UIAlertControllerStyleAlert];
        [alertVC addAction:[UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
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
    _line.image = [UIImage imageNamed:@"scan"];
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
        _line.frame = CGRectMake(self.view.bounds.size.width /2 - 279/2-1, 2*num+50, 280  ,110);
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
    [[[BMXClient sharedClient] rosterService] searchByRosterId:rosterid forceRefresh:YES completion:^(BMXRoster *roster, BMXError *error) {
        [HQCustomToast hideWating];
        if (error == nil) {
            SearchRosterProfileViewController *vc = [[SearchRosterProfileViewController alloc] initWithRoster:roster];
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            [HQCustomToast showDialog:error.errorMessage];
            [self.navigationController popViewControllerAnimated:YES];

        }
    }];
}



- (void)searcGroupById:(NSInteger)groupId WithInfo:(NSString *)info{
    [HQCustomToast showWating];
    [[[BMXClient sharedClient] groupService]  getGroupInfoByGroupId:groupId forceRefresh:YES completion:^(BMXGroup *group, BMXError *error) {
        [HQCustomToast hideWating];
        if (error == nil) {
            GroupBasicInfoViewController *vc = [[GroupBasicInfoViewController alloc] initWithGroup:group info:info];
            [self.navigationController pushViewController:vc animated:YES];
           
        } else {
            [HQCustomToast showDialog:error.errorMessage];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

- (void)jumpToQRCodeLoginVCWithInfo:(NSString *)info {
    [self.navigationController popViewControllerAnimated:YES];
    QRCodeLoginViewController *vc = [[QRCodeLoginViewController alloc] initWithInfo:info];
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
            [HQCustomToast showDialog:@"上传成功"];
            [self.navigationController popToRootViewControllerAnimated:YES];

        } failureBlock:^(NSError * _Nullable error) {
            [HQCustomToast showDialog:@"上传失败"];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }];
        
    } else {
        [HQCustomToast showDialog:@"请使用正确设备扫描"];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
