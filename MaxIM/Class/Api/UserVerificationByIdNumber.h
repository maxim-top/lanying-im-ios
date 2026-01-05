#import "BaseApi.h"

NS_ASSUME_NONNULL_BEGIN

@interface UserVerificationByIdNumber : BaseApi

- (instancetype)initWithName:(NSString *)name idNumber:(NSString *)idNumber;

@end

NS_ASSUME_NONNULL_END
