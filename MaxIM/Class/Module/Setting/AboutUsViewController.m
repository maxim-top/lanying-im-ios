
//
//  AboutUsViewController.m
//  MaxIM
//
//  Created by 韩雨桐 on 2019/8/30.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "AboutUsViewController.h"
#import <floo-ios/floo_proxy.h>
#import "UIView+BMXframe.h"
#import "UIViewController+CustomNavigationBar.h"
#import "MAXUtils.h"
#import "OnceHappenStorage.h"
#import "AppIDManager.h"

static NSDictionary *dictAppStatus = nil;

@interface AboutUsViewController ()
@property(nonatomic, strong, nullable) dispatch_source_t refreshCompanyNameTimer;//延时获取公司名
@property (nonatomic, strong) UILabel *labelCompanyName;
@property (nonatomic, strong) UILabel *labelVerifyStatus;
@property (nonatomic, strong) UILabel *labelAppStatus;
@property (nonatomic, strong) UIView *appStatusContainer;
@property (nonatomic, strong) UIButton *infoBtn;

@end

@implementation AboutUsViewController

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dictAppStatus = @{
            @"normal": @"app_status_normal",
            @"frozen": @"app_status_frozen",
            @"banned": @"app_status_banned",
            @"revoked": @"app_status_revoked",
        };
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor= [UIColor whiteColor];
    [self setUpNavItem];
    [self p_configSubview];
}

-(void)dealloc{
    if (self.refreshCompanyNameTimer) {
        dispatch_source_cancel(self.refreshCompanyNameTimer);
        self.refreshCompanyNameTimer = nil;
    }
}

-(NSString *)getAppStatus{
    NSString *appStatus = [[BMXClient sharedClient] getAppStatus];
    NSString *appStatusText = [NSString stringWithFormat:NSLocalizedString(@"app_status", @"服务状态：%@"), NSLocalizedString(dictAppStatus[appStatus], @"")];
    return appStatusText;
}

- (void)viewDidAppear:(BOOL)animated{
    [self setCompanyName];
}

- (void)setCompanyName{
    NSString *companyName = [MAXUtils getCompanyName];
    NSString *text = companyName;
    if (companyName == nil || companyName.length == 0) {
        text = [MAXUtils getCompanyNameFromLocal];
        if (text == nil || text.length == 0) {
            text = [NSString stringWithFormat:@"%@",NSLocalizedString(@"about_us_unverified_developer", @"未认证开发者")];
        }
    }
    NSString *vst = [MAXUtils getVerificationStatusText];
    if (vst == nil || vst.length == 0) {
        vst = [MAXUtils getVerificationStatusTextFromLocal];
        if (vst == nil || vst.length == 0) {
            vst = [NSString stringWithFormat:@"%@",NSLocalizedString(@"about_us_unverified", @"❓未认证")];
        }
    }

    self.labelCompanyName.text = text;
    self.labelVerifyStatus.text = vst;
        
    self.labelCompanyName.bmx_width = MAXScreenW - 20;
    [self.labelCompanyName sizeToFit];
    self.labelCompanyName.bmx_centerX = self.view.bmx_centerX;

    self.labelVerifyStatus.bmx_width = MAXScreenW - 20;
    self.labelVerifyStatus.bmx_top =  self.labelCompanyName.bmx_bottom + 15;
    [self.labelVerifyStatus sizeToFit];
    self.labelVerifyStatus.bmx_centerX = self.view.bmx_centerX;

    if (companyName.length > 0) {
        return;
    }
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    if (self.refreshCompanyNameTimer) {
        dispatch_cancel(self.refreshCompanyNameTimer);
        self.refreshCompanyNameTimer = nil;
    }
    self.refreshCompanyNameTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, 0 * NSEC_PER_SEC);
    uint64_t interval = 1 * NSEC_PER_SEC;
    dispatch_source_set_timer(self.refreshCompanyNameTimer, start, interval, 0);
    __weak typeof(self) weakSelf = self;
    dispatch_source_set_event_handler(self.refreshCompanyNameTimer, ^{
        typeof(self) strongSelf = weakSelf;
        
        NSString *name = [MAXUtils getCompanyName];
        if (name == nil || name.length == 0) {
            return;
        }
        NSString *vst = [MAXUtils getVerificationStatusText];
        if (vst == nil || vst.length == 0) {
            return;
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            strongSelf.labelCompanyName.text = name;
            strongSelf.labelVerifyStatus.text = vst;
            
            strongSelf.labelCompanyName.bmx_width = MAXScreenW - 20;
            [strongSelf.labelCompanyName sizeToFit];
            strongSelf.labelCompanyName.bmx_centerX = self.view.bmx_centerX;

            strongSelf.labelVerifyStatus.bmx_width = MAXScreenW - 20;
            strongSelf.labelVerifyStatus.bmx_top =  self.labelCompanyName.bmx_bottom + 15;
            [strongSelf.labelVerifyStatus sizeToFit];
            strongSelf.labelVerifyStatus.bmx_centerX = self.view.bmx_centerX;
        });
        dispatch_source_cancel(strongSelf.refreshCompanyNameTimer);
    });
    dispatch_resume(self.refreshCompanyNameTimer);
}

- (void)p_configSubview {
    NSString *appId = [[BMXClient sharedClient] getSDKConfig].getAppID;

    UILabel *labelThisApp = [[UILabel alloc] init];
    labelThisApp.text = [NSString stringWithFormat:NSLocalizedString(@"about_us_this_app", @"本APP（APPID:%@）服务提供方"),appId];
    labelThisApp.textAlignment = NSTextAlignmentCenter;
    labelThisApp.numberOfLines = 0;
    labelThisApp.font = [UIFont systemFontOfSize:15];
    labelThisApp.textColor = [UIColor lh_colorWithHex:0x666666];
    [self.view addSubview:labelThisApp];

    self.labelCompanyName = [[UILabel alloc] init];
    NSString *companyName = [MAXUtils getCompanyName];
    if (companyName == nil || companyName.length == 0) {
        companyName = [NSString stringWithFormat:@"%@",NSLocalizedString(@"about_us_unverified_developer", @"未认证开发者")];
    }
    self.labelCompanyName.text = companyName;
    self.labelCompanyName.textAlignment = NSTextAlignmentCenter;
    self.labelCompanyName.numberOfLines = 2;
    self.labelCompanyName.font = [UIFont systemFontOfSize:32];
    self.labelCompanyName.textColor = [UIColor lh_colorWithHex:0x0000FF];
    [self.view addSubview:self.labelCompanyName];

    self.labelVerifyStatus = [[UILabel alloc] init];
    NSString *verifyStatus = [MAXUtils getVerificationStatusText];
    if (verifyStatus == nil || verifyStatus.length == 0) {
        verifyStatus = [NSString stringWithFormat:@"%@",NSLocalizedString(@"about_us_unverified", @"❓未认证")];
    }
    self.labelVerifyStatus.text = verifyStatus;
    self.labelVerifyStatus.textAlignment = NSTextAlignmentCenter;
    self.labelVerifyStatus.numberOfLines = 0;
    self.labelVerifyStatus.font = [UIFont systemFontOfSize:15];
    self.labelVerifyStatus.textColor = [UIColor lh_colorWithHex:0x0000FF];
    [self.view addSubview:self.labelVerifyStatus];

    BMXSDKConfig *config = [[BMXClient sharedClient] getSDKConfig];
    NSString *SDK_Version = config.getSDKVersion;
    
    UILabel *labelICP = [[UILabel alloc] init];
    labelICP.text = NSLocalizedString(@"icp_no", @"京ICP备19033149号-11A");
    labelICP.textAlignment = NSTextAlignmentCenter;
    labelICP.numberOfLines = 0;
    labelICP.font = [UIFont systemFontOfSize:15];
    labelICP.textColor = [UIColor lh_colorWithHex:0x666666];
    [self.view addSubview:labelICP];

    UILabel *labelCopyright= [[UILabel alloc] init];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy"];
    NSString *year = [formatter stringFromDate:[NSDate date]];

    labelCopyright.text = [NSString stringWithFormat:NSLocalizedString(@"copyright_Maximtop", @"© 2019-%@ 美信拓扑"), year];
    labelCopyright.textAlignment = NSTextAlignmentCenter;
    labelCopyright.numberOfLines = 0;
    labelCopyright.font = [UIFont systemFontOfSize:15];
    labelCopyright.textColor = [UIColor lh_colorWithHex:0x666666];
    [self.view addSubview:labelCopyright];
    
    UILabel *labelVersion = [[UILabel alloc] init];
    labelVersion.textAlignment = NSTextAlignmentCenter;
    labelVersion.font = [UIFont systemFontOfSize:15];
    labelVersion.textColor = [UIColor lh_colorWithHex:0x666666];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *build_Version = [infoDictionary objectForKey:@"CFBundleVersion"];
    labelVersion.text = [NSString stringWithFormat:NSLocalizedString(@"Maximtop_IM__v", @"蓝莺IM %@.%@ SDK %@"), app_Version, build_Version, SDK_Version];
    [self.view addSubview:labelVersion];
    
    UILabel *labelWebsite = [[UILabel alloc] init];
    labelWebsite.text = NSLocalizedString(@"Official_Website", @"www.lanyingim.com");
    labelWebsite.textAlignment = NSTextAlignmentCenter;
    labelWebsite.numberOfLines = 0;
    labelWebsite.font = [UIFont systemFontOfSize:15];
    labelWebsite.textColor = [UIColor lh_colorWithHex:0x666666];
    [self.view addSubview:labelWebsite];
    
    labelWebsite.userInteractionEnabled = YES;
    UITapGestureRecognizer *urlTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openUrl)];
    [labelWebsite addGestureRecognizer:urlTap];
    
    UILabel *labelSlogan = [[UILabel alloc] init];
    labelSlogan.text = NSLocalizedString(@"One-Click_Multi-Cloud_Architecture", @"使用蓝莺IM专业技术");
    labelSlogan.textAlignment = NSTextAlignmentCenter;
    labelSlogan.numberOfLines = 0;
    labelSlogan.font = [UIFont systemFontOfSize:15];
    labelSlogan.textColor = [UIColor lh_colorWithHex:0x666666];
    [self.view addSubview:labelSlogan];

    labelThisApp.bmx_width = MAXScreenW - 20;
    CGFloat screenHeight = MAXScreenH;
    labelThisApp.bmx_top =  MAXScreenH > 700 ? 300 : 90;
    labelThisApp.bmx_height = 20;
    labelThisApp.bmx_centerX = self.view.bmx_centerX;

    self.labelCompanyName.bmx_width = MAXScreenW - 20;
    self.labelCompanyName.bmx_top =  labelThisApp.bmx_bottom + 30;
    self.labelCompanyName.bmx_height = 20;
    [self.labelCompanyName sizeToFit];
    self.labelCompanyName.bmx_centerX = self.view.bmx_centerX;

    self.labelVerifyStatus.bmx_width = MAXScreenW - 20;
    self.labelVerifyStatus.bmx_top =  self.labelCompanyName.bmx_bottom + 15;
    self.labelVerifyStatus.bmx_height = 20;
    [self.labelVerifyStatus sizeToFit];
    self.labelVerifyStatus.bmx_centerX = self.view.bmx_centerX;
    
    self.appStatusContainer = [[UIView alloc] init];
    self.appStatusContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.appStatusContainer];

    self.labelAppStatus = [[UILabel alloc] init];
    self.labelAppStatus.translatesAutoresizingMaskIntoConstraints = NO;
    self.labelAppStatus.text = [self getAppStatus];

    [self.appStatusContainer addSubview:self.labelAppStatus];

    self.infoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.infoBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self.infoBtn setImage:[UIImage imageNamed:@"info"] forState:UIControlStateNormal];
    [self.infoBtn addTarget:self action:@selector(btnAppStatusClick) forControlEvents:UIControlEventTouchUpInside];
    [self.appStatusContainer addSubview:self.infoBtn];

    [NSLayoutConstraint activateConstraints:@[
        [self.appStatusContainer.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.appStatusContainer.topAnchor constraintEqualToAnchor:self.labelVerifyStatus.bottomAnchor constant:30.0],
        [self.appStatusContainer.heightAnchor constraintEqualToConstant:20.0],
    ]];

    CGFloat spacing = 2.0f;
    [NSLayoutConstraint activateConstraints:@[
        [self.labelAppStatus.leadingAnchor constraintEqualToAnchor:self.appStatusContainer.leadingAnchor],
        [self.labelAppStatus.centerYAnchor constraintEqualToAnchor:self.appStatusContainer.centerYAnchor],
        [self.labelAppStatus.trailingAnchor constraintEqualToAnchor:self.infoBtn.leadingAnchor constant:-spacing],
        [self.labelAppStatus.heightAnchor constraintEqualToAnchor:self.appStatusContainer.heightAnchor],

        [self.infoBtn.trailingAnchor constraintEqualToAnchor:self.appStatusContainer.trailingAnchor],
        [self.infoBtn.centerYAnchor constraintEqualToAnchor:self.appStatusContainer.centerYAnchor],
        [self.infoBtn.widthAnchor constraintEqualToAnchor:self.labelAppStatus.heightAnchor],
        [self.infoBtn.heightAnchor constraintEqualToAnchor:self.labelAppStatus.heightAnchor]
    ]];

    labelICP.bmx_width = MAXScreenW - 20;
    labelICP.bmx_top =  MAXScreenH - 30;
    labelICP.bmx_height = 20;
    labelICP.bmx_centerX = self.view.bmx_centerX;

    labelCopyright.bmx_top =  labelICP.bmx_top - labelICP.height;
    labelCopyright.bmx_width = MAXScreenW - 20 * 2;
    labelCopyright.bmx_height = 20;
    labelCopyright.bmx_centerX = self.view.bmx_centerX;
    
    labelVersion.bmx_size =  CGSizeMake(100, 20);
    labelVersion.bmx_top = labelCopyright.bmx_top - labelCopyright.height;
    [labelVersion sizeToFit];
    labelVersion.bmx_centerX =  self.view.bmx_centerX;

    labelWebsite.bmx_top =  labelVersion.bmx_top - labelVersion.height - 5;
    labelWebsite.bmx_width =  MAXScreenW - 20;
    labelWebsite.bmx_height = 20 ;
    labelWebsite.bmx_centerX = self.view.bmx_centerX;
    
    labelSlogan.bmx_top =  labelWebsite.bmx_top - labelWebsite.height;
    labelSlogan.bmx_width = MAXScreenW - 20 * 2;
    labelSlogan.bmx_height = 20;
    labelSlogan.bmx_centerX = self.view.bmx_centerX;
    
    if (![OnceHappenStorage has:appId byType:@"ABOUT_PAGE_CONFIRM"]) {
        [OnceHappenStorage add:appId byType:@"ABOUT_PAGE_CONFIRM"];
        
        UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [confirmButton setTitle:NSLocalizedString(@"Confirm", @"确定") forState:UIControlStateNormal];
        confirmButton.backgroundColor = BMXCOLOR_HEX(0x0079F4);
        [confirmButton setTitleColor:[BMXCOLOR_HEX(0x333333) colorWithAlphaComponent:0.4] forState:UIControlStateDisabled];
        [confirmButton setTitleColor:BMXCOLOR_HEX(0xffffff) forState:UIControlStateNormal];
        [confirmButton addTarget:self action:@selector(confirmButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        confirmButton.layer.masksToBounds = YES;
        confirmButton.layer.cornerRadius = 12;

        [self.view addSubview:confirmButton];
        
        confirmButton.bmx_top = self.labelVerifyStatus.bmx_bottom + 110;
        confirmButton.bmx_left = 50;
        confirmButton.bmx_width = MAXScreenW - 100;
        confirmButton.bmx_height = 55;
    }
}

- (void)btnAppStatusClick {
    NSString *appStatus = [[BMXClient sharedClient] getAppStatus];
    if ([appStatus isEqualToString:@"normal"]) {
        NSString *ratelIpList = [[BMXClient sharedClient] getRatelIpList];
        UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
        pasteBoard.string = ratelIpList;

        [HQCustomToast showDialog:[NSString stringWithFormat:NSLocalizedString(@"ratel_ip_copied", @"服务器IP:%@，已复制到剪贴板"),ratelIpList] time:3];
    }
}

- (void)confirmButtonClicked {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setUpNavItem{
    [self setNavigationBarTitle:NSLocalizedString(@"About_Us", @"关于") navLeftButtonIcon:@"blackback"];
}

- (void)openUrl {
    
     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.lanyingim.com"]];
}

@end
