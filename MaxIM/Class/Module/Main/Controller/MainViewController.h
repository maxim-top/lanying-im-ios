//
//  MainVCTableViewController.h
//  LHChatUI
//
//  Created by hyt on 2016/12/22.
//  Copyright © 2016年 hyt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <floo-ios/BMXMessageObject.h>

@interface MainViewController : UIViewController


- (void)getAllConversations;

- (void)receiveNewMessage:(BMXMessageObject *)message;

- (void)sendNewMessage:(BMXMessageObject *)message;

@end
