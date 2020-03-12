//
//  UserMobileBindApi.h
//  MaxIM
//
//  Created by 韩雨桐 on 2019/11/18.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "BaseApi.h"

NS_ASSUME_NONNULL_BEGIN

@interface UserMobileBindApi : BaseApi

- (instancetype)initWithMobile:(NSString *)mobile  captach:(NSString *)captach;

@end

NS_ASSUME_NONNULL_END
