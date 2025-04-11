#import "BaseApi.h"

NS_ASSUME_NONNULL_BEGIN

@interface AllowLoginWithQRCodeApi : BaseApi

- (instancetype)initWithQrCode:(NSString *)code;

@end

NS_ASSUME_NONNULL_END
