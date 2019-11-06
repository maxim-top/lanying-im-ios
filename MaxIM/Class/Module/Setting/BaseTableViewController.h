//
//  BaseTableViewController.h
//  MaxIM
//
//  Created by hyt on 2018/11/22.
//  Copyright © 2018年 hyt. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BaseTableViewController : UIViewController

@property (nonatomic, strong) UITableView *tablview;
@property (nonatomic,copy) NSArray *celldataArray;
@property (nonatomic, strong) NSArray *sectionDataArray;


@end

NS_ASSUME_NONNULL_END
