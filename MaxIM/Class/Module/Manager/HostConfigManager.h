//
//  HostConfigManager.h
//  MaxIM
//
//  Created by 韩雨桐 on 2020/4/24.
//  Copyright © 2020 hyt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseArchiverModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HostConfigManager : BaseArchiverModel

@property (nonatomic, copy) NSString *IMServer;
@property (nonatomic, copy) NSString *IMPort;
@property (nonatomic, copy) NSString *restServer;

+ (instancetype)sharedManager;

+ (BOOL)checkLocalConfig;

- (void)updataConfig;


@end

NS_ASSUME_NONNULL_END
