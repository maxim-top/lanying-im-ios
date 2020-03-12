//
//  AccountInfoTableViewCell.m
//  MaxIM
//
//  Created by 韩雨桐 on 2019/12/18.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "AccountInfoTableViewCell.h"
#import "UIView+BMXframe.h"

@interface AccountInfoTableViewCell ()

@property (nonatomic, strong) UIView *line;


@end

@implementation AccountInfoTableViewCell


+ (instancetype)cellWithTableView:(UITableView *)tableview {
    NSString *cellID = @"AccountInfoTableViewCell";
    AccountInfoTableViewCell *cell = [tableview dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[AccountInfoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
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

- (void)reload:(NSString *)title subtitle:(NSString *)subtitle {
    self.titleLabel.text = title;
    self.subtitleLabel.text = subtitle;
}

- (void)setupSubview {
    self.titleLabel.bmx_size = CGSizeMake(MAXScreenW - 10 * 2,  25);
    self.titleLabel.bmx_top = 10;
    self.titleLabel.bmx_left = 15;
    
    self.subtitleLabel.bmx_size = CGSizeMake(MAXScreenW - 10 * 2,  25);
    self.subtitleLabel.bmx_top = _titleLabel.bmx_bottom + 10;
    self.subtitleLabel.bmx_left = _titleLabel.bmx_left;
    
    UIImage *image = [UIImage imageNamed:@"check"];
    self.selectImageView.bmx_size = CGSizeMake(image.size.width, image.size.height);
    self.selectImageView.bmx_right = MAXScreenW - 10;
    self.selectImageView.centerY = 69 /2.0;
    
    self.line.bmx_size = CGSizeMake(MAXScreenW - 10, 0.5);
    self.line.bmx_left =  10;
    self.line.bmx_right = MAXScreenW;
    self.line.bmx_bottom = 69-0.5;

    
    [self layoutIfNeeded];
}

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15];
        _titleLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1/1.0];
        [self addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UILabel *)subtitleLabel {
    if (_subtitleLabel == nil) {
        _subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:13];
        _subtitleLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1/1.0];
        [self addSubview:_subtitleLabel];
    }
    return _subtitleLabel;
}

- (UIImageView *)selectImageView {
    if (_selectImageView == nil) {
        _selectImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check"]];
        [self addSubview:_selectImageView];
    }
    return  _selectImageView;
}

- (UIView *)line {
    if (!_line) {
        _line = [[UIView alloc] init];
        [self addSubview:_line];
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
