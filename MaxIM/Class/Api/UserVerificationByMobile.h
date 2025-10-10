#import "BaseApi.h"

NS_ASSUME_NONNULL_BEGIN

@interface UserVerificationByMobile : BaseApi

- (instancetype)initWithMobile:(NSString *)mobile  captach:(NSString *)captach;

@end

NS_ASSUME_NONNULL_END
