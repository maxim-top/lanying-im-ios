//
//  BaseApi.m
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

#import "BaseApi.h"
#import "NetWorkingManager.h"
//#import "ApiResult.h"
#import "NSString+URLEncoding.h"
#import "AppIDManager.h"

//typedef void(^SuccessBlock)(id successObject);
//typedef void(^FailureBlock)(id object);

@interface BaseApi ()
{
    ApiSuccessBlock _customerSuccessBlock;
    ApiFailureBlock _customerFailureBlock;
    ApiResult *_result;
    
}

@end

@implementation BaseApi

- (NSString *)apiPath {
    return @"";
}

- (NSDictionary *)requestParams {
    return nil;
}

- (nullable AFConstructingBlock)constructingBodyBlock {
    return  ^(id<AFMultipartFormData> formData){
        NSDictionary *dic = [self p_dictionaryToJson:[self requestParams]];
        if (dic != nil) {
            [formData appendPartWithHeaders:nil body:[self p_bodyData]];
        }
        [formData appendPartWithHeaders:nil body:[NSData new]];
    };
}

- (HQRequestMethod)requestMethod {
    return HQRequestMethodGet;
}

- (NSString *)requestUrl {
    NSString *baseUrl;
    if ([self baseURL] == MaxIMRequestConsule) {
        baseUrl = [NSString stringWithFormat:@"%@", @"https://butler.maximtop.com/"];
    } else if ([self baseURL] == MaxIMRequestLanyingLink) {
        baseUrl = [NSString stringWithFormat:@"%@", @"https://lanying.link/"];
    } else {
        baseUrl = [NSString stringWithFormat:@"%@", @"https://api.maximtop.com/"];
    }
    
    NSString *url = [NSString stringWithFormat:@"%@%@",baseUrl, [self apiPath]];
    return url;
}

- (MaxIMRequestBaseURLType)baseURL {
    return MaxIMRequestApp;
}

- (SuccessBlock)successBlock {
    return ^(NSDictionary *dict){
        _result = [[ApiResult alloc] initWithDictionary:dict];
        if(_customerSuccessBlock)
            _customerSuccessBlock(_result);
    };
}

- (FailureBlock)failBlock {
    return ^(NSError *error){
        if(_customerFailureBlock)
            _customerFailureBlock(error);
    };
}

- (void)p_httpGet {
    NetWorkingManager *manager = NETWORK_MANAGER;
    if ([self baseURL] == MaxIMRequestConsule) {
        manager.baseURL = [NSString stringWithFormat:@"%@", @"https://butler.maxim.top/"];
    } else if ([self baseURL] == MaxIMRequestLanyingLink) {
        manager.baseURL = [NSString stringWithFormat:@"%@", @"https://lanying.link/"];
    } else {
        manager.baseURL = [NSString stringWithFormat:@"%@", @"https://api.maxim.top/"];
    }
    [manager GET:[self requestUrl]
              withParams:[self requestParams]
                 success:[self successBlock]
                    fail:[self failBlock]
                   cache:NO];
}

- (void)p_httpPost {
    NetWorkingManager *manager = NETWORK_MANAGER;
    if ([self baseURL] == MaxIMRequestConsule) {
        manager.baseURL = [NSString stringWithFormat:@"%@", @"https://butler.maxim.top/"];
    } else if ([self baseURL] == MaxIMRequestLanyingLink) {
        manager.baseURL = [NSString stringWithFormat:@"%@", @"https://lanying.link/"];
    } else {
        manager.baseURL = [NSString stringWithFormat:@"%@", @"https://api.maxim.top/"];
    }
    [manager POST:[self requestUrl]
               withParams:[self requestParams]
                  success:[self successBlock]
                     fail:[self failBlock]
                     body:nil cache:NO];
    
}

- (void)startWithSuccessBlock:(ApiSuccessBlock)success
                 failureBlock:(ApiFailureBlock)failure {
//    
//    if (![AppIDManager  isDefaultAppID] && [self baseURL] == MaxIMRequestApp) {
//        failure(nil);
//        [HQCustomToast showDialog:@"请使用默认APPID：\"welovemaxim\"" time:2];
//        return;
//    }

    
    _customerSuccessBlock = success;
    _customerFailureBlock = failure;
    if ([self requestMethod] == HQRequestMethodGet) {
        [self p_httpGet];
    } else {
        [self p_httpPost];
    }
}


- (void)startWithSuccessBlock:(ApiSuccessBlock)success {
    [self startWithSuccessBlock:success failureBlock:nil];
}

- (NSDictionary *)p_dictionaryToJson:(NSDictionary *)dic {
    if (!dic) {
        return nil;
    }
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic
                                                       options:0
                                                         error:&parseError];
    NSString *string = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSDictionary *mydict = @{@"body":string};
    return mydict;
}

- (NSData *)p_bodyData {
    NSDictionary *dict = [self p_dictionaryToJson:[self requestParams]];
    if (dict != nil) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[self p_dictionaryToJson:[self requestParams]]
                                                           options:0 error:nil];
        NSString *string = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSData *data =  [string dataUsingEncoding:NSUTF8StringEncoding];
        return data;
    }
    return nil;
}

- (ApiResult *)result {
    return _result;
}

@end
