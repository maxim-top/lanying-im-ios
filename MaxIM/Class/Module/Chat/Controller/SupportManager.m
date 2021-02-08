//
//  SupportManager.m
//  MaxIM
//
//  Created by 韩雨桐 on 2020/5/27.
//  Copyright © 2020 hyt. All rights reserved.
//

#import "SupportManager.h"
#import "SupportStaffApi.h"
#import <floo-ios/BMXClient.h>
#import <floo-ios/BMXRoster.h>

@interface SupportManager ()

@property (nonatomic, strong) NSArray *supportArray;
@property (nonatomic,copy) NSString *currentuserid;

@end

@implementation SupportManager

+ (id)sharedSupportManager {
    static SupportManager *supportManger;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        supportManger = [[SupportManager alloc] init];
    });
    
    return supportManger;
    
}

- (void)checkCurrentRoster:(BMXRoster *)roster
                 isSupport:(IsSupportBlock)isSupportBlock {
    self.isSupportBlock = isSupportBlock;
    self.currentuserid = [NSString stringWithFormat:@"%lld", roster.rosterId];
    [self getSupportData];
}


- (void)getSupportData {
    SupportStaffApi *api  = [[SupportStaffApi alloc] init];
    [api startWithSuccessBlock:^(ApiResult * _Nullable result) {
        MAXLog(@"aaaaaaaaa");
        if (result.isOK) {
            NSMutableArray *idArrayM = [NSMutableArray array];
            for (NSDictionary *dic in result.resultData) {
                [idArrayM addObject:[NSString stringWithFormat:@"%@", dic[@"user_id"]]];
            }
            
            self.supportArray = idArrayM;
            
            BOOL isSupport = NO;
            for (NSString *user_id in self.supportArray) {
                if ([user_id isEqualToString:self.currentuserid]) {
                    
                    isSupport = YES;
                    break;
                }
            }
            if (self.isSupportBlock) {
                self.isSupportBlock(isSupport);
            }

        }
    } failureBlock:^(NSError * _Nullable error) {
        if (self.isSupportBlock) {
            self.isSupportBlock(NO);
        }
    }];
}

- (void)getSupportListProfileWithArray:(NSArray *)array {
    [[[BMXClient sharedClient] rosterService] searchRostersByRosterIdList:array forceRefresh:NO completion:^(NSArray<BMXRoster *> *rosterList, BMXError *error) {
        if (!error) {
            self.supportArray = rosterList;
        }
    }];
    
}

- (NSArray *)supportArray {
    if (!_supportArray) {
        _supportArray =[NSArray array];
    }
    return _supportArray;
}

@end
