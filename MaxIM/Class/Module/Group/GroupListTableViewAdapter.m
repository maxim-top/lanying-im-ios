//
//  GroupListTableViewAdapter.m
//  MaxIM
//
//  Created by 韩雨桐 on 2019/9/27.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "GroupListTableViewAdapter.h"
#import <floo-ios/floo_proxy.h>

@implementation GroupListTableViewAdapter

+ (void)getGroupListcompletion:(void(^)(NSArray <BMXGroup *>*group, NSString *errmsg))aCompletionBlock {
    [[[BMXClient sharedClient] groupService] get:YES completion:^(BMXGroupList *res, BMXError *error) {
        //        MAXLog(@"%ld", groupList.count);
        [HQCustomToast hideWating];
        
        if (!error) {
            NSMutableArray *groupNormalArray = [NSMutableArray array];
            unsigned long sz = res.size;
            for (int i=0; i<sz; i++) {
                BMXGroup *group = [res get:i];
                if (group.groupStatus != BMXGroup_GroupStatus_Destroyed && group.isMember) {
                    [groupNormalArray addObject:group];
                }
            }
            return aCompletionBlock(groupNormalArray, nil);
        } else {
            [[[BMXClient sharedClient] groupService] get:NO completion:^(BMXGroupList *res, BMXError *error) {
                if (!error) {
                    NSMutableArray *groupNormalArray = [NSMutableArray array];
                    unsigned long sz = res.size;
                    for (int i=0; i<sz; i++) {
                        BMXGroup *group = [res get:i];
                        if (group.groupStatus != BMXGroup_GroupStatus_Destroyed && group.isMember) {
                            [groupNormalArray addObject:group];
                        }
                    }
                    return aCompletionBlock(groupNormalArray, nil);
                }else{
                    return aCompletionBlock(nil, [error description]);
                }
            }];
        }
    }];
}

+ (NSArray *)tableViewCellArray {
    return @[NSLocalizedString(@"System_message_of_group_chat", @"群聊系统消息")];
}
@end
