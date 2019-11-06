//
//  GroupBaseInfoViewController.h
//  MaxIM
//
//  Created by 韩雨桐 on 2019/3/25.
//  Copyright © 2019 hyt. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BMXGroup;
NS_ASSUME_NONNULL_BEGIN

@interface GroupBasicInfoViewController : UIViewController

- (instancetype)initWithGroup:(BMXGroup *)group info:(NSString *)info;

@end

NS_ASSUME_NONNULL_END
