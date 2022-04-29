//
//  BindNewViewController.m
//  MaxIM
//
//  Created by 韩雨桐 on 2019/12/5.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "BindNewViewController.h"
#import "BindPhoneView.h"
#import "UIViewController+CustomNavigationBar.h"
#import "UserMobileChangeApi.h"
#import "CaptchaApi.h"

@interface BindNewViewController ()<BindPhoneProtocol>

@property (nonatomic, strong) BindPhoneView *contentView;


@end

@implementation BindNewViewController
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
    [self setNavigationBarTitle:NSLocalizedString(@"Bind_a_new_phone_number", @"绑定新手机号") navLeftButtonIcon:@"blackback"];
}

//- (void)sendChaptchaWithPhone:(NSString *)phone {
//    CaptchaApi *api = [[CaptchaApi alloc] initWithMobile:phone];
//    [api startWithSuccessBlock:^(ApiResult * _Nullable result) {
//        if (result.isOK) {
//            
//        } else {
//            [HQCustomToast showDialog:result.errmsg];
//        }
//        
//    } failureBlock:^(NSError * _Nullable error) {
//        [HQCustomToast showNetworkError];
//        
//    }];
//    
//    MAXLog(@"%@",phone);
//}

- (void)changehMobile:(NSString *)mobile  sign:(NSString *)sign captcha:(NSString *)captcha {

    UserMobileChangeApi * api = [[UserMobileChangeApi alloc] initWithMobile:mobile sign:sign captcha:captcha];
    [api startWithSuccessBlock:^(ApiResult * _Nullable result) {
        if (result.isOK) {
            [self.navigationController popToRootViewControllerAnimated:YES];
        } else {
            [HQCustomToast showDialog:result.errmsg];
        }

    } failureBlock:^(NSError * _Nullable error) {
        [HQCustomToast showNetworkError];

    }];
}


- (void)commitPhone:(NSString *)phone chptcha:(NSString *)chptcha {
    [self changehMobile:phone sign:self.sign captcha:chptcha];
    MAXLog(@"phone = %@ , chptcha = %@", phone, chptcha);
}

- (BindPhoneView *)contentView {
    
    if (!_contentView) {
        _contentView = [[BindPhoneView alloc] initWithFrame:CGRectMake(0, NavHeight, MAXScreenW, MAXScreenH - NavHeight) needTitle:YES titleText:NSLocalizedString(@"enter_a_new_phone_number", @"请输入新的手机号")];
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
