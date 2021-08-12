//
//  ----------------------------------------------------------------------
//   File    :  GroupCreateAlertView.h
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
#import "CommonLayer.h"

@interface GroupCreateAlertView : CommonLayer

- (instancetype)initWithFrame:(CGRect)frame
                         Text:(NSString*) text
                           OK: (void (^)(NSString* title, NSString* description, NSString* message, BOOL))ok
                       Cancel: (void(^)()) cancel;

@end
