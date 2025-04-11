//
//  MainVCTableViewController.h
//  LHChatUI
//
//  Created by hyt on 2016/12/22.
//  Copyright © 2016年 hyt. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <floo-ios/floo_proxy.h>

@interface MainViewController : UIViewController

//@property (nonatomic, assign) BOOL conversationFinish;

- (void)getAllConversations;

- (void)updateConversationWithRosterItem:(BMXRosterItem *)roster;

- (void)receiveNewMessage:(BMXMessage *)message;

- (void)receiveRTCCallMessage:(BMXMessage *)message;

- (void)sendNewMessage:(BMXMessage *)message;


@end
