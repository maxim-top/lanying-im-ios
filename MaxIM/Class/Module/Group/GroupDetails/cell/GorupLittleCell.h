//
//  ----------------------------------------------------------------------
//   File    :  GorupLittleCell.h
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
@class BMXRoster;
@interface GorupLittleCell : UITableViewCell


-(void) setAvatarStr:(NSString*) avatarStr RosterName:(NSString*) name Selected:(BOOL) isSelected;

-(void) setAvatarUrl:(NSString*) avatarUrl RosterName:(NSString*) name Selected:(BOOL) isSelected;
-(void) setAvatarRoster:(BMXRoster*)roster RosterName:(NSString*) name Selected:(BOOL) isSelected;


-(void) setSelect:(BOOL) isSelect;

-(void) showAdmin:(BOOL) isShow;

- (void)setDlownAvatar:(BMXRoster *)roster Selected:(BOOL) isSelected;
@end

