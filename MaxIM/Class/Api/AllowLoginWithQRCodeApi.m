#import "AllowLoginWithQRCodeApi.h"

@interface AllowLoginWithQRCodeApi ()

@property (nonatomic, strong) NSString *qrcode;

@end

@implementation AllowLoginWithQRCodeApi

- (instancetype)initWithQrCode:(NSString *)code {
    if (self = [super init]) {
        self.qrcode = code;
    }
    return self;
}

- (nullable NSString *)apiPath  {
    return @"app/allow";
}

- (nullable NSDictionary *)requestParams {
    return  @{@"allow":@1,
              @"qr_code":self.qrcode};
}

- (HQRequestMethod)requestMethod {
    return HQRequestMethodGet;
}

@end
