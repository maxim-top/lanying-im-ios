//
//  ----------------------------------------------------------------------
//   File    :  GroupBaseController.h
//   Author  : shaohui.yang shaohui@bmxlabs.com
//   Purpose :
//   Created : 2018/12/27 by shaohui.yang shaohui@bmxlabs.com
//
//  ----------------------------------------------------------------------
//
//                    Copyright (C) 2018-2019   MaxIM.Top
//
// You may obtain a copy of the licence at http://www.maxim.top/LICENCE-MAXIM.md
//
//  ----------------------------------------------------------------------
    

#import <UIKit/UIKit.h>

@class BMXGroup;

@interface GroupBaseController : UIViewController

@property (nonatomic, strong) BMXGroup *group;

- (instancetype)initWithGroup:(BMXGroup *)group;


- (BOOL) isOwner;

- (BOOL) isSelf:(NSString*) compareId;

@end


