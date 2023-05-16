//
//  LHChatVC.h
//  LHChatUI
//
//  Created by hyt on 2016/12/22.
//  Copyright © 2016年 hyt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <floo-ios/floo_proxy.h>

@protocol ChatVCDelegate <NSObject>

- (void)chatVCDidSelectReturnButton;

@end

@interface LHChatVC : UIViewController

- (instancetype)initWithRoster:(BMXRosterItem *)roster
                   messageType:(BMXMessage_MessageType)messageType;

- (instancetype)initWithConversationId:(long long)conversationId
                   messageType:(BMXMessage_MessageType)messageType;

- (instancetype)initWithGroupChat:(BMXGroup *)group
                      messageType:(BMXMessage_MessageType)messageType;

@property (nonatomic,weak) id<ChatVCDelegate> delegate;



@end
