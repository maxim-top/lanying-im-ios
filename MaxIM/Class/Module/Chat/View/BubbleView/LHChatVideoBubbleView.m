//
//  LHChatVideoBubbleView.m
//  LHChatUI
//
//  Created by hyt on 2016/12/26.
//  Copyright © 2016年 hyt. All rights reserved.
//

#import "LHChatVideoBubbleView.h"
#import "SDImageCache.h"
#import "UIImageView+WebCache.h"
#import "BMXVideoAttachment.h"
#import "UIView+BMXframe.h"

//　图片最大显示大小
CGFloat const MAX_SIZE1 = 120.0f;


@interface LHChatVideoBubbleView ()

@property (nonatomic, strong) UIImageView *playImageView;
@property (nonatomic, strong) UILabel *durationLabel;

@end

@implementation LHChatVideoBubbleView


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
        retSize.width = MAX_SIZE1;
        retSize.height = MAX_SIZE1;
    }
    if (retSize.width > retSize.height) {
        CGFloat height =  MAX_SIZE1 / retSize.width  *  retSize.height;
        retSize.height = height;
        retSize.width = MAX_SIZE1;
    } else {
        CGFloat width = MAX_SIZE1 / retSize.height * retSize.width;
        retSize.width = width;
        retSize.height = MAX_SIZE1;
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
    
    self.durationLabel.bmx_bottom = self.imageView.bmx_bottom - 20;
    self.durationLabel.bmx_left = self.imageView.bmx_right - 50 - 10;
    self.durationLabel.size = CGSizeMake(50, 20);
    
    self.playImageView.center = self.imageView.center;
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
    
    BMXVideoAttachment *attachment = (BMXVideoAttachment *)self.messageModel.messageObjc.attachment;
    self.durationLabel.text = [NSString stringWithFormat:@"%d s", attachment.duration];
}

#pragma mark - public

+ (CGFloat)heightForBubbleWithObject:(LHMessageModel *)object {
    CGSize retSize = CGSizeMake(object.width, object.height);//object.size;
    if (retSize.width == 0 || retSize.height == 0) {
        retSize.width = MAX_SIZE1;
        retSize.height = MAX_SIZE1;
    } else if (retSize.width > retSize.height) {
        CGFloat height =  MAX_SIZE1 / retSize.width  *  retSize.height;
        retSize.height = height;
        retSize.width = MAX_SIZE1;
    } else {
        CGFloat width = MAX_SIZE1 / retSize.height * retSize.width;
        retSize.width = width;
        retSize.height = MAX_SIZE1;
    }
    MAXLog(@"%f, %f", retSize.width, retSize.height);
    CGFloat h = 2 * BUBBLE_VIEW_PADDING + retSize.height + 20;
    MAXLog(@"%f",h);
    
    return h;
}

- (void)bubbleViewPressed:(id)sender {
    [self routerEventWithName:kRouterEventVideoBubbleTapEventName
                     userInfo:@{kMessageKey : self.messageModel}];
}

- (UIImageView *)playImageView {
    if (_playImageView == nil) {
        _playImageView = [[UIImageView alloc] init];
        _playImageView.image = [UIImage imageNamed:@"recordPlay"];
        [_playImageView sizeToFit];
        [self addSubview:_playImageView];
    }
    return _playImageView;
}

- (UILabel *)durationLabel {
    if (_durationLabel == nil) {
        _durationLabel = [[UILabel alloc] init];
        _durationLabel.textAlignment = NSTextAlignmentRight;
        _durationLabel.textColor = [UIColor blackColor];
        _durationLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:_durationLabel];
    }
    return _durationLabel;
}

@end
