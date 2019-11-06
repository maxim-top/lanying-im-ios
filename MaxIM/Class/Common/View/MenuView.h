//
//  MenuView.h
//  MaxIM
//
//  Created by 韩雨桐 on 2019/10/12.
//  Copyright © 2019 hyt. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MenuViewDeleagte <NSObject>

- (void)menuViewDidSelectbutton:(UIButton *)button;

@end

@interface MenuView : UIView


@property (nonatomic,assign) id<MenuViewDeleagte> delegate;

- (instancetype)initWithFrame:(CGRect)frame buttonArray:(NSArray *)array;

- (void)hide;

@end

NS_ASSUME_NONNULL_END
