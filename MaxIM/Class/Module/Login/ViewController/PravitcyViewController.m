//
//  PravitcyViewController.m
//  MaxIM
//
//  Created by 韩雨桐 on 2019/6/19.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "PravitcyViewController.h"
#import "UIViewController+CustomNavigationBar.h"
#import <WebKit/WebKit.h>
@interface PravitcyViewController ()

@property (nonatomic,copy) NSString *navtitle;
@property (nonatomic,copy) NSString *url;

@end

@implementation PravitcyViewController

- (instancetype)initWithTitle:(NSString *)title url:(NSString *)url {
    if (self = [super init]) {
        self.navtitle = title;
        self.url = url;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setNav];
    
    
    
    
    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, NavHeight, self.view.width, self.view.height - kNavBarHeight)];
    NSURL *url = [NSURL URLWithString:self.url];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [webView loadRequest:request];
    [self.view addSubview:webView];
}

- (void)setNav {
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self setNavigationBarTitle:self.navtitle navLeftButtonIcon:@"blackback"];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
