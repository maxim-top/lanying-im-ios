//
//  TransterViewController.h
//  MaxIM
//
//  Created by hyt on 2019/1/11.
//  Copyright © 2019年 hyt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BMXGroup.h"
#import "BMXRoster.h"

@protocol TransterContactProtocol <NSObject>

- (void)transterSlectedRoster:(BMXRoster *)roster;
- (void)transterSlectedGroup:(BMXGroup *)group;

@end

NS_ASSUME_NONNULL_BEGIN

@interface TransterViewController : UIViewController

@property (nonatomic,assign) id<TransterContactProtocol> delegate;

@end

NS_ASSUME_NONNULL_END
