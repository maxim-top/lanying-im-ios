//
//  QRCodeLoginApi.h
//  MaxIM
//
//  Created by 韩雨桐 on 2019/4/25.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "BaseApi.h"

NS_ASSUME_NONNULL_BEGIN

@interface QRCodeLoginApi : BaseApi

- (instancetype)initWithQRCode:(NSString *)QRCode;

@end

NS_ASSUME_NONNULL_END
