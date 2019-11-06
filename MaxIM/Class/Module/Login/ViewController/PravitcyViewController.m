//
//  PravitcyViewController.m
//  MaxIM
//
//  Created by 韩雨桐 on 2019/6/19.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "PravitcyViewController.h"

@interface PravitcyViewController ()

@end

@implementation PravitcyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *returnButton = [UIButton buttonWithType:UIButtonTypeCustom];
    returnButton.frame = CGRectMake(10, 15, 50, 50);
    [returnButton setImage:[UIImage imageNamed:@"blackback"] forState:UIControlStateNormal];
    [returnButton addTarget:self action:@selector(returnVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:returnButton];
    
    UIWebView *webview = [[UIWebView alloc] initWithFrame:CGRectMake(0, kNavBarHeight, self.view.width, self.view.height - kNavBarHeight)];
    [webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.maximtop.com/privacy"]]];
    [self.view addSubview:webview];
    
    
    // Do any additional setup after loading the view.
}

- (void)returnVC {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    
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
