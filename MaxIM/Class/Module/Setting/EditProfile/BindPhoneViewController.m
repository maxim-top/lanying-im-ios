//
//  BindPhoneViewController.m
//  MaxIM
//
//  Created by 韩雨桐 on 2019/12/4.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "BindPhoneViewController.h"
#import "BindPhoneView.h"
#import "UIViewController+CustomNavigationBar.h"
#import "CaptchaApi.h"
#import "UserMobileBindApi.h"

@interface BindPhoneViewController ()<BindPhoneProtocol>


@property (nonatomic, strong) BindPhoneView *contentView;


@end

@implementation BindPhoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    // Do any additional setup after loading the view.
    [self setUpNavItem];
    [self addContentView];
}

- (void)addContentView {
    [self.view addSubview:self.contentView];
}

- (void)setUpNavItem {
    [self setNavigationBarTitle:@"绑定手机号" navLeftButtonIcon:@"blackback"];
}

- (void)sendChaptchaWithPhone:(NSString *)phone {
    CaptchaApi *api = [[CaptchaApi alloc] initWithMobile:phone];
    [api startWithSuccessBlock:^(ApiResult * _Nullable result) {
        if (result.isOK) {
        
        } else {
            [HQCustomToast showDialog:result.errmsg];
        }
        
    } failureBlock:^(NSError * _Nullable error) {
        [HQCustomToast showNetworkError];
    }];
 
    MAXLog(@"%@",phone);
}


- (void)commitPhone:(NSString *)phone chptcha:(NSString *)chptcha {
    
    UserMobileBindApi *api = [[UserMobileBindApi alloc] initWithMobile:phone captach:chptcha];
    [api startWithSuccessBlock:^(ApiResult * _Nullable result) {
        if (result.isOK) {
            [self.navigationController popViewControllerAnimated:YES];
            [HQCustomToast showDialog:@"绑定成功"];
        } else {
            [HQCustomToast showDialog:result.errmsg];
        }
        
    } failureBlock:^(NSError * _Nullable error) {
        [HQCustomToast showNetworkError];
    }];

    MAXLog(@"phone = %@ , chptcha = %@", phone, chptcha);
}

- (BindPhoneView *)contentView {
    
    if (!_contentView) {
        _contentView = [[BindPhoneView alloc] initWithFrame:CGRectMake(0, NavHeight, MAXScreenW, MAXScreenH - NavHeight)];
        _contentView.delegate = self;
    }
    return _contentView;
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
