//
//  LHChatImageBubbleView.m
//  LHChatUI
//
//  Created by hyt on 2016/12/26.
//  Copyright © 2016年 hyt. All rights reserved.
//

#import "LHChatImageBubbleView.h"
#import "SDImageCache.h"
#import "UIImageView+WebCache.h"

//　图片最大显示大小
CGFloat const MAX_SIZE = 120.0f;

@interface LHChatImageBubbleView ()



@end

@implementation LHChatImageBubbleView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _imageView = [[UIImageView alloc] init];
        _imageView.layer.cornerRadius = 6;
        _imageView.layer.masksToBounds= YES;
        _imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(bubbleViewPressed:)];
        [_imageView addGestureRecognizer:tap];
        [self addSubview:_imageView];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize retSize = CGSizeMake(self.messageModel.width, self.messageModel.height);//self.messageModel.size;
    if (retSize.width == 0 || retSize.height == 0) {
        retSize.width = MAX_SIZE;
        retSize.height = MAX_SIZE;
    }
    if (retSize.width > retSize.height) {
        CGFloat height =  MAX_SIZE / retSize.width  *  retSize.height;
        retSize.height = height;
        retSize.width = MAX_SIZE;
    } else {
        CGFloat width = MAX_SIZE / retSize.height * retSize.width;
        retSize.width = width;
        retSize.height = MAX_SIZE;
    }
    
    return CGSizeMake(retSize.width + BUBBLE_VIEW_PADDING * 1 + BUBBLE_ARROW_WIDTH, 1 * BUBBLE_VIEW_PADDING + retSize.height);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect frame = self.bounds;
//    frame.size.width -= BUBBLE_ARROW_WIDTH;
    frame = CGRectInset(frame, 0, 0);
    if (self.messageModel.isSender) {
        frame.origin.x = 0;
    } else {
        frame.origin.x =  BUBBLE_ARROW_WIDTH - 5;
    }
    
    frame.origin.y = 0;
    [self.imageView setFrame:frame];
}

#pragma mark - setter

- (void)setMessageModel:(LHMessageModel *)messageModel {
    [super setMessageModel:messageModel];
    self.imageView.image = [UIImage imageNamed:@"imageCell_Placer"];
    
    if (messageModel.imageRemoteURL && ![messageModel.imageRemoteURL isKindOfClass:[NSNull class]] && [[NSFileManager defaultManager] fileExistsAtPath:messageModel.imageRemoteURL]) {
            UIImage *image = [UIImage imageWithContentsOfFile:messageModel.imageRemoteURL];
            self.imageView.image = image;
        
    }else {
        self.imageView.image = [UIImage imageNamed:@"imageCell_Placer"];
    }
}

#pragma mark - public

+ (CGFloat)heightForBubbleWithObject:(LHMessageModel *)object {
    CGSize retSize = CGSizeMake(object.width, object.height);//object.size;
    if (retSize.width == 0 || retSize.height == 0) {
        retSize.width = MAX_SIZE;
        retSize.height = MAX_SIZE;
    } else if (retSize.width > retSize.height) {
        CGFloat height =  MAX_SIZE / retSize.width  *  retSize.height;
        retSize.height = height;
        retSize.width = MAX_SIZE;
    } else {
        CGFloat width = MAX_SIZE / retSize.height * retSize.width;
        retSize.width = width;
        retSize.height = MAX_SIZE;
    }
    MAXLog(@"%f, %f", retSize.width, retSize.height);
    CGFloat h = 2 * BUBBLE_VIEW_PADDING + retSize.height + 20;
    MAXLog(@"%f",h);

    return h;
}

- (void)bubbleViewPressed:(id)sender {
    [self routerEventWithName:kRouterEventImageBubbleTapEventName
                     userInfo:@{kMessageKey : self.messageModel}];
}

@end
