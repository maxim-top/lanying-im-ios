//
//  LHChatLocationBubbleView.m
//  LHChatUI
//
//  Created by hyt on 2016/12/26.
//  Copyright © 2016年 hyt. All rights reserved.
//

#import "LHChatLocationBubbleView.h"

@interface LHChatLocationBubbleView ()

@property (nonatomic, strong) UILabel *label;

@end

@implementation LHChatLocationBubbleView



- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _label = [[UILabel alloc] init];
        _label.userInteractionEnabled = YES;
        _label.numberOfLines = 0;
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(bubbleViewPressed:)];
        [_label addGestureRecognizer:tap];
        [self addSubview:_label];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize retSize = CGSizeMake(220, 80);//self.messageModel.size;
    return CGSizeMake(retSize.width + BUBBLE_VIEW_PADDING * 1 + BUBBLE_ARROW_WIDTH, 1 * BUBBLE_VIEW_PADDING + retSize.height);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect frame = self.bounds;
    frame.size.width -= BUBBLE_ARROW_WIDTH;
    frame = CGRectInset(frame, 2, 2);
    if (self.messageModel.isSender) {
        frame.origin.x = 2;
    } else {
        frame.origin.x = 2 + BUBBLE_ARROW_WIDTH;
    }
    
    frame.origin.y = 2;
    [self.label setFrame:frame];
}

#pragma mark - setter

- (void)setMessageModel:(LHMessageModel *)messageModel {
    [super setMessageModel:messageModel];
    self.label.text = messageModel.content;
    
}

#pragma mark - public

+ (CGFloat)heightForBubbleWithObject:(LHMessageModel *)object {
    CGSize retSize = CGSizeMake(220, 80);//object.size;
    return 2 * BUBBLE_VIEW_PADDING + retSize.height + 20;
}

- (void)bubbleViewPressed:(id)sender {
    [self routerEventWithName:kRouterEventLocationBubbleTapEventName
                     userInfo:@{kMessageKey : self.messageModel}];
}

@end
