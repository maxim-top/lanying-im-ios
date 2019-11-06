//
//  NotifierBindApi.h
//  MaxIM
//
//  Created by 韩雨桐 on 2019/6/12.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "BaseApi.h"

NS_ASSUME_NONNULL_BEGIN

@interface NotifierBindApi : BaseApi

- (instancetype)initWithAppID:(NSString *)appID
                  deviceToken:(NSString *)deviceToken
                 notifierName:(NSString *)notifierName
                       userID:(NSString *)userID;

@end

NS_ASSUME_NONNULL_END
