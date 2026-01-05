#import "GetDomainAccessibility.h"

@interface GetDomainAccessibility ()

@property (nonatomic,copy) NSString *domain;


@end

@implementation GetDomainAccessibility

- (instancetype)initWithDomain:(NSString *)domain {
    if (self = [super init]) {
        self.domain = domain;
    }
    return self;
}

- (nullable NSString *)apiPath  {
    return @"app/check_domain";
}

-  (NSDictionary *)requestParams {
    return @{@"domain": self.domain};
}

- (HQRequestMethod)requestMethod {
    return HQRequestMethodPost;
}



@end
