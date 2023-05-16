//
//  ContactTableView.h
//  MaxIM
//
//  Created by hyt on 2018/11/19.
//  Copyright © 2018年 hyt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <floo-ios/floo_proxy.h>

@class BMXRoster;
NS_ASSUME_NONNULL_BEGIN

@interface ContactTableView : UITableView

+ (instancetype)contactTableView;
- (void)refresh:(NSArray<BMXRosterItem *> *)array;

@end

NS_ASSUME_NONNULL_END
