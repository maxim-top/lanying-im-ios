//
//  LocationManger.h
//  MaxIM
//
//  Created by 韩雨桐 on 2019/6/17.
//  Copyright © 2019 hyt. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol LocationMangerDelegate <NSObject>


@end

@interface LocationManger : NSObject

- (void)start;
- (void)stopLocate;

@end

NS_ASSUME_NONNULL_END
