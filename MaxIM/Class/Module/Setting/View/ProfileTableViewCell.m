//
//  ----------------------------------------------------------------------
//   File    :  ProfileTableViewCell.m
//   Author  : HYT yutong@bmxlabs.com
//   Purpose :
//   Created : 2018/12/28 by HYT yutong@bmxlabs.com
//
//  ----------------------------------------------------------------------
//
//                    Copyright (C) 2018-2019   MaxIM.Top
//
// You may obtain a copy of the licence at http://www.maxim.top/LICENCE-MAXIM.md
//
//  ----------------------------------------------------------------------
    

#import "ProfileTableViewCell.h"
#import "UIView+BMXframe.h"

@interface ProfileTableViewCell ()

@property (nonatomic, strong) UIView *line;

@end

@implementation ProfileTableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableview {
    NSString *cellID = @"ProfileTableViewCell";
    ProfileTableViewCell *cell = [tableview dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[ProfileTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
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
    self.titleLabel.size = CGSizeMake(180, self.bmx_height);
    
    self.contentLabel.size = CGSizeMake(MAXScreenW - 200, self.bmx_height);
    self.contentLabel.bmx_right = MAXScreenW - 30;
    
    self.avatarimageView.bmx_right = MAXScreenW - 15 - 40 - 20;
    self.avatarimageView.bmx_size = CGSizeMake(40, 40);
    
    self.line.bmx_size = CGSizeMake(MAXScreenW - 40 - 35, 0.5);
    self.line.bmx_left = self.avatarimageView.bmx_right + 5;
    self.line.bmx_right = MAXScreenW;
    self.line.bmx_bottom = 68-1;
    
    [self layoutIfNeeded];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.avatarimageView.bmx_centerY  = self.contentView.bmx_centerY;
    self.contentLabel.bmx_centerY = self.contentView.bmx_centerY;
    self.titleLabel.bmx_centerY = self.contentView.bmx_centerY;

}

- (UIImageView *)avatarimageView {
    if (!_avatarimageView) {
        _avatarimageView = [[UIImageView alloc] init];
        [self.contentView addSubview:_avatarimageView];
        _avatarimageView.layer.masksToBounds = YES;
        _avatarimageView.layer.cornerRadius = 2;
        [_avatarimageView sizeToFit];
    }
    return _avatarimageView;
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
        _contentLabel.textAlignment = NSTextAlignmentRight;
        _contentLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:16];
        _contentLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1/1.0];
        [self.contentView addSubview:_contentLabel];
        [_contentLabel sizeToFit];
    }
    
    return _contentLabel;
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
