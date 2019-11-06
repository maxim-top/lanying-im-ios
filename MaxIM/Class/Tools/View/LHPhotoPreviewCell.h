//
//  LHPhotoPreviewCell.h
//  LHChatUI
//
//  Created by hyt on 2016/12/28.
//  Copyright © 2016年 hyt. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BMXMessageObject;

@interface LHPhotoPreviewCell : UICollectionViewCell

@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, copy) void (^singleTapGestureBlock)(CGRect imageRect);
@property (nonatomic, copy) void (^longPressGestureBlock)(UIImage *image);

- (void)recoverSubviews;
- (void)setImageUrlWith:(BMXMessageObject *)messagemodel;
@end
