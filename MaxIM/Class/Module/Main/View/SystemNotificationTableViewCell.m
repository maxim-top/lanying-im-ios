//
//  SystemNotificationTableViewCell.m
//  MaxIM
//
//  Created by 韩雨桐 on 2019/10/24.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "SystemNotificationTableViewCell.h"
#import "UIView+BMXframe.h"

@implementation SystemNotificationTableViewCell

+ (instancetype)cellWithTableview:(UITableView *)tableview {
    static NSString *cellId = @"SystemNotificationTableViewCell";
    SystemNotificationTableViewCell *cell = [tableview dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[SystemNotificationTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
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
  
    
    self.titleLabel.bmx_left = nickNameleft + self.avatarImageView.bmx_right;
    self.titleLabel.size = CGSizeMake(MAXScreenW - nickNameleft * 2  - self.avatarImageView.width - 10 , 22);
    self.titleLabel.bmx_top = top;
    
    self.subtitleLabel.bmx_left = nickNameleft + self.avatarImageView.bmx_right;
    self.subtitleLabel.size = CGSizeMake(MAXScreenW - nickNameleft * 2  - self.avatarImageView.width -10, 22);
    self.subtitleLabel.bmx_top = top + subtitleLabeltop + 22;
    
    self.timeLabel.bmx_size = CGSizeMake(120, 22);
    self.timeLabel.bmx_right = MAXScreenW-20;
    self.timeLabel.bmx_top = self.titleLabel.bmx_top;
    
    [self layoutIfNeeded];
}



- (UIImageView *)avatarImageView {
    if (!_avatarImageView) {
        _avatarImageView = [[UIImageView alloc] init];
        _avatarImageView.clipsToBounds=YES;
        _avatarImageView.layer.cornerRadius = 24;
        [self.contentView addSubview:_avatarImageView];
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
        [self.contentView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UILabel *)subtitleLabel {
    if (_subtitleLabel == nil) {
        _subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.text = @"";
        _subtitleLabel.numberOfLines  = 1;
        _subtitleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:13];
        _subtitleLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1/1.0];
        [self.contentView addSubview:_subtitleLabel];
    }
    return _subtitleLabel;
}

- (UILabel *)timeLabel {
    if (_timeLabel == nil) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
        _timeLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1/1.0];
        _timeLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_timeLabel];
        
    }
    return _timeLabel;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
