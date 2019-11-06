
//
//  GetTokenApi.m
//  MaxIM
//
//  Created by 韩雨桐 on 2019/4/8.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "GetTokenApi.h"

@interface GetTokenApi ()

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *password;

@end

@implementation GetTokenApi

- (instancetype)initWithName:(NSString *)name password:(NSString *)password {
    if (self = [super init]) {
        self.name = name;
        self.password = password;
    }
    return self;
}

- (nullable NSString *)apiPath  {
    return @"app/token";
}

- (nullable NSDictionary *)requestParams {
    return  @{@"name": self.name,
              @"password":self.password};
}

- (HQRequestMethod)requestMethod {
    return HQRequestMethodPost;
}

@end
