//
//  BaseApi.h
//  MaxIMDemo
//
//  Created by hanyutong on 16/8/9.
//  ----------------------------------------------------------------------
//
//                    Copyright (C) 2018-2019   MaxIM.Top
//
// You may obtain a copy of the licence at http://www.maxim.top/LICENCE-MAXIM.md
//
//  ----------------------------------------------------------------------
//

#import <Foundation/Foundation.h>
#import "AFURLRequestSerialization.h"
#import "ApiResult.h"

typedef NS_ENUM(NSInteger , HQRequestMethod) {
    HQRequestMethodGet = 0,
    HQRequestMethodPost
};

typedef NS_ENUM(NSInteger , MaxIMRequestBaseURLType) {
    MaxIMRequestApp = 0,
    MaxIMRequestConsule
};

typedef void (^AFConstructingBlock)(id <AFMultipartFormData> _Nonnull formData);

@class BaseApi;

typedef void(^BaseApiCompletionBlock)(__kindof BaseApi * _Nullable request);
typedef void(^ApiSuccessBlock)(ApiResult * _Nullable result);
typedef void(^ApiFailureBlock)(NSError * _Nullable error);

@interface BaseApi : NSObject

//可以重写
- (nullable AFConstructingBlock)constructingBodyBlock;
- (nullable NSString *)apiPath;
- (nullable NSDictionary *)requestParams;
- (nullable ApiResult *)result;
- (MaxIMRequestBaseURLType)baseURL;
- (HQRequestMethod)requestMethod;
- (void)startWithSuccessBlock:(nullable ApiSuccessBlock)success failureBlock:(nullable ApiFailureBlock)failure;

- (void)uploadImageWithSuccessBlock:(ApiSuccessBlock _Nullable )success
                       failureBlock:(ApiFailureBlock _Nullable )failure;

@end
