
//
//  ChatTableViewAdapter.m
//  MaxIM
//
//  Created by 韩雨桐 on 2019/7/24.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "ChatTableViewAdapter.h"
#import "LHChatTimeCell.h"
#import "LHMessageModel.h"
#import "LHChatViewCell.h"
#import <floo-ios/floo_proxy.h>

@interface ChatTableViewAdapter () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation ChatTableViewAdapter

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id obj = [self.dataSource objectAtIndex:indexPath.row];
    
    if ([obj isKindOfClass:[NSString class]]) {
        LHChatTimeCell *timeCell = (LHChatTimeCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([LHChatTimeCell class])];
        if (!timeCell) {
            timeCell = [[LHChatTimeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([LHChatTimeCell class])];
        }
        timeCell.timeLable.text = (NSString *)obj;
        return timeCell;
    }
    
    LHMessageModel *messageModel = (LHMessageModel *)obj;
    NSString *cellIdentifier = [LHChatViewCell cellIdentifierForMessageModel:messageModel];
    messageModel.indexPath = indexPath;
    LHChatViewCell *messageCell = (LHChatViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!messageCell) {
        messageCell = [[LHChatViewCell alloc] initWithMessageModel:messageModel hideMemberInfo:NO reuseIdentifier:cellIdentifier];
    }
    
    if (messageModel.isSender) {
        [messageCell setAvaratImage:self.selfImage];
        
        if (self.messageType == BMXMessage_MessageType_Single) {
            // 配置是否已读
            
            if (messageModel.messageObjc.isReadAcked == YES) {
                messageCell.readStatusLabel.text = NSLocalizedString(@"Read", @"已读");
            } else {
                messageCell.readStatusLabel.text = NSLocalizedString(@"Unread", @"未读");
            }
        }
        
    } else {
        __weak  LHChatViewCell *weakCell = messageCell;
        [[[BMXClient sharedClient] rosterService] searchWithRosterId:messageModel.messageObjc.fromId forceRefresh:NO completion:^(BMXRosterItem *roster, BMXError *error) {
            if (!error) {
                
                if ([[NSFileManager defaultManager] fileExistsAtPath:roster.avatarThumbnailPath]) {
                    UIImage *avarat = [UIImage imageWithContentsOfFile:roster.avatarThumbnailPath];
                    [weakCell setAvaratImage:avarat];
                }else {

                    [[[BMXClient sharedClient] rosterService] downloadAvatarWithItem:roster thumbnail:YES callback:^(int progress) {

                    } completion:^(BMXError *error) {
                        if (!error) {
                            UIImage *avarat = [UIImage imageWithContentsOfFile:roster.avatarThumbnailPath];
                            [weakCell setAvaratImage:avarat];
                        }else {
                            [weakCell setAvaratImage:nil];
                        }
                    }];
                }
            }
        }];
    }
    
    if (self.messageType == BMXMessage_MessageType_Group) {
        
        messageModel.isChatGroup = YES;
        
        __weak  LHChatViewCell *weakCell = messageCell;
        [[[BMXClient sharedClient] rosterService] searchWithRosterId:messageModel.messageObjc.fromId forceRefresh:NO completion:^(BMXRosterItem *item, BMXError *error) {
            if (!error) {
                messageModel.nickName = [item.nickname length] ? item.nickname : item.username;
                [weakCell setMessageName:messageModel.nickName];
            }
        }];
    } else {
        messageModel.isChatGroup = NO;
    }
    messageCell.messageModel = messageModel;
    MAXLog(@"%@",     messageCell.messageModel.content);
    return messageCell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSObject *obj = [self.dataSource objectAtIndex:indexPath.row];
    if ([obj isKindOfClass:[NSString class]]) {
        return 31;
    } else {
        LHMessageModel *model = (LHMessageModel *)obj;
        CGFloat height = [LHChatViewCell tableView:tableView heightForRowAtIndexPath:indexPath withObject:model];
        return height;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.isMeetRefresh) {
        return 40;
    }
    return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (!self.isMeetRefresh) return nil;
    UIView *refreshView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MAXScreenW, 40)];
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((MAXScreenW - 15) * 0.5, (20 - 15) * 0.5, 15, 15)];
    activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [activityIndicatorView startAnimating];
    [refreshView addSubview:activityIndicatorView];
    return refreshView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}


@end
