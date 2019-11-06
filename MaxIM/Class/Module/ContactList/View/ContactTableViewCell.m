//
//  ----------------------------------------------------------------------
//   File    :  ContactTableViewCell.m
//   Author  : HYT yutong@bmxlabs.com
//   Purpose :
//   Created : 2019/1/16 by HYT yutong@bmxlabs.com
//
//  ----------------------------------------------------------------------
//
//                    Copyright (C) 2018-2019   MaxIM.Top
//
// You may obtain a copy of the licence at http://www.maxim.top/LICENCE-MAXIM.md
//
//  ----------------------------------------------------------------------
    
#import "ContactTableViewCell.h"
#import "UIView+BMXframe.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "BMXClient.h"
#import "BMXRoster.h"

static NSString *cellID = @"ContactTableViewCell";

@interface ContactTableViewCell()

@end

@implementation ContactTableViewCell


+ (instancetype)contactTableViewCellWith:(UITableView *)tableView {
    ContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier  {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)clickAccept:(id)sender {
    MAXLog(@"接受请求");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ContanctAddClick" object:self.contact];
}

- (void)refreshByTitle:(NSString *)titlel {
    self.nicknameLabel.text = titlel;
}

- (void)refresh:(BMXRoster *)roster {
    self.contact = roster;
    
    
    self.avatarImg.image = [UIImage imageNamed:@"contact_placeholder"];
    self.nicknameLabel.text = roster.userName;
    
    UIImage *image = [UIImage imageWithContentsOfFile:roster.avatarThumbnailPath];
    if (!image) {
        
        [[[BMXClient sharedClient] rosterService] downloadAvatarWithRoster:roster progress:^(int progress, BMXError *error) {
            
        }  completion:^(BMXRoster *rosterObjc, BMXError *error) {
            if (!error) {
                UIImage *image = [UIImage imageWithContentsOfFile:rosterObjc.avatarThumbnailPath];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.avatarImg.image = image;
                });
            }
        }];
    }else {
        self.avatarImg.image = image;
    }
}

- (void)setupUI {
    CGFloat avatarLeft = 15;
    CGFloat nickNameleft = 10;
    CGFloat top = 10;
    
    self.avatarImg.bmx_left = avatarLeft;
    self.avatarImg.bmx_size = CGSizeMake(40, 40);
    
    self.nicknameLabel.bmx_left = nickNameleft + self.avatarImg.bmx_right;
    self.nicknameLabel.size = CGSizeMake(MAXScreenW - nickNameleft * 2  - self.avatarImg.width , 20);
    self.nicknameLabel.bmx_top = top;
    
    self.infoLabel.bmx_left = nickNameleft + self.avatarImg.bmx_right;
    self.infoLabel.bmx_top = self.nicknameLabel.bmx_bottom;
    self.infoLabel.size = CGSizeMake(MAXScreenW - nickNameleft * 2  - self.avatarImg.width , 40);

    
    self.contentLabel.bmx_size = CGSizeMake(100, 30);
    self.contentLabel.bmx_right = MAXScreenW - avatarLeft;
    
    
    self.button.bmx_size = CGSizeMake(50, 30);
    self.button.bmx_right = MAXScreenW - avatarLeft;
    [self layoutIfNeeded];
}


- (void)layoutSubviews {
    [super layoutSubviews];
    self.avatarImg.bmx_centerY = self.contentView.bmx_centerY;
    self.contentLabel.bmx_centerY = self.avatarImg.bmx_centerY;
    self.button.bmx_centerY = self.avatarImg.bmx_centerY;
    [self.nicknameLabel sizeToFit];
    [self.infoLabel sizeToFit];

}

- (UIImageView *)avatarImg {
    if (!_avatarImg) {
        _avatarImg = [[UIImageView alloc] init];
        [self addSubview:_avatarImg];
        [_avatarImg sizeToFit];
    }
    return _avatarImg;
}

- (UILabel *)nicknameLabel {
    if (!_nicknameLabel) {
        _nicknameLabel = [[UILabel alloc] init];
        _nicknameLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:16];
        _nicknameLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1/1.0];        [self addSubview:_nicknameLabel];
        [_nicknameLabel sizeToFit];
    }
    return _nicknameLabel;
}

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:16];
        _contentLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1/1.0];        [self addSubview:_contentLabel];
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
        [_button setTitle:@"添加好友" forState:UIControlStateNormal];
        [_button addTarget:self action:@selector(clickAccept:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_button];
        [_button sizeToFit];
    }
    return _button;
}

- (UILabel *)infoLabel {
    if (!_infoLabel) {
        _infoLabel = [[UILabel alloc] init];
        _infoLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:12];
        _infoLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1/1.0];
        [self addSubview:_infoLabel];
        [_infoLabel sizeToFit];
//        _infoLabel.text = @"0000000000";
    }
    return _infoLabel;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
