//
//  GroupAlreadyReadListViewController.h
//  MaxIM
//
//  Created by 韩雨桐 on 2019/8/22.
//  Copyright © 2019 hyt. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BMXMessage;
@class BMXGroup;

NS_ASSUME_NONNULL_BEGIN

@interface GroupAlreadyReadListViewController : UIViewController

- (instancetype)initWithMessage:(BMXMessage *)messageObject group:(BMXGroup *)group;

@end

NS_ASSUME_NONNULL_END
