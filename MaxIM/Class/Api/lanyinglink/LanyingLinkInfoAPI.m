#import "LanyingLinkInfoAPI.h"

@interface LanyingLinkInfoAPI ()

@property (nonatomic,copy) NSString *link;

@end

@implementation LanyingLinkInfoAPI

- (instancetype)initWithLink:(NSString *)link {
    if (self = [super init]) {
        self.link = link;
    }
    return self;
}

- (nullable NSString *)apiPath  {
    return @"info";
}

- (nullable NSDictionary *)requestParams {
    return  @{@"link": self.link};
}

- (HQRequestMethod)requestMethod {
    return HQRequestMethodGet;
}

- (MaxIMRequestBaseURLType)baseURL {
    return MaxIMRequestLanyingLink;
}


@end
