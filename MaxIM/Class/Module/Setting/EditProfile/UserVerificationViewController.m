#import "UserVerificationViewController.h"
#import "UserVerificationView.h"
#import "UIViewController+CustomNavigationBar.h"
#import "CaptchaApi.h"
#import "UserVerificationByMobile.h"
#import "UserVerificationByIdNumberViewController.h"
#import "MAXUtils.h"

@interface UserVerificationViewController ()<BindPhoneProtocol>


@property (nonatomic, strong) UserVerificationView *contentView;


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
            NSString *error = NSLocalizedString(@"Verification failure", @"认证失败");
            if (result.code == 500 && [result.errmsg hasPrefix:@"Too Many Requests"]) {
                error = NSLocalizedString(@"error_sms_code_RequestFailed", @"短信验证码请求失败。");
            }

            [HQCustomToast showDialog:error];
        }
        
    } failureBlock:^(NSError * _Nullable error) {
        [HQCustomToast showNetworkError];
    }];
 
    MAXLog(@"%@",phone);
}

- (void)nextPage{
    if ([MAXUtils needShowVerificationPage:@"id_card"]) {
        [self gotoIdNumberUserVerification];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)gotoIdNumberUserVerification {
    UserVerificationByIdNumberViewController *vc = [[UserVerificationByIdNumberViewController alloc] init];
    
    // 获取当前导航栈的可变副本
    NSMutableArray *currentViewControllers = [self.navigationController.viewControllers mutableCopy];
    // 移除当前视图控制器（如果有的话）
    if ([currentViewControllers containsObject:self]) {
        [currentViewControllers removeObject:self];
    }

    // 添加目标视图控制器
    [currentViewControllers addObject:vc];

    // 设置新的导航栈
    [self.navigationController setViewControllers:currentViewControllers animated:YES];
}

- (void)commitPhone:(NSString *)phone chptcha:(NSString *)chptcha {
    if (phone.length == 0) {
        [self nextPage];
        return;
    }
    UserVerificationByMobile *api = [[UserVerificationByMobile alloc] initWithMobile:phone captach:chptcha];
    [api startWithSuccessBlock:^(ApiResult * _Nullable result) {
        if (result.isOK) {
            [self nextPage];
            [HQCustomToast showDialog:NSLocalizedString(@"Verified_successfully", @"认证成功")];
        } else {
            NSString *error = NSLocalizedString(@"Verification failure", @"认证失败");
            [HQCustomToast showDialog:error];
        }
    } failureBlock:^(NSError * _Nullable error) {
        [HQCustomToast showNetworkError];
    }];

    MAXLog(@"phone = %@ , chptcha = %@", phone, chptcha);
}

- (UserVerificationView *)contentView {
    if (!_contentView) {
        _contentView = [[UserVerificationView alloc] initWithFrame:CGRectMake(0, NavHeight, MAXScreenW, MAXScreenH - NavHeight)];
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
