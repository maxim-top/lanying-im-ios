//
//  ImageTitleBasicTableViewCell.h
//  MaxIM
//
//  Created by 韩雨桐 on 2018/12/15.
//  Copyright © 2018 hyt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <floo-ios/floo_proxy.h>

@class BMXRoster;
@class BMXGroup;

NS_ASSUME_NONNULL_BEGIN

@interface ImageTitleBasicTableViewCell : UITableViewCell

@property (nonatomic, strong) UIImageView *avatarImg;
@property (nonatomic, strong) UILabel *nicknameLabel;

@property (nonatomic, strong) UIView *line;

- (void)refreshByTitle:(NSString *)titlel;
- (void)refresh:(BMXRosterItem *)roster;
- (void)refreshByGroup:(BMXGroup *)group;
- (void)refreshSupportRoster:(BMXRosterItem *)roster;
+ (instancetype)ImageTitleBasicTableViewCellWith:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_END
