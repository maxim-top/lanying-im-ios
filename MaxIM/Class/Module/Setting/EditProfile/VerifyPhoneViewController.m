//
//  VerifyPhoneViewController.m
//  MaxIM
//
//  Created by 韩雨桐 on 2019/12/5.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "VerifyPhoneViewController.h"
#import "BindPhoneView.h"
#import "UIViewController+CustomNavigationBar.h"
#import <floo-ios/BMXUserProfile.h>
#import "UserMobilePrechangeByMobileApi.h"
#import "CaptchaApi.h"
#import "UserMobileChangeApi.h"
#import <Photos/Photos.h>
#import "BindNewViewController.h"

@interface VerifyPhoneViewController ()<BindPhoneProtocol>

@property (nonatomic, strong) BindPhoneView *contentView;

@end

@implementation VerifyPhoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    // Do any additional setup after loading the view.
    [self setUpNavItem];
    [self addContentView];
    [self.contentView setPhoneNum:self.profile.mobilePhone];
}

- (void)addContentView {
    [self.view addSubview:self.contentView];
}

- (void)setUpNavItem {
    [self setNavigationBarTitle:@"更换手机号" navLeftButtonIcon:@"blackback"];
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
    
    
    UserMobilePrechangeByMobileApi *api = [[UserMobilePrechangeByMobileApi alloc] initWithCaptcha:chptcha mobile:phone];
    [api startWithSuccessBlock:^(ApiResult * _Nullable result) {
        if (result.isOK) {
            
            BindNewViewController *vc = [[BindNewViewController alloc] init];
            vc.sign = result.resultData[@"sign"];
            [self.navigationController pushViewController:vc animated:YES];
            
//            [self changehMobile:phone sign:result.resultData[@"sign"] captcha:chptcha];
            
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
        _contentView = [[BindPhoneView alloc] initWithFrame:CGRectMake(0, NavHeight, MAXScreenW, MAXScreenH - NavHeight) needTitle:YES titleText:@"已绑定手机号验证身份"];
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
