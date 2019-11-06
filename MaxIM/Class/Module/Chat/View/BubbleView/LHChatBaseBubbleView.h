//
//  LHChatBaseBubbleView.h
//  LHChatUI
//
//  Created by hyt on 2016/12/26.
//  Copyright © 2016年 hyt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LHMessageModel.h"
#import "UIResponder+Router.h"




@interface LHChatBaseBubbleView : UIView

@property (nonatomic, strong) LHMessageModel *messageModel;

+ (CGFloat)heightForBubbleWithObject:(LHMessageModel *)object;

- (void)bubbleViewPressed:(id)sender;

@end
