//
//  WechatApi.h
//  MaxIM
//
//  Created by 韩雨桐 on 2019/4/29.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "BaseApi.h"

NS_ASSUME_NONNULL_BEGIN

@interface WechatApi : BaseApi

- (instancetype)initWithTempCode:(NSString *)tempCode;

@end

NS_ASSUME_NONNULL_END




