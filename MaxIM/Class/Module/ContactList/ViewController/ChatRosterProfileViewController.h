//
//  ----------------------------------------------------------------------
//   File    :  ChatRosterProfileViewController.h
//   Author  : HYT yutong@bmxlabs.com
//   Purpose :
//   Created : 2019/1/3 by HYT yutong@bmxlabs.com
//
//  ----------------------------------------------------------------------
//
//                    Copyright (C) 2018-2019   MaxIM.Top
//
// You may obtain a copy of the licence at http://www.maxim.top/LICENCE-MAXIM.md
//
//  ----------------------------------------------------------------------
    

#import <UIKit/UIKit.h>
@class BMXRoster;

NS_ASSUME_NONNULL_BEGIN

@interface ChatRosterProfileViewController : UIViewController

- (instancetype)initWithRoster:(BMXRoster *)roster;


- (NSArray *)getSettingConfigDataArray;

@end

NS_ASSUME_NONNULL_END
