//
//  NetWorkingManager.h
//  MaxIMDemo
//
//  Created by hanyutong on 16/7/5.
//  ----------------------------------------------------------------------
//
//                    Copyright (C) 2018-2019   MaxIM.Top
//
// You may obtain a copy of the licence at http://www.maxim.top/LICENCE-MAXIM.md
//
//  ----------------------------------------------------------------------
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"
#import "JSONResult.h"

extern NSString *disConnectionNetworkNotifation;
extern NSString *connectingInWifiNetworkNotifation;
extern NSString *connectingIPhoneNetworkNotifation;
static NSInteger kRequestTimeOutDuration = 10;


@class JSONResult;

@interface NetWorkingManager : NSObject
@property (strong,nonatomic) AFHTTPSessionManager* manager;
@property (assign, nonatomic) BOOL isActive;
@property (copy, nonatomic)  NSString *CIDStr;
@property (assign, nonatomic) BOOL isLogin;
@property (copy, nonatomic) NSString *SIDStr;
@property (nonatomic,copy) NSString *baseURL;

typedef void (^MutipleResult)(BOOL isSuccess, NSString *errmsg);
typedef void (^SuccessBlock)(id responseObject);
typedef void (^BodyBlock)(id<AFMultipartFormData> formData);
typedef void (^FailureBlock)(id object);

+ (instancetype)netWorkingManager;
+ (instancetype)netWorkingManagerWithNetworkStatusListening;

- (void)resetHeaderWithAppID:(NSString *)appID;

- (NSURLSessionDataTask*)GET:(NSString*)URLString
                  withParams:(NSDictionary*)params
                     success:(void(^)(NSDictionary *dict))successBlock
                        fail:(void(^)(NSError *error))failerrorBlock cache:(BOOL)cache;

- (NSURLSessionDataTask* )POST:(NSString*)URLString
                    withParams:(NSDictionary *)params
                       success:(void(^)(NSDictionary *dict))successBlock
                          fail:(void(^)(NSError *error))failerrorBlock
                          body:(BodyBlock)bodyBlock
                         cache:(BOOL)cache;
// TODO:后端目前接口不可用
- (void)uploadImage:(UIImage *)image success:(SuccessBlock)success failure:(FailureBlock)failure;


@end
