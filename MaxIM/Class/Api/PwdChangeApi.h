//
//  PwdChangeApi.h
//  MaxIM
//
//  Created by 韩雨桐 on 2020/4/20.
//  Copyright © 2020 hyt. All rights reserved.
//

#import "BaseApi.h"

NS_ASSUME_NONNULL_BEGIN

@interface PwdChangeApi : BaseApi

- (instancetype)initWithPassword:(NSString *)password
                newPasswordCheck:(NSString *)newPasswordCheck
                            sign:(NSString *)sign;

@end

NS_ASSUME_NONNULL_END
