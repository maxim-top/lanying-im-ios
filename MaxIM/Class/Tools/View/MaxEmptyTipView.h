//
//  MaxEmptyTipView.h
//  MaxIM
//
//  Created by 韩雨桐 on 2019/11/6.
//  Copyright © 2019 hyt. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    MaxEmptyTipTypeCommonBlank,
    MaxEmptyTipTypeContactSupport,
    MaxEmptyTipTypeBlocklist
} MaxEmptyTipType;

@interface MaxEmptyTipView : UIView

- (instancetype)initWithFrame:(CGRect)frame type:(MaxEmptyTipType)type;

@end

NS_ASSUME_NONNULL_END
