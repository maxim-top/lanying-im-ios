//
//  LoginViewController.h
//  MaxIM
//
//  Created by 韩雨桐 on 2019/11/16.
//  Copyright © 2019 hyt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface LoginViewController : UIViewController

+ (UIViewController *)loginViewWithViewControllerWithNavigation;

- (instancetype)initWithViewType:(LoginVCType)viewType;



@end

NS_ASSUME_NONNULL_END
