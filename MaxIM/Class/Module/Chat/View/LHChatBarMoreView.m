//
//  LHChatBarMoreView.m
//  LHChatUI
//
//  Created by hyt on 2016/12/23.
//  Copyright © 2016年 hyt. All rights reserved.
//

#import "LHChatBarMoreView.h"

const NSInteger CHAT_BUTTON_SIZE = 55;
const NSInteger INSETS = 8;

@interface LHChatBarMoreView ()

@property (nonatomic, strong) UIButton *photoButton;
@property (nonatomic, strong) UIButton *takePicButton;
@property (nonatomic, strong) UIButton *locationButton;
@property (nonatomic, strong) UIButton *fileButton;
@property (nonatomic, strong) UIButton *videoButton;


@end

@implementation LHChatBarMoreView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor lh_colorWithHex:0xf2f2f6];
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews {
    CGFloat insets = (self.frame.size.width - 4 * CHAT_BUTTON_SIZE) / 5;
    
    _photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_photoButton setFrame:CGRectMake(insets, 25, CHAT_BUTTON_SIZE , CHAT_BUTTON_SIZE)];
    [_photoButton setImage:[UIImage imageNamed:@"picture"] forState:UIControlStateNormal];
    [_photoButton setImage:[UIImage imageNamed:@"picture"] forState:UIControlStateHighlighted];
    [_photoButton addTarget:self action:@selector(photoAction) forControlEvents:UIControlEventTouchUpInside];
    _photoButton.titleLabel.textColor = [UIColor lh_colorWithHex:0x8e8e93];
    [self addSubview:_photoButton];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(insets, CGRectGetMaxY(_photoButton.frame) + 10, CHAT_BUTTON_SIZE, 12)];
    label.font = [UIFont systemFontOfSize:12];
    label.text = NSLocalizedString(@"Photos", @"照片");
    label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:label];
    
    _takePicButton =[UIButton buttonWithType:UIButtonTypeCustom];
    [_takePicButton setFrame:CGRectMake(insets * 2 + CHAT_BUTTON_SIZE, 25, CHAT_BUTTON_SIZE , CHAT_BUTTON_SIZE)];
    [_takePicButton setImage: [UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
    [_takePicButton setImage:[UIImage imageNamed:@"camera"] forState:UIControlStateHighlighted];
    [_takePicButton addTarget:self action:@selector(takePicAction) forControlEvents:UIControlEventTouchUpInside];
    _takePicButton.titleLabel.textColor = [UIColor lh_colorWithHex:0x8e8e93];
    [self addSubview:_takePicButton];
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(insets*2+ CHAT_BUTTON_SIZE, CGRectGetMaxY(_takePicButton.frame) + 10, CHAT_BUTTON_SIZE, 12)];
    label2.font = [UIFont systemFontOfSize:12];
    label2.text = NSLocalizedString(@"Snap", @"拍照");
    label2.textAlignment = NSTextAlignmentCenter;
    [self addSubview:label2];
    
    
    _locationButton =[UIButton buttonWithType:UIButtonTypeCustom];
    [_locationButton setFrame:CGRectMake(insets * 3 + CHAT_BUTTON_SIZE * 2 , 25, CHAT_BUTTON_SIZE , CHAT_BUTTON_SIZE)];
    [_locationButton setImage: [UIImage imageNamed:@"loc"] forState:UIControlStateNormal];
    [_locationButton setImage:[UIImage imageNamed:@"loc"] forState:UIControlStateHighlighted];
    [_locationButton addTarget:self action:@selector(locationAction) forControlEvents:UIControlEventTouchUpInside];
    _locationButton.titleLabel.textColor = [UIColor lh_colorWithHex:0x8e8e93];
    [self addSubview:_locationButton];
    
    UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(insets*3 + CHAT_BUTTON_SIZE * 2 , CGRectGetMaxY(_takePicButton.frame) + 10, CHAT_BUTTON_SIZE, 12)];
    label3.font = [UIFont systemFontOfSize:12];
    label3.text = NSLocalizedString(@"Location", @"位置");
    label3.textAlignment = NSTextAlignmentCenter;
    [self addSubview:label3];
    
    _fileButton =[UIButton buttonWithType:UIButtonTypeCustom];
    [_fileButton setFrame:CGRectMake(insets * 4  + CHAT_BUTTON_SIZE * 3, 25, CHAT_BUTTON_SIZE , CHAT_BUTTON_SIZE)];
    [_fileButton setImage: [UIImage imageNamed:@"file"] forState:UIControlStateNormal];
    [_fileButton setImage:[UIImage imageNamed:@"file"] forState:UIControlStateHighlighted];
    [_fileButton addTarget:self action:@selector(fileAction) forControlEvents:UIControlEventTouchUpInside];
    _fileButton.titleLabel.textColor = [UIColor lh_colorWithHex:0x8e8e93];
    [self addSubview:_fileButton];
    
    UILabel *label4 = [[UILabel alloc] initWithFrame:CGRectMake(insets*4+ CHAT_BUTTON_SIZE  * 3, CGRectGetMaxY(_takePicButton.frame) + 10, CHAT_BUTTON_SIZE, 12)];
    label4.font = [UIFont systemFontOfSize:12];
    label4.text = NSLocalizedString(@"File", @"文件");
    label4.textAlignment = NSTextAlignmentCenter;
    [self addSubview:label4];
    
    _videoButton =[UIButton buttonWithType:UIButtonTypeCustom];
    [_videoButton setFrame:CGRectMake(insets , CGRectGetMaxY(label.frame) + 10, CHAT_BUTTON_SIZE , CHAT_BUTTON_SIZE)];
    [_videoButton setImage: [UIImage imageNamed:@"video"] forState:UIControlStateNormal];
    [_videoButton setImage:[UIImage imageNamed:@"video"] forState:UIControlStateHighlighted];
    [_videoButton addTarget:self action:@selector(videoAction) forControlEvents:UIControlEventTouchUpInside];
    _videoButton.titleLabel.textColor = [UIColor lh_colorWithHex:0x8e8e93];
    [self addSubview:_videoButton];
    
    UILabel *label5 = [[UILabel alloc] initWithFrame:CGRectMake(insets, CGRectGetMaxY(_videoButton.frame) + 10, CHAT_BUTTON_SIZE, 12)];
    label5.font = [UIFont systemFontOfSize:12];
    label5.text = NSLocalizedString(@"Short_video", @"小视频");
    label5.textAlignment = NSTextAlignmentCenter;
    [self addSubview:label5];
    

}

#pragma mark - action

- (void)takePicAction {
    if(_delegate && [_delegate respondsToSelector:@selector(moreViewTakePicAction:)]){
        [_delegate moreViewTakePicAction:self];
    }
}

- (void)photoAction {
    if (_delegate && [_delegate respondsToSelector:@selector(moreViewPhotoAction:)]) {
        [_delegate moreViewPhotoAction:self];
    }
}

- (void)locationAction {
    if (_delegate && [_delegate respondsToSelector:@selector(moreViewLocationAction:)]) {
        [_delegate moreViewLocationAction:self];
    }
}

- (void)fileAction {
    if (_delegate && [_delegate respondsToSelector:@selector(moreViewFileAction:)]) {
        [_delegate moreViewFileAction:self];
    }
}

- (void)videoAction {
    if (_delegate && [_delegate respondsToSelector:@selector(moreViewVideoAction:)]) {
        [_delegate moreViewVideoAction:self];
    }
}

@end
