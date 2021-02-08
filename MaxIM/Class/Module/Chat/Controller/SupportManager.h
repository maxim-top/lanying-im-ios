//
//  SupportManager.h
//  MaxIM
//
//  Created by 韩雨桐 on 2020/5/27.
//  Copyright © 2020 hyt. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BMXRoster;
NS_ASSUME_NONNULL_BEGIN

typedef void(^IsSupportBlock)(BOOL isSupport);

@interface SupportManager : NSObject

@property (nonatomic, copy) IsSupportBlock isSupportBlock;

+ (id)sharedSupportManager;

- (void)checkCurrentRoster:(BMXRoster *)roster
                 isSupport:(IsSupportBlock)isSupportBlock;

@end

NS_ASSUME_NONNULL_END
