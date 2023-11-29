
//
//  ImageTitleBasicTableViewCell.m
//  MaxIM
//
//  Created by 韩雨桐 on 2018/12/15.
//  Copyright © 2018 hyt. All rights reserved.
//

#import "ImageTitleBasicTableViewCell.h"
#import "UIView+BMXframe.h"
#import <floo-ios/floo_proxy.h>

static NSString *cellID = @"ImageTitleBasicTableViewCell";

@implementation ImageTitleBasicTableViewCell

+ (instancetype)ImageTitleBasicTableViewCellWith:(UITableView *)tableView {
    ImageTitleBasicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier  {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (void)refreshByTitle:(NSString *)titlel {
    self.nicknameLabel.text = titlel;
    
    self.avatarImg.layer.borderWidth = 0.5;
    self.avatarImg.layer.borderColor = kColorC4_5.CGColor;
    
    if ([titlel isEqualToString:NSLocalizedString(@"Friend_request_and_notification", @"好友申请与通知")]) {
        self.avatarImg.image = [UIImage imageNamed:@"application"];
        self.avatarImg.layer.borderWidth = 0;
        self.avatarImg.layer.borderColor = [UIColor clearColor].CGColor;
        
    } else if  ([titlel isEqualToString:NSLocalizedString(@"Group_application_and_notification", @"群申请与通知")] || [titlel isEqualToString:NSLocalizedString(@"System_message_of_group_chat", @"群聊系统消息")]) {
        self.avatarImg.image = [UIImage imageNamed:@"application"];
        self.avatarImg.layer.borderWidth = 0;
        self.avatarImg.layer.borderColor = [UIColor clearColor].CGColor;
        
    } else {
        self.avatarImg.image = [UIImage imageNamed:@"group"];
    }

    

}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat avatarLeft = 15;
    CGFloat nickNameleft = 10;
    CGFloat top = 10;
    
    UIImage *image = [UIImage imageNamed:@"contact_placeholder"];
    self.avatarImg.bmx_left = avatarLeft;
    self.avatarImg.bmx_size = CGSizeMake(image.size.width, image.size.height);
    self.avatarImg.bmx_centerY = self.contentView.bmx_centerY;
    
    self.nicknameLabel.bmx_left = nickNameleft + self.avatarImg.bmx_right;
    self.nicknameLabel.size = CGSizeMake(MAXScreenW - nickNameleft * 2  - self.nicknameLabel.bmx_left , 40);
    self.nicknameLabel.bmx_top = top;
    
    self.line.bmx_size = CGSizeMake(MAXScreenW - 40 - 35, 0.5);
    self.line.bmx_left = self.avatarImg.bmx_right + 5;
    self.line.bmx_right = MAXScreenW;
    self.line.bmx_bottom = 60 - 0.5;
}

- (void)refresh:(BMXRosterItem *)roster {
    
    self.avatarImg.image = [UIImage imageNamed:@"contact_placeholder"];
    self.avatarImg.layer.borderWidth = 0.5;
    self.avatarImg.layer.borderColor = kColorC4_5.CGColor;
    
    self.nicknameLabel.text = [[roster nickname] length] ?  roster.nickname : roster.username;
    
    UIImage *image = [UIImage imageWithContentsOfFile:roster.avatarThumbnailPath];
    if (!image) {
        [[[BMXClient sharedClient] rosterService] downloadAvatarWithItem:roster thumbnail:YES callback:^(int progress){} completion:^(BMXError *error) {
            if (error.errorCode == BMXErrorCode_NoError) {
                UIImage *image = [UIImage imageWithContentsOfFile:roster.avatarThumbnailPath];
                MAXLog(@"%@", roster.avatarThumbnailPath);
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.avatarImg.image = image;
                });
            }
        }];
    }else {
        self.avatarImg.image = image;
    }
    
}

- (void)refreshSupportRoster:(BMXRosterItem *)roster {
    
    self.avatarImg.image = [UIImage imageNamed:@"contact_placeholder"];
    self.avatarImg.layer.borderWidth = 0.5;
    self.avatarImg.layer.borderColor = kColorC4_5.CGColor;
    
    self.nicknameLabel.text = [[roster nickname] length] ?  roster.nickname : roster.username;
    
    [[[BMXClient sharedClient] rosterService] downloadAvatarWithItem:roster thumbnail:YES callback:^(int progress){}completion:^(BMXError *error) {
        if (!error) {
            UIImage *image = [UIImage imageWithContentsOfFile:roster.avatarThumbnailPath];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.avatarImg.image = image;
            });
        } else {
            self.avatarImg.image = [UIImage imageNamed:@"contact_placeholder"];
        }
    }];
}

- (void)refreshByGroup:(BMXGroup *)group {
    
    self.avatarImg.image = [UIImage imageNamed:@"group_placeHo"]; 
    self.nicknameLabel.text = group.name;
    
    if (group.avatarThumbnailPath > 0 && [[NSFileManager defaultManager] fileExistsAtPath:group.avatarThumbnailPath]) {
        self.avatarImg.image = [UIImage imageWithContentsOfFile:group.avatarThumbnailPath];
    }else {
        [[[BMXClient sharedClient] groupService] downloadAvatarWithGroup:group thumbnail:YES callback:^(int progress){} completion:^(BMXError *error) {
            if (!error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImage *image = [UIImage imageWithContentsOfFile:group.avatarThumbnailPath];
                    self.avatarImg.image = image;
                    
                });
            }
        }];
    }
}


- (void)setupUI {
    CGFloat avatarLeft = 15;
    CGFloat nickNameleft = 10;
    CGFloat top = 10;
    
    UIImage *image = [UIImage imageNamed:@"contact_placeholder"];
    self.avatarImg.bmx_left = avatarLeft;
    self.avatarImg.bmx_size = CGSizeMake(image.size.width, image.size.height);
    self.avatarImg.bmx_centerY = self.contentView.bmx_centerY;
    
    self.nicknameLabel.bmx_left = nickNameleft + self.avatarImg.bmx_right;
    self.nicknameLabel.size = CGSizeMake(MAXScreenW - nickNameleft * 2  - self.nicknameLabel.bmx_left, 40);
    self.nicknameLabel.bmx_top = top;
    
    
    self.line.bmx_size = CGSizeMake(MAXScreenW - 40 - 35, 0.2);
    self.line.bmx_left = self.avatarImg.bmx_right + 5;
    self.line.bmx_right = MAXScreenW;
    self.line.bmx_bottom = self.avatarImg.bmx_bottom + 10;
}

- (UIImageView *)avatarImg {
    if (!_avatarImg) {
        _avatarImg = [[UIImageView alloc] init];
        UIImage *image = [UIImage imageNamed:@"contact_placeholder"];
        
        self.avatarImg.layer.borderWidth = 0.5;
        self.avatarImg.layer.borderColor = kColorC4_5.CGColor;

        self.avatarImg.clipsToBounds = YES;
        self.avatarImg.layer.cornerRadius = image.size.width / 2.0;
        [self.contentView addSubview:_avatarImg];
        [_avatarImg sizeToFit];
    }
    return _avatarImg;
}

- (UILabel *)nicknameLabel {
    if (!_nicknameLabel) {
        _nicknameLabel = [[UILabel alloc] init];

        _nicknameLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:16];
        _nicknameLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1/1.0];
        [self.contentView addSubview:_nicknameLabel];
    }
    return _nicknameLabel;
}


- (UIView *)line {
    if (!_line) {
        _line = [[UIView alloc] init];
        [self.contentView addSubview:_line];
        _line.backgroundColor = kColorC4_5;
    }
    return _line;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
@end
