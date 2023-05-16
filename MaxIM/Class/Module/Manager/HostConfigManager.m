//
//  HostConfigManager.m
//  MaxIM
//
//  Created by 韩雨桐 on 2020/4/24.
//  Copyright © 2020 hyt. All rights reserved.
//

#import "HostConfigManager.h"
#import <floo-ios/floo_proxy.h>
#import "HostConfigStorage.h"

@implementation HostConfigManager
static HostConfigManager *manager = nil;

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [HostConfigStorage  loadObject];
        if (!manager) {
            manager = [[HostConfigManager alloc] init];
        }
        
    });
    
    return manager;
}

+ (BOOL)checkLocalConfig {
    
    return [HostConfigStorage  loadObject] != nil;
}

- (instancetype)init {
    
    self = [super init];
    if (self) {
        _IMPort = @"";
        _IMServer = @"";
        _restServer = @"";
    }
    return self;
}

- (void)setIMServer:(NSString *)IMServer {
    
    _IMServer = IMServer;
}


- (void)setIMPort:(NSString *)IMPort {
    
    int port = [IMPort intValue];
    if (port > 0) {
        _IMPort = IMPort;
    }else  {
        _IMPort = @"";
    }
    
}

- (void)setRestServer:(NSString *)RestServer {
    
    _restServer = RestServer;
}
- (void)updataConfig {
    
    BMXSDKConfigHostConfig *config  =  [[[BMXClient sharedClient] getSDKConfig] getHostConfig];
    if (_IMServer.length > 0 && _IMPort.length > 0 && _restServer.length > 0) {
        [config setImHost: _IMServer];
        [config setImPort: [_IMPort intValue]];
        [config setRestHost: _restServer];
        [[[BMXClient sharedClient] getSDKConfig] setHostConfig: config];
        [HostConfigStorage saveObject:self];
    }
//    if (_IMPort.length > 0) {
//        
//        config.mPort = [_IMPort intValue];
//    }
//    if (_restServer.length > 0) {
//        
//        config.restHost = _restServer;
//    }
//    if (_IMServer.length > 0 ) {
//        
//        [[BMXClient sharedClient] sdkConfig].hostConfig = config;
//        [HostConfigStorage saveObject:self];
//    }
}

- (void)setIsUserServer:(BOOL)isUserServer {
    
    if (!isUserServer) {
        self.IMServer = @"";
        self.IMPort = @"";
        self.restServer = @"";
    }
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dictionary];
    }
    return self;
}
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
    
}


@end
