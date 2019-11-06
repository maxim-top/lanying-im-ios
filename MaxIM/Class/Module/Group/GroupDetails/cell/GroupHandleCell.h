//
//  ----------------------------------------------------------------------
//   File    :  GroupHandleCell.h
//   Author  : shaohui.yang shaohui@bmxlabs.com
//   Purpose :
//   Created : 2019/1/4 by shaohui.yang shaohui@bmxlabs.com
//
//  ----------------------------------------------------------------------
//
//                    Copyright (C) 2018-2019   MaxIM.Top
//
// You may obtain a copy of the licence at http://www.maxim.top/LICENCE-MAXIM.md
//
//  ----------------------------------------------------------------------
    


#import <UIKit/UIKit.h>

#import "BMXGroupApplication.h"
#import "BMXGroupInvitation.h"
#import "BMXRoster.h"
#import "BMXGroup.h"

@class BMXGroup;
@class BMXClient;

@interface GroupHandleCell : UITableViewCell

- (void) cellInviteContentWithRoster:(BMXRoster*) roster group:(BMXGroup*) group inviteStatus:(BMXGroupInvitationStatus) status exp:(long long) expTime actionHandler:(void (^)(BOOL ret)) handler;

-(void) cellApplicationContentWithRoster:(BMXRoster*) roster group:(BMXGroup*) group applicationStatus:(BMXGroupApplicationStatus) status exp:(long long) expTime actionHandler:(void (^)(BOOL ret)) handler;

+ (CGFloat) cellHeight;

@end

