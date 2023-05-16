
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

@interface AboutUsViewController ()

@end

@implementation AboutUsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor= [UIColor whiteColor];
    [self setUpNavItem];
    [self p_configSubview];
}

- (void)p_configSubview {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"about" ofType:@"png"];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(MAXScreenW / 2.0 - 200.0 / 2.0, 150, 200.0, 100.0)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.image = image;
    [self.view addSubview:imageView];
    
    
    
    UILabel *label1 = [[UILabel alloc] init];
    label1.textAlignment = NSTextAlignmentCenter;
    label1.font = [UIFont systemFontOfSize:14];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    label1.text = [NSString stringWithFormat:NSLocalizedString(@"Maximtop_IM__v", @"蓝莺IM v%@"), app_Version];
    [self.view addSubview:label1];

    
    UILabel *label2 = [[UILabel alloc] init];
    BMXSDKConfig *config = [[BMXClient sharedClient] getSDKConfig];
    NSString *SDK_Version = config.getSDKVersion;

    label2.text = [NSString stringWithFormat:@"Floo/SDK  v%@", SDK_Version];
    label2.textAlignment = NSTextAlignmentCenter;
    label2.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:label2];
    
    
    UILabel *label3 = [[UILabel alloc] init];
    label3.text = NSLocalizedString(@"One-Click_Multi-Cloud_Architecture", @"构建新一代智能聊天APP\n用蓝莺IM专业SDK！");
    label3.textAlignment = NSTextAlignmentCenter;
    label3.numberOfLines = 2;
    label3.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:label3];
    
    UILabel *label5 = [[UILabel alloc] init];
    label5.text = NSLocalizedString(@"Official_Website", @"官网 https://www.lanyingim.com");
    label5.textAlignment = NSTextAlignmentCenter;
    label5.numberOfLines = 0;
    label5.font = [UIFont systemFontOfSize:15];
    [self.view addSubview:label5];
    
    label5.userInteractionEnabled = YES;
    UITapGestureRecognizer *urlTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openUrl)];
    [label5 addGestureRecognizer:urlTap];

    UILabel *label7 = [[UILabel alloc] init];
    label7.text = NSLocalizedString(@"Contact_business", @"联系商务 400-666-0162");
    label7.textAlignment = NSTextAlignmentCenter;
    label7.numberOfLines = 0;
    label7.font = [UIFont systemFontOfSize:15];
    [self.view addSubview:label7];
    
    label7.userInteractionEnabled = YES;
    UITapGestureRecognizer *phoneTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(callAction)];
    [label7 addGestureRecognizer:phoneTap];
    
    UILabel *bottom_label= [[UILabel alloc] init];
    bottom_label.text = NSLocalizedString(@"copyright_Maximtop", @"© 2019-2022 美信拓扑");
    bottom_label.textAlignment = NSTextAlignmentCenter;
    bottom_label.numberOfLines = 0;
    bottom_label.font = [UIFont systemFontOfSize:15];
    [self.view addSubview:bottom_label];
    
   
    
    label3.bmx_top =  imageView.bmx_bottom + 30;
    label3.bmx_width = MAXScreenW - 20 * 2;
    label3.bmx_height = 60;
    label3.bmx_centerX = self.view.bmx_centerX;

    label5.bmx_top =  label3.bmx_bottom + 40;
    label5.bmx_width =  MAXScreenW - 20;
    label5.bmx_height = 20 ;
    label5.bmx_centerX = self.view.bmx_centerX;
    
    label7.bmx_width = MAXScreenW - 20;
    label7.bmx_top =  label5.bmx_bottom + 10;
    label7.bmx_height = 20;
    label7.bmx_centerX = self.view.bmx_centerX;
    
    
    
    label1.bmx_size =  CGSizeMake(100, 20);
    label1.bmx_centerX =  self.view.bmx_centerX;
    label1.bmx_top = label7.bmx_bottom + 40;
    
    label2.bmx_size =  CGSizeMake(100, 20);
    label2.bmx_centerX =  self.view.bmx_centerX;
    label2.bmx_top = label1.bmx_bottom + 5;
    [label1 sizeToFit];
    [label2 sizeToFit];

    bottom_label.bmx_top =  MAXScreenH - 30;
    bottom_label.bmx_width = MAXScreenW - 20 * 2;
    bottom_label.bmx_height = 20;
    bottom_label.bmx_centerX = self.view.bmx_centerX;
    
    

}

- (void)setUpNavItem{
    [self setNavigationBarTitle:NSLocalizedString(@"About_Us", @"关于我们") navLeftButtonIcon:@"blackback"];
}

- (void)openUrl {
    
     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.lanyingim.com"]];
}

- (void)callAction {
    
      [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@",@"400-666-0162"]]];
}

@end
