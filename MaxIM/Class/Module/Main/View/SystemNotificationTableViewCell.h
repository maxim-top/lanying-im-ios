//
//  SystemNotificationTableViewCell.h
//  MaxIM
//
//  Created by 韩雨桐 on 2019/10/24.
//  Copyright © 2019 hyt. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SystemNotificationTableViewCell : UITableViewCell

@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UILabel *timeLabel;

+ (instancetype)cellWithTableview:(UITableView *)tableview;

@end

NS_ASSUME_NONNULL_END
