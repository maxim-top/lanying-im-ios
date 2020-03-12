//
//  VerifyPasswordView.h
//  MaxIM
//
//  Created by 韩雨桐 on 2019/12/5.
//  Copyright © 2019 hyt. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol VerifyPasswordProtocol <NSObject>

@optional

- (void)commitWithPassword:(NSString *)password;

@end


@interface VerifyPasswordView : UIView

@property (nonatomic, assign) id<VerifyPasswordProtocol> delegate;


- (instancetype)initWithFrame:(CGRect)frame
                    titleText:(NSString *)titleText
           continueButtonName:(NSString *)buttonName;

@end

NS_ASSUME_NONNULL_END
