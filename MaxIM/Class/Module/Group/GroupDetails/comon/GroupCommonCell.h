//
//  ----------------------------------------------------------------------
//   File    :  GroupCommonCell.h
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


@interface GroupCommonCell : UITableViewCell


- (void) setMainText:(NSString *) mainText detailText:(NSString *) detailText switcherFlag:(BOOL) switcherFlag switcherTarget:(__weak id) target switcherSelector:(nullable SEL) selector;

- (void) showAccesor:(BOOL) isShow;

- (void) showSepLine:(BOOL) isShow;

@property (nonatomic, strong) UIImageView *avatarImageView;


@end

