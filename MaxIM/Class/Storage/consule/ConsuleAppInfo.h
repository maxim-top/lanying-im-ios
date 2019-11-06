//
//  ConsuleAppInfo.h
//  MaxIM
//
//  Created by 韩雨桐 on 2019/6/28.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "BaseArchiverModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ConsuleAppInfo : BaseArchiverModel

@property (nonatomic,copy) NSString *appId;
@property (nonatomic,copy) NSString *uuid;
@property (nonatomic,copy) NSString *deviceToken;


@end

NS_ASSUME_NONNULL_END
