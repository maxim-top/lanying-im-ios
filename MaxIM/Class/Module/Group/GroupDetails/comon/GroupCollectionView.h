//
//  ----------------------------------------------------------------------
//   File    :  GroupCollectionView.h
//   Author  : shaohui.yang shaohui@bmxlabs.com
//   Purpose :
//   Created : 2018/12/26 by shaohui.yang shaohui@bmxlabs.com
//
//  ----------------------------------------------------------------------
//
//                    Copyright (C) 2018-2019   MaxIM.Top
//
// You may obtain a copy of the licence at http://www.maxim.top/LICENCE-MAXIM.md
//
//  ----------------------------------------------------------------------
    

#import <UIKit/UIKit.h>
#import <floo-ios/BMXRoster.h>


@protocol groupMemberCollectionDelegate <NSObject>

-(void) groupMemberCellTouchedRoster:(BMXRoster*) roster;
-(void) groupMemberCellTouchedAdd;

@end


@interface GroupCollectionView : UIView

@property (nonatomic, weak, nullable) id <groupMemberCollectionDelegate> gmCollectionDelegate;

-(void) fillRosterList:(NSArray*) list limit2line:(BOOL) limit;

+ (CGFloat) calcHeightWithArrcount:(NSInteger) count limt:(BOOL) limit;



@end
