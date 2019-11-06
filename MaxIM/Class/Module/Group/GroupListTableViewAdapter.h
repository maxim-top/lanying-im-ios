//
//  GroupListTableViewAdapter.h
//  MaxIM
//
//  Created by 韩雨桐 on 2019/9/27.
//  Copyright © 2019 hyt. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BMXGroup;

NS_ASSUME_NONNULL_BEGIN

@interface GroupListTableViewAdapter : NSObject

+ (void)getGroupListcompletion:(void(^)(NSArray <BMXGroup *>*group, NSString *errmsg))aCompletionBlock;

+ (NSArray *)tableViewCellArray;

@end

NS_ASSUME_NONNULL_END
