//
//  AppDelegate+PushService.m
//  MaxIM
//
//  Created by 韩雨桐 on 2020/8/25.
//  Copyright © 2020 hyt. All rights reserved.
//

#import "AppDelegate+PushService.h"

@implementation AppDelegate (PushService)

- (void)registerAPNs {
//    [[[BMXClient sharedClient] pushService] start];
//    [[[BMXClient sharedClient] pushService] addDelegate:self];
    
    
//    [[[BMXClient sharedClient] pushService] setBadge:10];


//
//    [[[BMXClient sharedClient] pushService] getToken];
//
//    [[[BMXClient sharedClient] pushService] getCertification];
//
//
//    [[[BMXClient sharedClient] pushService] setTags:@[@"testtag"] operationId:@"123456"];
//    [[[BMXClient sharedClient] pushService] getTagsByOperationId:@"123456" withCompletion:^(NSArray *tags, BMXError *error) {
//        MAXLog(@"%@", error);
//    }];
//
//
//    [[[BMXClient sharedClient] pushService] deleteTags:@[@"testtag"] operationId:@"1"];
//
//    [[[BMXClient sharedClient] pushService] clearTagsByOperationId:@"1"];
    
//    [[[BMXClient sharedClient] pushService] setSlienceTimeStartHour:8 endHour:18];
}


- (void)pushMessageStatusChanged:(BMXMessage *)message error:(BMXError *)error {
    MAXLog(@"%@", message.content);
}

- (void)pushStartDidFinished:(NSString *)bmxToken {
    MAXLog(@"%@", bmxToken);

}

- (void)certRetrieved:(NSString *)certification {
    MAXLog(@"%@", certification);  // 如果SDKconfig已配置证书，就不会执行该回调
}


- (void)setTagsDidFinished:(NSString *)operationId {
    MAXLog(@"%@", operationId);
}

- (void)getTagsDidFinished:(NSString *)operationId {
    MAXLog(@"%@", operationId);
}

- (void)deleteTagsDidFinished:(NSString *)operationId {
    MAXLog(@"%@", operationId);
}

- (void)clearedTags:(NSString *)operationId {
    MAXLog(@"%@", operationId);
}

- (void)receivedPush:(NSArray<BMXMessage *> *)messages {

}



@end
