//
//  NotifierUploadPushInfoApi.h
//  MaxIM
//
//  Created by 韩雨桐 on 2019/6/28.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "BaseApi.h"

NS_ASSUME_NONNULL_BEGIN

@interface NotifierUploadPushInfoApi : BaseApi

- (instancetype)initWithDeviceToken:(NSString *)deviceToken
                               uuid:(NSString *)uuid;
@end

NS_ASSUME_NONNULL_END
