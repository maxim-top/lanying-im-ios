//
//  LogViewController.m
//  MaxIM
//
//  Created by 韩雨桐 on 2020/3/28.
//  Copyright © 2020 hyt. All rights reserved.
//

#import "LogViewController.h"
#import "UIViewController+CustomNavigationBar.h"
#import <floo-ios/floo_proxy.h>
static const NSUInteger kLineNum = 200;

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
    self.logPath =  [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:[NSString stringWithFormat:@"ChatData/%@/flooLog/floo.log", [BMXClient sharedClient].getSDKConfig.getAppID]];
    NSString *content = [NSString stringWithContentsOfFile:self.logPath encoding:NSUTF8StringEncoding error:nil] ;
    NSArray* lines =
              [content componentsSeparatedByCharactersInSet:
              [NSCharacterSet newlineCharacterSet]];
    NSMutableString* lastLines = [NSMutableString string];
    for (NSUInteger i = lines.count - kLineNum; i < lines.count; i++)
    {
        [lastLines appendString: [lines objectAtIndex: i]];
        [lastLines appendString:@"\n"];
    }
    self.logTextView.text = lastLines;
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
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableArray *itemsArr = [[NSMutableArray alloc]init];
        for(id logger in [DDLog allLoggers]){
            if([logger isKindOfClass:[DDFileLogger class]]){
                DDFileLogger *fileLogger = (DDFileLogger*) logger;
                for(NSString *path in [[fileLogger logFileManager] sortedLogFilePaths]){
                    NSURL *logUrl = [NSURL fileURLWithPath:path];
                    [itemsArr addObject: logUrl];
                }
            }
        }
        self.logPath =  [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:[NSString stringWithFormat:@"ChatData/%@/flooLog/floo.log", [BMXClient sharedClient].getSDKConfig.getAppID]];
        NSURL *flooLogUrl = [NSURL fileURLWithPath:self.logPath];
        [itemsArr addObject: flooLogUrl];
        
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:itemsArr applicationActivities:nil];
        
        // 适配iPad
        UIPopoverPresentationController *popVC = activityViewController.popoverPresentationController;
        popVC.sourceView = self.view;
        [self presentViewController:activityViewController animated:YES completion:nil];
    });
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
