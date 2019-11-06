//
//  NetworkStatusMonitor.h
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
//

#import <Foundation/Foundation.h>


@class NetworkStatusMonitor;

@protocol NetworkStatusMonitorDelegate <NSObject>

- (void)networkStatusMonitorOldStatus:(NetworkStatus)oldStatus
                        currentStatus:(NetworkStatus)currentStatus;

@end

@interface NetworkStatusMonitor : NSObject

@property (nonatomic, assign) NetworkStatus networkStatus;
@property (nonatomic, weak) id<NetworkStatusMonitorDelegate> delegate;

+ (instancetype)shared;

@end
