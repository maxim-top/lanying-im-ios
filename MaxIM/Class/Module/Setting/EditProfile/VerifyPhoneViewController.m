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
#import "ChangePasswordViewController.h"
#import "PwdChangeVerifyByMobileApi.h"

@interface VerifyPhoneViewController ()<BindPhoneProtocol>

@property (nonatomic, strong) BindPhoneView *contentView;

@property (nonatomic,assign) EditType editType;


@end

@implementation VerifyPhoneViewController

- (instancetype)initWithEditType:(EditType)type {
    
    if (self = [super init]) {
        self.editType = type;
    }
    return self;

}

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
    
    [self setNavigationBarTitle:NSLocalizedString(@"Verify_with_phone_number", @"验证手机号") navLeftButtonIcon:@"blackback"];
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
    if (self.editType == EditTypePhone) {
        [self sendChangeMobileRequsetPhone:phone chptcha:chptcha];
    } else {
        [self sendchangePasswordRequsetPhone:phone chptcha:chptcha];
    }
    
    MAXLog(@"phone = %@ , chptcha = %@", phone, chptcha);
}

- (void)sendchangePasswordRequsetPhone:(NSString *)phone chptcha:(NSString *)chptcha {
    PwdChangeVerifyByMobileApi *api = [[PwdChangeVerifyByMobileApi alloc] initWithCaptcha:chptcha mobile:phone];
    [api startWithSuccessBlock:^(ApiResult * _Nullable result) {
        if (result.isOK) {
            [self changePassWordWith:result];
        } else {
            [HQCustomToast showDialog:result.errmsg];
        }
        
    } failureBlock:^(NSError * _Nullable error) {
        [HQCustomToast showNetworkError];

    }];
}

- (void)sendChangeMobileRequsetPhone:(NSString *)phone chptcha:(NSString *)chptcha {
    
    UserMobilePrechangeByMobileApi *api = [[UserMobilePrechangeByMobileApi alloc] initWithCaptcha:chptcha mobile:phone];
    [api startWithSuccessBlock:^(ApiResult * _Nullable result) {
        if (result.isOK) {
            
            [self bindNewPhoneWith:result];
           
        } else {
            [HQCustomToast showDialog:result.errmsg];
        }
        
    } failureBlock:^(NSError * _Nullable error) {
        [HQCustomToast showNetworkError];
    }];

}


- (void)changePassWordWith:(ApiResult *)result {
    
    ChangePasswordViewController *changePwdVC = [[ChangePasswordViewController alloc] init];
    changePwdVC.sign = result.resultData[@"sign"];
    [self.navigationController pushViewController:changePwdVC animated:YES];
    
}

- (void)bindNewPhoneWith:(ApiResult *)result {
    BindNewViewController *vc = [[BindNewViewController alloc] init];
    vc.sign = result.resultData[@"sign"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (BindPhoneView *)contentView {
    
    if (!_contentView) {
        _contentView = [[BindPhoneView alloc] initWithFrame:CGRectMake(0, NavHeight, MAXScreenW, MAXScreenH - NavHeight) needTitle:YES titleText:NSLocalizedString(@"Verify_identity_with_bound_phone_number", @"已绑定手机号验证身份")];
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
