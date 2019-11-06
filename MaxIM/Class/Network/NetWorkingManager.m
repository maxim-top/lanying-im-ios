//
//  NetWorkingManager.m
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

#import "NetWorkingManager.h"
#import "AFNetworking.h"
#import "NetWorkingManager.h"
#import "NetworkService.h"
#import "NSString+URLEncoding.h"
#import "IMAcountInfoStorage.h"
#import "IMAcount.h"
#import "ConsuleAppInfoStorage.h"
#import "ConsuleAppInfo.h"

static NetworkService *_networkService;


NSString *disConnectionNetworkNotifation = @"disConnectionNetworkNotifation";

NSString *connectingInWifiNetworkNotifation = @"connectingInWifiNetworkNotifation";

NSString * connectingIPhoneNetworkNotifation = @"connectingIPhoneNetworkNotifation";

@interface NetWorkingManager()

// 当前网络状态
@property (nonatomic, assign) NetworkStatus internetStatus;

@property (nonatomic, copy) NSString *http_uri;

@end

@implementation NetWorkingManager

- (AFHTTPSessionManager *)manager{
    if (!_manager) {
        _manager = [[AFHTTPSessionManager alloc] init];
//        MAXLog(@"______%@",BASE_URL);
        [self p_configSecurityPolicy];
        AFJSONRequestSerializer *requset = [AFJSONRequestSerializer serializer];
        [requset setTimeoutInterval:kRequestTimeOutDuration];
        [_manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        _manager.requestSerializer = requset;
        _manager.responseSerializer = [AFJSONResponseSerializer serializer];
        _manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html",@"text/json", @"text/javascript",@"text/plain", nil];
        _networkService = [NetworkService shareNetworkService];

        
    }
    return _manager;
}

- (instancetype)initWithNetworkStatusListening {
    self = [super init];
    if (self) {
        [self listenNetworkState];
    }
    return self;
}

- (void)p_configSecurityPolicy {
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    [securityPolicy setValidatesDomainName:NO];
    _manager.securityPolicy = securityPolicy;
    
}

+ (instancetype)netWorkingManager {
    NetWorkingManager *netWorkingManager = [[NetWorkingManager alloc] init];
    [netWorkingManager manager];
    return netWorkingManager;
}

+ (instancetype)netWorkingManagerWithNetworkStatusListening {
    NetWorkingManager *netWorkingManager = [[NetWorkingManager alloc] initWithNetworkStatusListening];
    [netWorkingManager manager];
    return netWorkingManager;
}

- (NSURLSessionDataTask* )POST:(NSString*)URLString
                    withParams:(NSDictionary *)params
                       success:(void(^)(NSDictionary *dict))successBlock
                          fail:(void(^)(NSError *error))failerrorBlock
                          body:(BodyBlock)bodyBlock
                         cache:(BOOL)cache {
    self.http_uri = [self p_getHttpURIFromURL:URLString];
    
    
    [self setHeader];
    cache = false;
    
    NSURLSessionDataTask *task = [self.manager POST:URLString parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                           successBlock(responseObject);

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                           failerrorBlock(error);

    }];
    return  task;
}

- (void)resetHeaderWithAppID:(NSString *)appID {
    [self.manager.requestSerializer setValue:appID forHTTPHeaderField:@"app_id"];
}


- (void)setHeader {
    IMAcount *acount = [IMAcountInfoStorage loadObject];
    if ([acount.token length]) {
        [self.manager.requestSerializer setValue:acount.token forHTTPHeaderField:@"access-token"];
    }
    
    [self.manager.requestSerializer setValue:@"welovemaxim" forHTTPHeaderField:@"app_id"];

    
    
    ConsuleAppInfo *appinfo = [ConsuleAppInfoStorage loadObject];
    if ([appinfo.appId length]) {
        [self.manager.requestSerializer setValue:appinfo.appId forHTTPHeaderField:@"app_id"];
    }

}

- (NSURLSessionDataTask*)GET:(NSString*)URLString
                  withParams:(NSDictionary*)params
                     success:(void(^)(NSDictionary *dict))successBlock
                        fail:(void(^)(NSError *error))failerrorBlock
                       cache:(BOOL)cache {
    self.http_uri = [self p_getHttpURIFromURL:URLString];
    
    [self setHeader];
    URLString = [self normalizedURL:URLString WithQueryString:params];
    return [self.manager GET:URLString
                  parameters:nil
                    progress:^(NSProgress * _Nonnull downloadProgress) {
                    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                        successBlock(responseObject);
                    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                        failerrorBlock(error);
                    }];
}

#pragma mark - Tool
//字典转json格式字符串：
- (NSDictionary *)dictionaryToJson:(NSDictionary *)dic {
    if (!dic) {
        return nil;
    }
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic
                                                       options:0
                                                         error:&parseError];
    NSString *string = [[NSString alloc] initWithData:jsonData
                                             encoding:NSUTF8StringEncoding];
    NSDictionary *mydict = @{@"body":string};
    return mydict;
}

- (NSString *)normalizedURL:(NSString *)URL WithQueryString:(NSDictionary *)parameters {
    NSString *queryString = [self normalizedRequestParameters:parameters];
    if (queryString != nil && queryString.length > 0) {
        URL = [NSString stringWithFormat:@"%@?%@",URL,queryString];
    }
    return URL;
}

- (NSString *)normalizedRequestParameters:(NSDictionary *)parameters {
    if (parameters == nil) {
        return nil;
    }
    NSMutableArray *parametersArray = [NSMutableArray array];
    for (NSString *key in parameters) {
        NSString *value = [parameters valueForKey:key];
        [parametersArray addObject:[NSString stringWithFormat:@"%@=%@",
                                    key,
                                    [value isKindOfClass:[NSString class]]?[value URLEncodedString]:value]];
    }
    return [parametersArray componentsJoinedByString:@"&"];
}

- (void)listenNetworkState {
    AFNetworkReachabilityManager *mgr = [AFNetworkReachabilityManager sharedManager];
    [mgr setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                MAXLog(@"未知网络");
                break;
                
            case AFNetworkReachabilityStatusNotReachable:
                self.internetStatus = NotReachable;
                [[NSNotificationCenter defaultCenter] postNotificationName:disConnectionNetworkNotifation
                                                                    object:nil];
                MAXLog(@"没有网络(断网)");
                break;
                
            case AFNetworkReachabilityStatusReachableViaWWAN:
                MAXLog(@"手机自带网络");
                [self postNetworkInPhoneNet:ReachableVia3G oldStatus:self.internetStatus];
                self.internetStatus = ReachableVia3G;
                break;
                
            case AFNetworkReachabilityStatusReachableViaWiFi:
                [self postNetworkInWifi:ReachableViaWiFi oldStatus:self.internetStatus];
                self.internetStatus = ReachableViaWiFi;
                MAXLog(@"WIFI");
                break;
        }
    }];
    // 3.开始监控
    [mgr startMonitoring];
}

- (void)postNetworkInPhoneNet:(NetworkStatus)status
                    oldStatus:(NetworkStatus)oldStatus {
    if ( ReachableVia3G == oldStatus) {
        return;
    }
    self.internetStatus = status;
    [[NSNotificationCenter defaultCenter] postNotificationName:connectingIPhoneNetworkNotifation
                                                        object:nil];;
}

- (void)postNetworkInWifi:(NetworkStatus)status oldStatus:(NetworkStatus)oldStatus{
    if ( ReachableViaWiFi == oldStatus) {
        return;
    }
    self.internetStatus = status;
    [[NSNotificationCenter defaultCenter] postNotificationName:connectingInWifiNetworkNotifation
                                                        object:nil];;
}

- (NSString *)p_getHttpURIFromURL:(NSString *)URLStr {
    NSURL *baseUrl = [NSURL URLWithString:self.baseURL];
    NSString *URI = [URLStr stringByReplacingOccurrencesOfString:[baseUrl absoluteString]
                                                      withString:@""];
    if ([URI containsString:@"?"]) {
        NSRange range = [URI rangeOfString:@"?"];
        URI = [URI substringToIndex:range.location];
    }
    URI = [NSString stringWithFormat:@"/%@",URI];
    return URI;
}

@end
