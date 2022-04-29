

//
//  ----------------------------------------------------------------------
//   File    :  DeviceTableViewCell.m
//   Author  : HYT yutong@bmxlabs.com
//   Purpose :
//   Created : 2019/2/2 by HYT yutong@bmxlabs.com
//
//  ----------------------------------------------------------------------
//
//                    Copyright (C) 2018-2019   MaxIM.Top
//
// You may obtain a copy of the licence at http://www.maxim.top/LICENCE-MAXIM.md
//
//  ----------------------------------------------------------------------
    

#import "DeviceTableViewCell.h"
#import "UIView+BMXframe.h"


@interface DeviceTableViewCell ()

@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UIView *line;

@end

@implementation DeviceTableViewCell


+ (instancetype)cellWithTableView:(UITableView *)tableview {
    NSString *cellID = @"DeviceTableViewCell";
    DeviceTableViewCell *cell = [tableview dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[DeviceTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupSubview];
    }
    return self;
}

- (void)hiddenDeleteButton:(BOOL)deleteButton {
    [self.button setHidden:deleteButton];
}

- (void)deleteDevice:(UIButton *)button {
    MAXLog(@"删除设备");
    if (self.delegate && [self.delegate respondsToSelector:@selector(deviceTableViewCelldidClickButtonWithDevice:)]) {
        [self.delegate deviceTableViewCelldidClickButtonWithDevice:self.device];
    }
}

- (void)setupSubview {
    CGFloat nickNameleft = 15;
    CGFloat avatarLeft = 15;
    CGFloat top = 10;
    
    self.titleLabel.bmx_left = nickNameleft ;
    self.titleLabel.size = CGSizeMake(MAXScreenW-90, self.bmx_height);
    self.titleLabel.bmx_centerY = self.bmx_centerY;
    
    self.contentLabel.bmx_left = nickNameleft;
    self.contentLabel.bmx_top  = top + self.titleLabel.height + 5;
    self.contentLabel.size = CGSizeMake(MAXScreenW - 60, 40);
    
    self.button.bmx_centerY = self.titleLabel.bmx_centerY;
    self.button.bmx_size = CGSizeMake(50, 30);
    self.button.bmx_right = MAXScreenW - avatarLeft;
    
    self.line.bmx_size = CGSizeMake(MAXScreenW - 10, 0.5);
    self.line.bmx_left =  10;
    self.line.bmx_right = MAXScreenW;
    self.line.bmx_bottom = 100-1;

    [self layoutIfNeeded];
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:16];
        _titleLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1/1.0];
        [self.contentView addSubview:_titleLabel];
        [_titleLabel sizeToFit];
    }
    return _titleLabel;
}


- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.textAlignment = NSTextAlignmentLeft;
        _contentLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:13];
        _contentLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1/1.0];
        [self.contentView addSubview:_contentLabel];
        [_contentLabel sizeToFit];
    }
    
    return _contentLabel;
}

- (UIButton *)button {
    if (!_button) {
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.layer.cornerRadius = 5.0;//2.0是圆角的弧度，根据需求自己更改
        _button.layer.borderColor = [UIColor blackColor].CGColor;//设置边框颜色
        _button.layer.borderWidth = 1.0f;//设置边框颜色
        _button.titleLabel.font = [UIFont systemFontOfSize:11];
        [_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_button setTitle:NSLocalizedString(@"Delete_device", @"删除设备") forState:UIControlStateNormal];
        [_button addTarget:self action:@selector(deleteDevice:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_button];
        [_button sizeToFit];
    }
    return _button;
}

- (UIView *)line {
    if (!_line) {
        _line = [[UIView alloc] init];
        [self.contentView addSubview:_line];
        _line.backgroundColor = kColorC4_5;
    }
    return _line;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
