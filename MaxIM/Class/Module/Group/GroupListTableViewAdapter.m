//
//  GroupListTableViewAdapter.m
//  MaxIM
//
//  Created by 韩雨桐 on 2019/9/27.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "GroupListTableViewAdapter.h"
#import "BMXClient.h"
#import "BMXGroup.h"
@implementation GroupListTableViewAdapter

+ (void)getGroupListcompletion:(void(^)(NSArray <BMXGroup *>*group, NSString *errmsg))aCompletionBlock {
    [[[BMXClient sharedClient] groupService] getGroupListForceRefresh:NO completion:^(NSArray *groupList, BMXError *error) {
        //        MAXLog(@"%ld", groupList.count);
        [HQCustomToast hideWating];
        
        if (!error) {
            
            NSMutableArray *groupNormalArray = [NSMutableArray array];
            for (BMXGroup *group in groupList) {
                //                MAXLog(@"%@", group.name);
                //                MAXLog(@"%d", group.groupStatus);
                //                MAXLog(@"%d", group.isMember);
                
                if (group.groupStatus != BMXGroupDestroyed && group.isMember == YES) {
                    [groupNormalArray addObject:group];
                } else {
                    //                    MAXLog(@"%lld", group.groupId);
                }
            }
            return aCompletionBlock(groupNormalArray, nil);

        } else {
            return aCompletionBlock(nil, error.errorMessage);
        }
    }];
}

+ (NSArray *)tableViewCellArray {
    return @[@"群聊系统消息"];
}
@end
