//
//  UserMobileBindWithSignApi.h
//  MaxIM
//
//  Created by 韩雨桐 on 2019/11/18.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "BaseApi.h"

NS_ASSUME_NONNULL_BEGIN

@interface UserMobileBindWithSignApi : BaseApi

- (instancetype)initWithMobile:(NSString *)mobile  sign:(NSString *)sign;

@end

NS_ASSUME_NONNULL_END
