//
//  LHChatBaseBubbleView.m
//  LHChatUI
//
//  Created by hyt on 2016/12/26.
//  Copyright © 2016年 hyt. All rights reserved.
//

#import "LHChatBaseBubbleView.h"

// bubbleView 的背景图片
NSString *const BUBBLE_LEFT_IMAGE_NAME = @"bubble_normal";
NSString *const BUBBLE_RIGHT_IMAGE_NAME = @"bubble_normal_owner";

@interface LHChatBaseBubbleView ()

@property (nonatomic, strong) UIImageView *backImageView;

@end

@implementation LHChatBaseBubbleView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.backImageView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(bubbleViewPressed:)];
        [self addGestureRecognizer:tap];
        
        UILongPressGestureRecognizer *press = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(bubbleViewLongPressed:)];
        [self addGestureRecognizer:press];
    }
    return self;
}

- (void)setMessageModel:(LHMessageModel *)messageModel {
    _messageModel = messageModel;
    
    BOOL isReceiver = !messageModel.isSender;
    NSString *imageName = isReceiver ? BUBBLE_LEFT_IMAGE_NAME : BUBBLE_RIGHT_IMAGE_NAME;
    NSInteger leftCapWidth = isReceiver?BUBBLE_LEFT_LEFT_CAP_WIDTH:BUBBLE_RIGHT_LEFT_CAP_WIDTH;
    NSInteger topCapHeight =  isReceiver?BUBBLE_LEFT_TOP_CAP_HEIGHT:BUBBLE_RIGHT_TOP_CAP_HEIGHT;
    
    UIImage *image = [UIImage imageNamed:imageName];
    NSInteger bottomCapHeight = image.size.height - topCapHeight - 1;
    NSInteger rightCapWidth = image.size.width - leftCapWidth -1;
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(topCapHeight, leftCapWidth, bottomCapHeight, rightCapWidth)];
    self.backImageView.image = image;
}

#pragma mark - public
+ (CGFloat)heightForBubbleWithObject:(LHMessageModel *)object {
    return 40;
}

- (void)bubbleViewPressed:(id)sender {
    [self routerEventWithName:kRouterEventChatCellBubbleTapEventName userInfo:@{kMessageKey : self.messageModel}];
}

- (void)bubbleViewLongPressed:(id)sender {
    
    [self routerEventWithName:kRouterEventLongPressName userInfo:@{kMessageKey : self.messageModel,@"ges":sender}];
}


#pragma mark - lazy
- (UIImageView *)backImageView {
    if (!_backImageView) {
        _backImageView = [[UIImageView alloc] init];
        _backImageView.userInteractionEnabled = YES;
        _backImageView.multipleTouchEnabled = YES;
        _backImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    return _backImageView;
}



@end
