//
//  UserMobileBindWithSignApi.m
//  MaxIM
//
//  Created by 韩雨桐 on 2019/11/18.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "UserMobileBindWithSignApi.h"


@interface UserMobileBindWithSignApi ()

@property (nonatomic,copy) NSString *mobile;
@property (nonatomic,copy) NSString *sign;



@end


@implementation UserMobileBindWithSignApi



- (instancetype)initWithMobile:(NSString *)mobile  sign:(NSString *)sign {
    if (self = [super init]) {
        self.mobile = mobile;
        self.sign = sign;
    }
    return self;
}

- (nullable NSString *)apiPath  {
    return @"app/user/mobile_bind_with_sign";
}

-  (NSDictionary *)requestParams {
    return @{@"mobile": self.mobile,
             @"sign": self.sign};
}

- (HQRequestMethod)requestMethod {
    return HQRequestMethodPost;
}



@end
