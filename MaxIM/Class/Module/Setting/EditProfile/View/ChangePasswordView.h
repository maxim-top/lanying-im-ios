//
//  ChangePasswordView.h
//  MaxIM
//
//  Created by 韩雨桐 on 2020/4/19.
//  Copyright © 2020 hyt. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^ChangePwdBlock)(NSString *newPassword);

@interface ChangePasswordView : UIView

@property (nonatomic, copy) ChangePwdBlock changeBlock;

@end

NS_ASSUME_NONNULL_END
