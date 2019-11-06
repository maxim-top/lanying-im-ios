//
//  ----------------------------------------------------------------------
//   File    :  GroupCreateViewController.h
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

@class BMXRoster;
@class BMXGroup;


@protocol GroupCreateViewControllerDelegate <NSObject>

- (void)atgroupmemberVCdidPopToLastVC:(NSArray<BMXRoster *> *)rosterArray;

@end

@interface GroupCreateViewController : UIViewController

@property (nonatomic,assign) BOOL isAt;

@property (nonatomic,weak) id<GroupCreateViewControllerDelegate> delegate;

- (instancetype)initWithCurrentGroup:(BMXGroup *)group;

@end

