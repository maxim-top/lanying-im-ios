
//
//  NotifierBindApi.m
//  MaxIM
//
//  Created by 韩雨桐 on 2019/6/12.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "NotifierBindApi.h"

@interface NotifierBindApi ()

@property (nonatomic,copy) NSString *appID;
@property (nonatomic,copy) NSString *deviceToken;
@property (nonatomic,copy) NSString *notifierName;
@property (nonatomic,copy) NSString *userID;

@end

@implementation NotifierBindApi

- (instancetype)initWithAppID:(NSString *)appID
                  deviceToken:(NSString *)deviceToken
                 notifierName:(NSString *)notifierName
                       userID:(NSString *)userID {
    if (self = [super init]) {
        self.appID = appID;
        self.deviceToken = deviceToken;
        self.notifierName = notifierName;
        self.userID = userID;
    }
    return self;
}

- (nullable NSString *)apiPath  {
    return @"notifier/bind";
}

- (nullable NSDictionary *)requestParams {
    return  @{@"app_id": self.appID,
              @"device_token": self.deviceToken,
              @"notifier_name": self.notifierName,
              @"user_id": [NSNumber numberWithInteger:[self.userID integerValue]]};
}

- (HQRequestMethod)requestMethod {
    return HQRequestMethodPost;
}

- (MaxIMRequestBaseURLType)baseURL {
    return MaxIMRequestConsule;
}


@end
