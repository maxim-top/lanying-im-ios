
//
//  AboutUsViewController.m
//  MaxIM
//
//  Created by 韩雨桐 on 2019/8/30.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "AboutUsViewController.h"
#import "BMXClient.h"
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
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.view.frame) - 50, 100, 100, 100)];
    imageView.image = [UIImage imageNamed:@"about_logo"];
    [self.view addSubview:imageView];
    
    
    
    UILabel *label1 = [[UILabel alloc] init];
    label1.textAlignment = NSTextAlignmentCenter;
    label1.font = [UIFont systemFontOfSize:14];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    label1.text = [NSString stringWithFormat:@"MaxIM Version: %@", app_Version];
    [self.view addSubview:label1];

    
    UILabel *label2 = [[UILabel alloc] init];
    BMXSDKConfig *config = [[BMXClient sharedClient] sdkConfig];
    NSString *SDK_Version = config.sdkVersion;

    label2.text = [NSString stringWithFormat:@"FlooSDK Version: %@", SDK_Version];
    label2.textAlignment = NSTextAlignmentCenter;
    label2.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:label2];
    
    
    UILabel *label3 = [[UILabel alloc] init];
    label3.text = @"一键启用多云架构的即时通讯云服务";
    label3.textAlignment = NSTextAlignmentCenter;
    label3.numberOfLines = 0;
    label3.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:label3];
    
    
    UILabel *label4 = [[UILabel alloc] init];
    label4.text = @"联系商务请访问官网https://www.maximtop.com";
    label4.textAlignment = NSTextAlignmentCenter;
    label4.numberOfLines = 0;
    label4.font = [UIFont systemFontOfSize:15];
    [self.view addSubview:label4];
    
    
    UILabel *label5 = [[UILabel alloc] init];
    label5.text = @"或致电400-666-0162";
    label5.textAlignment = NSTextAlignmentCenter;
    label5.numberOfLines = 0;
    label5.font = [UIFont systemFontOfSize:15];
    [self.view addSubview:label5];
    
    UILabel *bottom_label= [[UILabel alloc] init];
    bottom_label.text = @"copyright© 2019 美信拓扑";
    bottom_label.textAlignment = NSTextAlignmentCenter;
    bottom_label.numberOfLines = 0;
    bottom_label.font = [UIFont systemFontOfSize:15];
    [self.view addSubview:bottom_label];
    
    label1.bmx_size =  CGSizeMake(100, 20);
    label1.bmx_centerX =  self.view.bmx_centerX  - 15;
    label1.bmx_top = imageView.bmx_bottom + 30;

    label2.bmx_size =  CGSizeMake(100, 20);
    label2.bmx_centerX =  self.view.bmx_centerX - 15;
    label2.bmx_top = label1.bmx_bottom + 5;
    [label1 sizeToFit];
    [label2 sizeToFit];
    
    label3.bmx_top =  label2.bmx_bottom + 30;
    label3.bmx_width = MAXScreenW - 20 * 2;
    label3.bmx_height = 30;
    label3.bmx_centerX = self.view.bmx_centerX;
    
    label4.bmx_top =  label3.bmx_bottom + 30;
    label4.bmx_width = MAXScreenW - 20 * 2;
    label4.bmx_height = 20;
    label4.bmx_centerX = self.view.bmx_centerX;
    
    label5.bmx_top =  label4.bmx_bottom + 10;
    label5.bmx_width = MAXScreenW - 20 * 2;
    label5.bmx_height = 20;
    label5.bmx_centerX = self.view.bmx_centerX;
    
    bottom_label.bmx_top =  MAXScreenH - 30;
    bottom_label.bmx_width = MAXScreenW - 20 * 2;
    bottom_label.bmx_height = 10;
    bottom_label.bmx_centerX = self.view.bmx_centerX;

}

- (void)setUpNavItem{
    [self setNavigationBarTitle:@"关于我们" navLeftButtonIcon:@"blackback"];
}


@end
