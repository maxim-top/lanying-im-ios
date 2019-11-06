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


- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
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
    
    self.tipLabel.bmx_left = 20;
    self.tipLabel.bmx_width = MAXScreenW - 40;
    self.tipLabel.bmx_height = 20;
    self.tipLabel.bmx_top = self.imageView.bmx_bottom + 12;
    
    self.tipLabel.text = @"这里什么也没有~";
    
    
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
        [self addSubview:_tipLabel];
    }
    return _tipLabel;
}
@end
