#import "SecretInfoAPI.h"

@interface SecretInfoAPI ()

@property (nonatomic, strong) NSString *code;

@end

@implementation SecretInfoAPI

- (instancetype)initWithCode:(NSString *)code {
    if (self = [super init]) {
        self.code = code;
    }
    return self;
}

- (nullable NSString *)apiPath  {
    return @"app/secret_info";
}

- (nullable NSDictionary *)requestParams {
    return  @{@"code":self.code};
}

- (HQRequestMethod)requestMethod {
    return HQRequestMethodGet;
}

@end
