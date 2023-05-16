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

#import <floo-ios/floo_proxy.h>

@class BMXGroup;
@class BMXClient;

@interface GroupHandleCell : UITableViewCell

- (void) cellInviteContentWithRoster:(BMXRosterItem*) roster group:(BMXGroup*) group inviteStatus:(BMXGroup_InvitationStatus) status exp:(long long) expTime actionHandler:(void (^)(BOOL ret)) handler;

-(void) cellApplicationContentWithRoster:(BMXRosterItem*) roster group:(BMXGroup*) group applicationStatus:(BMXGroup_ApplicationStatus) status exp:(long long) expTime actionHandler:(void (^)(BOOL ret)) handler;

+ (CGFloat) cellHeight;

@end

