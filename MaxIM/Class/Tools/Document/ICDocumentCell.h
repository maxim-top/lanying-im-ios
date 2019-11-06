//
//  ICDocumentCell.h
//  XZ_WeChat
//
//  Created by hyt on 16/7/22.
//  Copyright © 2016年 gxz All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol ICDocumentCellDelegate <NSObject>

- (void)selectBtnClicked:(id)sender;

@end

@interface ICDocumentCell : UITableViewCell

@property (nonatomic, assign) CGFloat leftFreeSpace; // 低线的左边距

@property (nonatomic, assign) CGFloat rightFreeSpace;

@property (nonatomic, weak) UIView *bottomLine;


@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *filePath;

@property (nonatomic, weak) id<ICDocumentCellDelegate> delegate;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@property (nonatomic, weak) UIButton *selectBtn;



@end
