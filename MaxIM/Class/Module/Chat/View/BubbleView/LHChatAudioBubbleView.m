//
//  LHChatAudioBubbleView.m
//  LHChatUI
//
//  Created by hyt on 2016/12/26.
//  Copyright © 2016年 hyt. All rights reserved.
//

#import "LHChatAudioBubbleView.h"



@interface LHChatAudioBubbleView ()


@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *label;



@end

@implementation LHChatAudioBubbleView


- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        
        _voiceIcon = [[UIImageView alloc] init];
//        _voiceIcon.backgroundColor = [UIColor redColor];
        [self addSubview:_voiceIcon];
        
        _label = [[UILabel alloc] init];
        _label.userInteractionEnabled = YES;
        _label.font = [UIFont systemFontOfSize:11];
        _label.numberOfLines = 0;
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(bubbleViewPressed:)];
        [_label addGestureRecognizer:tap];
        [self addSubview:_label];

    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize retSize = CGSizeMake(50, 20);//self.messageModel.size;
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
    
    CGRect frame1 = self.bounds;
    frame1.size.width -= frame1.size.width / 1.3;
    frame1 = CGRectInset(frame1, 1, 8);
    if (self.messageModel.isSender) {
        frame1.origin.x = self.bounds.size.width/2.0 + 6;
    } else {
        frame1.origin.x = self.bounds.size.width/2.0 + 6;
    }
    
    frame1.origin.y = 8;
    [self.voiceIcon setFrame:frame1];
    
}

#pragma mark - setter

- (void)setMessageModel:(LHMessageModel *)messageModel {
    [super setMessageModel:messageModel];
    self.label.text = messageModel.content;
    self.voiceIcon.animationDuration = 0.8;
    if (messageModel.isSender) {  // sender
        self.voiceIcon.image = [UIImage imageNamed:@"right-3"];
        UIImage *image1 = [UIImage imageNamed:@"right-1"];
        UIImage *image2 = [UIImage imageNamed:@"right-2"];
        UIImage *image3 = [UIImage imageNamed:@"right-3"];
        self.voiceIcon.animationImages = @[image1, image2, image3];
    } else {                          // receive
        self.voiceIcon.image = [UIImage imageNamed:@"left-3"];
        UIImage *image1 = [UIImage imageNamed:@"left-1"];
        UIImage *image2 = [UIImage imageNamed:@"left-2"];
        UIImage *image3 = [UIImage imageNamed:@"left-3"];
        self.voiceIcon.animationImages = @[image1, image2, image3];
    }
    
}

#pragma mark - public

+ (CGFloat)heightForBubbleWithObject:(LHMessageModel *)object {
    CGSize retSize = CGSizeMake(220, 40);//object.size;
    CGFloat h =  2 * BUBBLE_VIEW_PADDING + retSize.height;
    return h;
}

- (void)bubbleViewPressed:(id)sender {
    [self routerEventWithName:kRouterEventVoiceBubbleTapEventName
                     userInfo:@{kMessageKey : self.messageModel}];
}

@end
