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

@end

@implementation LogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setUpNavItem];
    [self.view addSubview:self.logTextView];
    
//
    NSString * logPath =  [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:[NSString stringWithFormat:@"ChatData/%@/flooLog/floo.log", [BMXClient sharedClient].sdkConfig.appID]];
    self.logTextView.text = [NSString stringWithContentsOfFile:logPath encoding:NSUTF8StringEncoding error:nil] ;
    
}

- (void)setUpNavItem{
    [self setNavigationBarTitle:@"日志" navLeftButtonIcon:@"blackback"];
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
