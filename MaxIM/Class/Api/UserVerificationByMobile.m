#import "UserVerificationByMobile.h"

@interface UserVerificationByMobile ()

@property (nonatomic,copy) NSString *mobile;
@property (nonatomic,copy) NSString *captach;

@end

@implementation UserVerificationByMobile

- (instancetype)initWithMobile:(NSString *)mobile  captach:(NSString *)captach {
    if (self = [super init]) {
        self.mobile = mobile;
        self.captach = captach;
    }
    return self;
}

- (nullable NSString *)apiPath  {
    return @"app/user_verification_by_mobile";
}

-  (NSDictionary *)requestParams {
    return @{@"captcha": self.captach,
             @"mobile": self.mobile };
}

- (HQRequestMethod)requestMethod {
    return HQRequestMethodPost;
}

@end
