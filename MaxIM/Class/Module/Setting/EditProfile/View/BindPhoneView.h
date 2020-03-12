//
//  BIndPhoneView.h
//  MaxIM
//
//  Created by 韩雨桐 on 2019/12/4.
//  Copyright © 2019 hyt. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@protocol BindPhoneProtocol <NSObject>

@optional

- (void)sendChaptchaWithPhone:(NSString *)phone;

- (void)commitPhone:(NSString *)phone chptcha:(NSString *)chptcha;

@end

@interface BindPhoneView : UIView

@property (nonatomic, assign) id<BindPhoneProtocol> delegate;


- (instancetype)initWithFrame:(CGRect)frame
                   needTitle:(BOOL)needTitle
                    titleText:(NSString *)titleText;

- (void)setPhoneNum:(NSString *)phoneNum;

@end

NS_ASSUME_NONNULL_END
