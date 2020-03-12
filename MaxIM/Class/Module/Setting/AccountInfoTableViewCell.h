//
//  AccountInfoTableViewCell.h
//  MaxIM
//
//  Created by 韩雨桐 on 2019/12/18.
//  Copyright © 2019 hyt. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AccountInfoTableViewCell : UITableViewCell


@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UIImageView *selectImageView;

+ (instancetype)cellWithTableView:(UITableView *)tableview;

- (void)reload:(NSString *)title subtitle:(NSString *)subtitle;



@end

NS_ASSUME_NONNULL_END
