//
//  LHChatBarMoreView.h
//  LHChatUI
//
//  Created by hyt on 2016/12/23.
//  Copyright © 2016年 hyt. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LHChatBarMoreView;

@protocol LHChatBarMoreViewDelegate <NSObject>

@required
- (void)moreViewTakePicAction:(LHChatBarMoreView *)moreView;
- (void)moreViewPhotoAction:(LHChatBarMoreView *)moreView;
- (void)moreViewLocationAction:(LHChatBarMoreView *)moreView;
- (void)moreViewFileAction:(LHChatBarMoreView *)moreView;
- (void)moreViewVideoAction:(LHChatBarMoreView *)moreView;

@end

@interface LHChatBarMoreView : UIView

@property (nonatomic, weak) id<LHChatBarMoreViewDelegate> delegate;

@end
