//
//  TitleSwitchTableViewCell.h
//  MaxIM
//
//  Created by hyt on 2018/12/30.
//  Copyright © 2018年 hyt. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TitleSwitchTableViewCell;
NS_ASSUME_NONNULL_BEGIN

@protocol TitleSwitchTableViewCellDelegate <NSObject>

- (void)cellDidchangeSwitchStatus:(UISwitch *)mswtich cell:(TitleSwitchTableViewCell *)cell;

@end

@interface TitleSwitchTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UISwitch *mswitch;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic,weak) id<TitleSwitchTableViewCellDelegate> delegate;
+ (instancetype)cellWithTableView:(UITableView *)tableview;


@end

NS_ASSUME_NONNULL_END
