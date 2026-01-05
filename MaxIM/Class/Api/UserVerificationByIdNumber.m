#import "UserVerificationByIdNumber.h"

@interface UserVerificationByIdNumber ()

@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *idNumber;

@end

@implementation UserVerificationByIdNumber

- (instancetype)initWithName:(NSString *)name idNumber:(NSString *)idNumber {
    if (self = [super init]) {
        self.name = name;
        self.idNumber = idNumber;
    }
    return self;
}

- (nullable NSString *)apiPath  {
    return @"app/user_verification_by_id_card";
}

-  (NSDictionary *)requestParams {
    return @{@"id_card_number": self.idNumber,
             @"name": self.name };
}

- (HQRequestMethod)requestMethod {
    return HQRequestMethodPost;
}

@end
