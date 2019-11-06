//
//  TemporaryPasswordApi.h
//  MaxIM
//
//  Created by 韩雨桐 on 2019/4/8.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "BaseApi.h"

NS_ASSUME_NONNULL_BEGIN

@interface TemporaryPasswordApi : BaseApi

- (instancetype)initWithMobile:(NSString *)mobile code:(NSString *)code;

@end

NS_ASSUME_NONNULL_END
