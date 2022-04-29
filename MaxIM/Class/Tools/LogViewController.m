//
//  LogViewController.m
//  MaxIM
//
//  Created by 韩雨桐 on 2020/3/28.
//  Copyright © 2020 hyt. All rights reserved.
//

#import "LogViewController.h"
#import "UIViewController+CustomNavigationBar.h"
#import <floo-ios/BMXClient.h>

@interface LogViewController ()

@property (nonatomic, strong) UITextView *logTextView;
@property (nonatomic, strong) NSString * logPath;

@end

@implementation LogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setUpNavItem];
    [self.view addSubview:self.logTextView];
    
//
    self.logPath =  [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:[NSString stringWithFormat:@"ChatData/%@/flooLog/floo.log", [BMXClient sharedClient].sdkConfig.appID]];
    self.logTextView.text = [NSString stringWithContentsOfFile:self.logPath encoding:NSUTF8StringEncoding error:nil] ;
//    [self.logTextView selectAll:nil];
}

- (void)setUpNavItem{
    [self setNavigationBarTitle:NSLocalizedString(@"Log", @"日志") navLeftButtonIcon:@"blackback"];
    
    UIImage *moreImage = [UIImage imageNamed:@"file"];
    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.navigationBar addSubview:moreButton];
    [moreButton setImage:moreImage forState:UIControlStateNormal];
    moreButton.frame = CGRectMake(MAXScreenW - 10 - 30 - 5, NavHeight - 5 -30, 30, 30);
    [moreButton addTarget:self action:@selector(clickMoreButton:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)clickMoreButton:(UIButton *)button {
    UIPasteboard* pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:[NSString stringWithContentsOfFile:self.logPath encoding:NSUTF8StringEncoding error:nil]];
    [HQCustomToast showDialog:NSLocalizedString(@"All_logs_have_been_copied_to_clipboard", @"日志已全部复制到剪贴板")];
}


- (UITextView *)logTextView {
    if (!_logTextView) {
        CGRect frame = CGRectMake(0, NavHeight, MAXScreenW, MAXScreenH - NavHeight);
        _logTextView = [[UITextView alloc] initWithFrame:frame];
        _logTextView.editable = NO;
        _logTextView.font = [UIFont systemFontOfSize:T5_30PX];
    }
    return _logTextView;
}

@end
