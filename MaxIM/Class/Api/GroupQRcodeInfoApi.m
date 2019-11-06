
//
//  GroupQRcodeInfoApi.m
//  MaxIM
//
//  Created by 韩雨桐 on 2019/4/8.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "GroupQRcodeInfoApi.h"

@interface GroupQRcodeInfoApi ()

@property (nonatomic, strong) NSString *groupId;

@end

@implementation GroupQRcodeInfoApi

- (instancetype)initWithGroupId:(NSString *)groupId {
    if (self = [super init]) {
        self.groupId = groupId;
    }
    return self;
}

- (nullable NSString *)apiPath  {
    return @"app/qrcode/group_sign";
}

- (nullable NSDictionary *)requestParams {
    return  @{@"group_id": self.groupId};
}

- (HQRequestMethod)requestMethod {
    return HQRequestMethodGet;
}

@end
