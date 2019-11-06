//
//  ----------------------------------------------------------------------
//   File    :  RecentConversaionTableViewCell.h
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
    

#import <UIKit/UIKit.h>
@class BMXConversation;

NS_ASSUME_NONNULL_BEGIN

@interface RecentConversaionTableViewCell : UITableViewCell

@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIImageView *recordImageview;
@property (nonatomic, strong) UILabel *dotLabel;
@property (nonatomic, strong) UIImageView *dotView;

+ (instancetype)cellWithTableview:(UITableView *)tableview;
- (void)refreshByConversation:(BMXConversation *)conversationd;
- (void)updateDotFrame;

@end

NS_ASSUME_NONNULL_END
