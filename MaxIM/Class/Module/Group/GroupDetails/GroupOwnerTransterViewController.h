//
//  ----------------------------------------------------------------------
//   File    :  GroupOwnerTransterViewController.h
//   Author  : shaohui.yang shaohui@bmxlabs.com
//   Purpose :
//   Created : 2018/12/25 by shaohui.yang shaohui@bmxlabs.com
//
//  ----------------------------------------------------------------------
//
//                    Copyright (C) 2018-2019   MaxIM.Top
//
// You may obtain a copy of the licence at http://www.maxim.top/LICENCE-MAXIM.md
//
//  ----------------------------------------------------------------------
    

#import <UIKit/UIKit.h>
#import "GroupBaseController.h"

@protocol GroupOwnerTransterViewControllerDelegate <NSObject>

- (void)groupOwnerTransterVCdidSelect:(id)toModel;

@end

@interface GroupOwnerTransterViewController : GroupBaseController

@property (nonatomic,weak) id<GroupOwnerTransterViewControllerDelegate> delegate;

//@property (nonatomic,assign) BOOL isTransformMessage;



@end
