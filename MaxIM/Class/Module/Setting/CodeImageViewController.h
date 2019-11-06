//
//  CodeImageViewController.h
//  MaxIM
//
//  Created by 韩雨桐 on 2019/3/20.
//  Copyright © 2019 hyt. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class BMXUserProfile;
@class BMXGroup;
@interface CodeImageViewController : UIViewController


- (instancetype)initWithProfile:(BMXUserProfile *)profile;


- (instancetype)initWithGroup:(BMXGroup *)group;



@end

NS_ASSUME_NONNULL_END
