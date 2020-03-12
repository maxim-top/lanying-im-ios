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
        self.tipLabel.text = @"这里什么也没有~";
    } else {
        self.tipLabel.text = @"如果想联系技术支持，请退出后，将APPID切换成\"welovemaxim\"";
//        [self.tipLabel sizeToFit];
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
