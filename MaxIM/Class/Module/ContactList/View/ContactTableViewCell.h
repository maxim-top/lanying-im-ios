//
//  ----------------------------------------------------------------------
//   File    :  ContactTableViewCell.h
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
    

#import <UIKit/UIKit.h>
#import <floo-ios/floo_proxy.h>

@class BMXRoster;

@interface ContactTableViewCell : UITableViewCell

@property (nonatomic, strong) UIImageView *avatarImg;
@property (nonatomic, strong) UILabel *nicknameLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UILabel *infoLabel;
@property(nonatomic, strong) BMXRosterItem *contact;

+ (instancetype)contactTableViewCellWith:(UITableView *)tableView;

- (void)refresh:(BMXRosterItem *)contact;
- (void)refreshByTitle:(NSString *)titlel;


@end
