//
//  ImageAlertView.h
//  MaxIM
//
//  Created by 韩雨桐 on 2019/5/25.
//  Copyright © 2019 hyt. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^SendBtnClickBlock)(void);

@interface ImageAlertView : UIView

@property (nonatomic, copy) SendBtnClickBlock btnClickBlock;

- (void)setAvarat:(UIImage *)avarat
         nickName:(NSString *)nickName
       contentImg:(UIImage *)contentImg;

@end

NS_ASSUME_NONNULL_END
