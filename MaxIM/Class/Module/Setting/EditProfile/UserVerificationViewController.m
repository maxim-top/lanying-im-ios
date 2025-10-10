#import "UserVerificationViewController.h"
#import "BindPhoneView.h"
#import "UIViewController+CustomNavigationBar.h"
#import "CaptchaApi.h"
#import "UserVerificationByMobile.h"

@interface UserVerificationViewController ()<BindPhoneProtocol>


@property (nonatomic, strong) BindPhoneView *contentView;


@end

@implementation UserVerificationViewController

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
    [self setNavigationBarTitle:NSLocalizedString(@"real_name_verification", @"实名认证") navLeftButtonIcon:@"blackback"];
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
    
    UserVerificationByMobile *api = [[UserVerificationByMobile alloc] initWithMobile:phone captach:chptcha];
    [api startWithSuccessBlock:^(ApiResult * _Nullable result) {
        if (result.isOK) {
            [self.navigationController popViewControllerAnimated:YES];
            [HQCustomToast showDialog:NSLocalizedString(@"Verified_successfully", @"认证成功")];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
            [HQCustomToast showDialog:NSLocalizedString(@"permission_need_enabled", @"此业务需要开通，请联系App管理员。")];
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
