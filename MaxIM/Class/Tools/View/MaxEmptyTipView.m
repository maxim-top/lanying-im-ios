//
//  MaxEmptyTipView.m
//  MaxIM
//
//  Created by 韩雨桐 on 2019/11/6.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "MaxEmptyTipView.h"
#import "UIView+BMXframe.h"

@interface MaxEmptyTipView ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel  *tipLabel;

@end

@implementation MaxEmptyTipView


- (instancetype)initWithFrame:(CGRect)frame type:(MaxEmptyTipType)type {
    
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
        [self labelString:type];
    }
    return self;
}

- (void)setupUI {
    
    self.backgroundColor = BMXCOLOR_HEX(0xffffff);
    UIImage *image = [UIImage imageNamed:@"EmptyTipView"];
    self.imageView.image = image;
    self.imageView.bmx_size = image.size;
    self.imageView.bmx_centerX = MAXScreenW / 2;
    self.imageView.bmx_centerY = self.bmx_height / 2 - 40;
    
    self.tipLabel.bmx_left = 30;
    self.tipLabel.bmx_width = MAXScreenW - 60;
    self.tipLabel.bmx_height = 40;
    self.tipLabel.bmx_top = self.imageView.bmx_bottom + 12;
    
}

- (void)labelString:(MaxEmptyTipType)type {
    if (type == MaxEmptyTipTypeCommonBlank) {
        self.tipLabel.text = NSLocalizedString(@"Nothing_here", @"你没有聊天会话，可以在右上角搜索用户id添加好友。");
    } else if(type == MaxEmptyTipTypeContactSupport) {
        self.tipLabel.text = NSLocalizedString(@"If_you_want_to_experience", @"如果想要体验该功能，请退出后，将APPID切换成`welovemaxim`");
//        [self.tipLabel sizeToFit];
    } else if(type == MaxEmptyTipTypeBlocklist) {
        self.tipLabel.text = NSLocalizedString(@"block_list_empty", @"黑名单为空，您可以在好友列表上左划来添加好友到黑名单");
    }
}


- (UIImageView *)imageView  {
    
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        [self addSubview:_imageView];
    }
    return _imageView;
}


- (UILabel *)tipLabel {
    
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.font = [UIFont systemFontOfSize:12];
        _tipLabel.textColor = BMXCOLOR_HEX(0x0079F4);
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.numberOfLines = 0;
        [self addSubview:_tipLabel];
    }
    return _tipLabel;
}
@end
