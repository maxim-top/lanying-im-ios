

//
//  TitleSwitchTableViewCell.m
//  MaxIM
//
//  Created by hyt on 2018/12/30.
//  Copyright © 2018年 hyt. All rights reserved.
//

#import "TitleSwitchTableViewCell.h"
#import "UIView+BMXframe.h"

@interface TitleSwitchTableViewCell ()


@end

@implementation TitleSwitchTableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableview {
    NSString *cellID = @"TitleSwitchTableViewCell";
    TitleSwitchTableViewCell *cell = [tableview dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[TitleSwitchTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
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

- (void)setupSubview {
    CGFloat nickNameleft = 15;
    
    self.titleLabel.bmx_left = nickNameleft ;
    self.titleLabel.size = CGSizeMake(200, self.bmx_height);

    self.contentLabel.bmx_left = nickNameleft + 80;
    self.contentLabel.size = CGSizeMake(MAXScreenW - nickNameleft * 2  -  80, self.bmx_height);
   
    self.mswitch.bmx_right = MAXScreenW - 15 ;
    self.mswitch.size = CGSizeMake(40, self.bmx_height);
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.titleLabel.bmx_centerY = self.contentView.bmx_centerY;
    self.contentLabel.bmx_centerY = self.contentView.bmx_centerY;
    self.mswitch.bmx_centerY = self.contentView.bmx_centerY + 5;
    self.contentLabel.bmx_right = self.contentView.bmx_right - 10;
}


- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:16];
        _titleLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1/1.0];
        [self.contentView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.textAlignment = NSTextAlignmentRight;
        _contentLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:16];
        _contentLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1/1.0];
        [self.contentView addSubview:_contentLabel];
        
    }
    
    return _contentLabel;
}

- (UISwitch *)mswitch {
    if (!_mswitch) {
        _mswitch = [[UISwitch alloc] init];
        _mswitch.onTintColor = BMXCOLOR_HEX(0x0079f4);
        _mswitch.transform = CGAffineTransformMakeScale(0.65, 0.65);
        [_mswitch addTarget:self action:@selector(clickSwitch:) forControlEvents:UIControlEventValueChanged];
        [self.contentView addSubview:_mswitch];
    }
    return _mswitch;
}

- (void)clickSwitch:(UISwitch *)swi {
    if (self.delegate && [self.delegate respondsToSelector:@selector(cellDidchangeSwitchStatus:cell:)]) {
        [self.delegate cellDidchangeSwitchStatus:swi cell:self];
    }
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
