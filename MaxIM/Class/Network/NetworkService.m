//  ************************************************************************
//
//  NetworkService.m
//  MaxIMDemo
//
//  Created by hanyutong on 2017/8/3.
//  ----------------------------------------------------------------------
//
//                    Copyright (C) 2018-2019   MaxIM.Top
//
// You may obtain a copy of the licence at http://www.maxim.top/LICENCE-MAXIM.md
//
//  ----------------------------------------------------------------------
//
//  Main function: 暂时只配置了网络请求header
//
//  Other specifications:
//
//  ************************************************************************

#import "NetworkService.h"
#import "NetWorkingManager.h"

static NSString *kNetStatus;
static NetworkService *_networkService;


@implementation NetworkService

+ (NetworkService *)shareNetworkService {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _networkService = [[self alloc] init];
        [_networkService p_addObservers];
    });
    return _networkService;
}

- (void)p_addObservers {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(p_networkStatusDidChanged:)
                   name:connectingIPhoneNetworkNotifation object:nil];
    
    [center addObserver:self selector:@selector(p_networkStatusDidChanged:)
                   name:connectingInWifiNetworkNotifation object:nil];
    
    [center addObserver:self selector:@selector(p_networkStatusDidChanged:)
                   name:disConnectionNetworkNotifation object:nil];
}

- (void)p_removeObservers {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:connectingIPhoneNetworkNotifation object:nil];
    [center removeObserver:self name:connectingInWifiNetworkNotifation object:nil];
    [center removeObserver:self name:disConnectionNetworkNotifation object:nil];
}

- (void)dealloc {
    [self p_removeObservers];
}

- (void)p_networkStatusDidChanged:(NSNotification *)notifiaction {
    kNetStatus = @"unknow";
    if ([notifiaction.name isEqualToString:@"disConnectionNetworkNotifation"]) {
        kNetStatus = @"disConnectionNetwork";
    } else if ([notifiaction.name isEqualToString:@"connectingIPhoneNetworkNotifation"]) {
        kNetStatus = @"wwan";
    } else if ([notifiaction.name isEqualToString:@"connectingInWifiNetworkNotifation"]) {
        kNetStatus = @"wifi";
    }
}

@end

