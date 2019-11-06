//
//  ----------------------------------------------------------------------
//   File    :  DeviceTableViewCell.h
//   Author  : HYT yutong@bmxlabs.com
//   Purpose :
//   Created : 2019/2/2 by HYT yutong@bmxlabs.com
//
//  ----------------------------------------------------------------------
//
//                    Copyright (C) 2018-2019   MaxIM.Top
//
// You may obtain a copy of the licence at http://www.maxim.top/LICENCE-MAXIM.md
//
//  ----------------------------------------------------------------------
    

#import <UIKit/UIKit.h>
@class BMXDevice;
NS_ASSUME_NONNULL_BEGIN

@protocol DeviceTableViewCellDelegate <NSObject>

- (void)deviceTableViewCelldidClickButtonWithDevice:(BMXDevice *)device;

@end

@interface DeviceTableViewCell : UITableViewCell


+ (instancetype)cellWithTableView:(UITableView *)tableview;

@property (nonatomic, strong) BMXDevice *device;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic,weak) id<DeviceTableViewCellDelegate> delegate;

- (void)hiddenDeleteButton:(BOOL)deleteButton;


@end

NS_ASSUME_NONNULL_END
