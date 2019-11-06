//
//  NotifierUploadPushInfoApi.m
//  MaxIM
//
//  Created by 韩雨桐 on 2019/6/28.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "NotifierUploadPushInfoApi.h"

@interface NotifierUploadPushInfoApi ()

@property (nonatomic,copy) NSString *deviceToken;
@property (nonatomic,copy) NSString *uuid;

@end

@implementation NotifierUploadPushInfoApi

- (instancetype)initWithDeviceToken:(NSString *)deviceToken
                               uuid:(NSString *)uuid {
    if (self = [super init]) {
        self.deviceToken = deviceToken;
        self.uuid = uuid;
    }
    return self;
}

- (nullable NSString *)apiPath  {
    return @"notifier/upload_push_info";
}

- (nullable NSDictionary *)requestParams {
    return  @{@"device_token": self.deviceToken,
              @"uuid": self.uuid};
}

- (HQRequestMethod)requestMethod {
    return HQRequestMethodPost;
}

- (MaxIMRequestBaseURLType)baseURL {
    return MaxIMRequestConsule;
}


@end
