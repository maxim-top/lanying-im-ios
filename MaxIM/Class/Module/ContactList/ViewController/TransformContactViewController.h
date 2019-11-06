//
//  TransformContactViewController.h
//  MaxIM
//
//  Created by 韩雨桐 on 2019/8/27.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "ContactListViewController.h"

@class BMXRoster;
@class BMXGroup;

NS_ASSUME_NONNULL_BEGIN

@protocol TransformContactVCProtocol <NSObject>

- (void)transterSlectedRoster:(BMXRoster *)roster;
- (void)transterSlectedGroup:(BMXGroup *)group;

@end

@interface TransformContactViewController : UIViewController

@property (nonatomic,assign) id<TransformContactVCProtocol> delegate;


@end

NS_ASSUME_NONNULL_END
