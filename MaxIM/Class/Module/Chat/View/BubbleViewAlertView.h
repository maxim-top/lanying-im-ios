//
//  BubbleViewAlertView.h
//  MaxIM
//
//  Created by 韩雨桐 on 2019/3/28.
//  Copyright © 2019 hyt. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BubbleViewAlertView : UIView

+ (instancetype)bubbleViewAlertViewWithButtonArray:(NSArray *)array isSender:(BOOL)isSender;

- (void)showAlertViewWithView:(UIView *)view;
- (void)hiddenAlertView;



@end

NS_ASSUME_NONNULL_END
