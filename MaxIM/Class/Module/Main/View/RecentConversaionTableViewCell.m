//
//  ----------------------------------------------------------------------
//   File    :  RecentConversaionTableViewCell.m
//   Author  : HYT yutong@bmxlabs.com
//   Purpose :
//   Created : 2018/12/27 by HYT yutong@bmxlabs.com
//
//  ----------------------------------------------------------------------
//
//                    Copyright (C) 2018-2019   MaxIM.Top
//
// You may obtain a copy of the licence at http://www.maxim.top/LICENCE-MAXIM.md
//
//  ----------------------------------------------------------------------
    

#import "RecentConversaionTableViewCell.h"
#import "UIView+BMXframe.h"
#import <UIImageView+WebCache.h>
#import <floo-ios/BMXConversation.h>

@interface RecentConversaionTableViewCell ()

@property (nonatomic, strong) UIView *line;

@end

@implementation RecentConversaionTableViewCell

+ (instancetype)cellWithTableview:(UITableView *)tableview {
    static NSString *cellId = @"RecentConversaionTableViewCell";
    RecentConversaionTableViewCell *cell = [tableview dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[RecentConversaionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
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
    CGFloat avatarLeft = 15;
    CGFloat nickNameleft = 10;
    CGFloat top = 10;
    CGFloat subtitleLabeltop = 7;
    
    self.avatarImageView.bmx_left = avatarLeft;
    self.avatarImageView.bmx_size = CGSizeMake(48, 48);
    self.avatarImageView.bmx_top = top;
    self.avatarImageView.frame = CGRectMake(avatarLeft, CGRectGetMidY(self.frame)  - 45 / 2.0 / 2.0, 48, 48);
    
    self.dotLabel.bmx_size = CGSizeMake(15, 15);
    self.dotLabel.bmx_right = self.avatarImageView.bmx_right;
    self.dotLabel.bmx_bottom = self.avatarImageView.bmx_top + 10;
    
    self.dotView.bmx_size = CGSizeMake(10, 10);
    self.dotView.bmx_right = self.avatarImageView.bmx_right+5;
    self.dotView.bmx_bottom = self.avatarImageView.bmx_top + 5;
    
    
    self.titleLabel.bmx_left = nickNameleft + self.avatarImageView.bmx_right;
    self.titleLabel.size = CGSizeMake(MAXScreenH - nickNameleft * 2  - self.avatarImageView.width , 22);
    self.titleLabel.bmx_top = top;
    
    self.subtitleLabel.bmx_left = nickNameleft + self.avatarImageView.bmx_right;
    self.subtitleLabel.size = CGSizeMake(MAXScreenH - nickNameleft * 2  - self.avatarImageView.width , 22);
    self.subtitleLabel.bmx_top = top + subtitleLabeltop + 22;
    
    self.timeLabel.bmx_size = CGSizeMake(120, 22);
    self.timeLabel.bmx_right = MAXScreenW-20;
    self.timeLabel.bmx_top = self.titleLabel.bmx_top;
    
    self.line.bmx_size = CGSizeMake(MAXScreenW - 40 - 35, 0.5);
    self.line.bmx_left = self.avatarImageView.bmx_right + 5;
    self.line.bmx_right = MAXScreenW;
    self.line.bmx_bottom = 68-1;

    
    [self layoutIfNeeded];
}

- (UIImageView *)avatarImageView {
    if (!_avatarImageView) {
        _avatarImageView = [[UIImageView alloc] init];
        _avatarImageView.clipsToBounds=YES;
        _avatarImageView.layer.cornerRadius = 24;
        [self addSubview:_avatarImageView];
        [_avatarImageView sizeToFit];
    }
    return _avatarImageView;
}

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = @"";
        _titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15];
        _titleLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1/1.0];
        [self addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UILabel *)subtitleLabel {
    if (_subtitleLabel == nil) {
        _subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.text = @"";
        _subtitleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:13];
        _subtitleLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1/1.0];
        [self addSubview:_subtitleLabel];
    }
    return _subtitleLabel;
}

- (UILabel *)timeLabel {
    if (_timeLabel == nil) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
        _timeLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1/1.0];
        _timeLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:_timeLabel];

    }
    return _timeLabel;
}

- (UIImageView *)recordImageview {
    if (_recordImageview == nil) {
        _recordImageview = [[UIImageView alloc] init];
        [self addSubview:_recordImageview];
    }
    return _recordImageview;
}

- (UILabel *)dotLabel {
    if (!_dotLabel) {
        _dotLabel = [[UILabel alloc] init];
        [self addSubview:_dotLabel];
        _dotLabel.font = [UIFont systemFontOfSize:10];
        _dotLabel.textAlignment = NSTextAlignmentCenter;
        _dotLabel.backgroundColor = [UIColor redColor];
        _dotLabel.textColor = [UIColor whiteColor];
        _dotLabel.layer.masksToBounds = YES;
        _dotLabel.layer.cornerRadius = 7.5;
    }
    return _dotLabel;
}

- (UIImageView *)dotView {
    if (!_dotView) {
        _dotView = [[UIImageView alloc] init];
        [self addSubview:_dotView];
        _dotView.backgroundColor = [UIColor redColor];
        _dotView.layer.masksToBounds = YES;
        _dotView.layer.cornerRadius = 5;
        _dotView.hidden = YES;
    }
    return _dotView;
}

- (UIView *)line {
    if (!_line) {
        _line = [[UIView alloc] init];
        [self addSubview:_line];
        _line.backgroundColor = kColorC4_5;
    }
    return _line;
}


@end
