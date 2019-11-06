//  ************************************************************************
//
//  NetworkStatusMonitor.m
//  MaxIMDemo
//
//  Created by hyt on 2017/9/30.
//  ----------------------------------------------------------------------
//
//                    Copyright (C) 2018-2019   MaxIM.Top
//
// You may obtain a copy of the licence at http://www.maxim.top/LICENCE-MAXIM.md
//
//  ----------------------------------------------------------------------


#import "NetworkStatusMonitor.h"
#import "AFNetworkReachabilityManager.h"

@interface NetworkStatusMonitor()

@property (nonatomic, strong) NSPointerArray *delegateArray;

@end

@implementation NetworkStatusMonitor

+ (instancetype)shared {
    static dispatch_once_t onceToken;
    static NetworkStatusMonitor *instance;
    dispatch_once(&onceToken, ^{
        instance = [[NetworkStatusMonitor alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        [self p_startMonitor];
    }
    return self;
}

- (void)p_startMonitor {
    AFNetworkReachabilityManager *mgr = [AFNetworkReachabilityManager sharedManager];
    [mgr setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                MAXLog(@"未知网络");
                break;
            case AFNetworkReachabilityStatusNotReachable:
                MAXLog(@"没有网络(断网)");
                [self p_postNotificationWithStatus:NotReachable];
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                MAXLog(@"手机自带网络");
                [self p_postNotificationWithStatus:ReachableViaWWAN];
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                MAXLog(@"WIFI");
                [self p_postNotificationWithStatus:ReachableViaWiFi];
                break;
        }
    }];
    // 3.开始监控
    [mgr startMonitoring];
}

- (void)p_postNotificationWithStatus:(NetworkStatus)status{
    if (_networkStatus == status) {
        return;
    }
    for (id delegate in self.delegateArray) {
        if ([delegate respondsToSelector:@selector(networkStatusMonitorOldStatus:currentStatus:)]) {
            [delegate networkStatusMonitorOldStatus:_networkStatus
                                      currentStatus:status];
        }
    }
    _networkStatus = status;
    if (status == ReachableViaWWAN) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifationConnectingiPhoneNetwork object:nil];
    } else if (status == ReachableViaWiFi) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifationConnectingInWifiNetwork object:nil];
    } else if (status == NotReachable) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifationDisConnectionNetwork object:nil];
    }
}

#pragma mark - Setter
- (void)setDelegate:(id<NetworkStatusMonitorDelegate>)delegate {
    if ([delegate respondsToSelector:@selector(networkStatusMonitorOldStatus:currentStatus:)]) {
        for (id target in self.delegateArray) {
            if ([delegate isKindOfClass:[target class]]) {
                return;
            }
        }
        [self.delegateArray addPointer:(__bridge void *)delegate];
    }
}

-(NSPointerArray *)delegateArray {
    if (!_delegateArray) {
        _delegateArray = [NSPointerArray weakObjectsPointerArray];
    }
    return _delegateArray;
}

@end
