#import "UserVerificationByIdNumberViewController.h"
#import "UserVerificationByIdNumberView.h"
#import "UIViewController+CustomNavigationBar.h"
#import "CaptchaApi.h"
#import "UserVerificationByIdNumber.h"

@interface UserVerificationByIdNumberViewController ()<BindPhoneProtocol>


@property (nonatomic, strong) UserVerificationByIdNumberView *contentView;


@end

@implementation UserVerificationByIdNumberViewController

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

- (void)commitName:(NSString *)name idNumber:(NSString *)idNumber {
    if (name.length == 0) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    UserVerificationByIdNumber *api = [[UserVerificationByIdNumber alloc] initWithName:name idNumber:idNumber];
    [api startWithSuccessBlock:^(ApiResult * _Nullable result) {
        if (result.isOK) {
            [self.navigationController popViewControllerAnimated:YES];
            [HQCustomToast showDialog:NSLocalizedString(@"Verified_successfully", @"认证成功")];
        } else {
            [HQCustomToast showDialog:NSLocalizedString(@"Verification failure", @"认证失败")];
        }
    } failureBlock:^(NSError * _Nullable error) {
        [HQCustomToast showNetworkError];
    }];

    MAXLog(@"name = %@ , id number = %@", name, idNumber);
}

- (UserVerificationByIdNumberView *)contentView {
    if (!_contentView) {
        _contentView = [[UserVerificationByIdNumberView alloc] initWithFrame:CGRectMake(0, NavHeight, MAXScreenW, MAXScreenH - NavHeight)];
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
