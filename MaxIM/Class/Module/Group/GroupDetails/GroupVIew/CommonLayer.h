//
//  ----------------------------------------------------------------------
//   File    :  CommonLayer.h
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

@interface CommonLayer : UIView

@property (nonatomic, retain) UIView* mask;
@property (nonatomic, retain) UIView* sframe;


- (CommonLayer*)initWithFrame:(CGRect)frame;

- (CommonLayer*)initWithSframeHeight:(CGFloat) height;

-(void) setSframeHeight:(CGFloat) height;

-(void) show;
-(void) hide;
-(void) aniShowFrame;

-(void) animHideMask;
-(void) destory;
-(void) touchedBack;

@end
