#import "UserVerificationApi.h"


@interface UserVerificationApi ()

@property (nonatomic,copy) NSString *userId;

@end

@implementation UserVerificationApi

- (instancetype)initWithUserId:(NSString *)userId {
    if (self = [super init]) {
        self.userId = userId;
    }
    return self;
}

- (nullable NSString *)apiPath  {
    return @"app/user_verification";
}
//
//-  (NSDictionary *)requestParams {
//    return @{@"user_id": self.userId };
//}

- (HQRequestMethod)requestMethod {
    return HQRequestMethodGet;
}

@end
