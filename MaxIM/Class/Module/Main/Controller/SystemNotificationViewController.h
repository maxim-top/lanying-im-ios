//
//  SystemNotificationViewController.h
//  MaxIM
//
//  Created by 韩雨桐 on 2019/10/23.
//  Copyright © 2019 hyt. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BMXConversation;
@class BMXMessageObject;


NS_ASSUME_NONNULL_BEGIN

@interface SystemNotificationViewController : UIViewController

@property (nonatomic, strong) BMXConversation *conversation;
@property (nonatomic, strong) BMXMessageObject *message;
@property (nonatomic, strong) NSDictionary *profileDic;

@end

NS_ASSUME_NONNULL_END
