//
//  SettingTableView.h
//  BlockMessage
//
//  Created by hyt on 2018/7/22.
//  Copyright © 2018年 HYT. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BMXUserProfile;
@interface SettingTableView : UITableView

@property (nonatomic, strong) NSArray *cellDataArray;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *nameLabel;


- (void)refeshProfile:(BMXUserProfile *)profile;
@end
