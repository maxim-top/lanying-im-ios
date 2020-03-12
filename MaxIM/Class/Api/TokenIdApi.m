//
//  TokenIdApi.m
//  MaxIM
//
//  Created by 韩雨桐 on 2019/11/29.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "TokenIdApi.h"


@interface TokenIdApi ()

@property (nonatomic,copy) NSString *userID;
@property (nonatomic,copy) NSString *password;


@end

@implementation TokenIdApi


- (instancetype)initWithUserID:(NSString *)userID  password:(NSString *)password {
    if (self = [super init]) {
        self.userID = userID;
        self.password = password;
    }
    return self;

}

- (nullable NSString *)apiPath  {
    return @"app/token_id";
}

-  (NSDictionary *)requestParams {
    return @{@"password": self.password,
             @"user_id": self.userID};
}

- (HQRequestMethod)requestMethod {
    return HQRequestMethodPost;
}

@end
