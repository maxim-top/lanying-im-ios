//  ************************************************************************
//
//  MAXUtils.m
//  MaxIMDemo
//
//  Created by hyt on 2022/9/2.
//  ----------------------------------------------------------------------
//
//                    Copyright (C) 2018-2022   MaxIM.Top
//
// You may obtain a copy of the licence at http://www.maxim.top/LICENCE-MAXIM.md
//
//  ----------------------------------------------------------------------

#import "MAXUtils.h"
@interface MAXUtils ()
@end

@implementation MAXUtils

+ (void)getAllRosterIdsWithCompletion:(void (^)(ListOfLongLong *list)) resBlock {
    if (resBlock) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            ListOfLongLong *ids = [[ListOfLongLong alloc] init];
            [[[BMXClient sharedClient] rosterService] get: ids forceRefresh:YES];
            dispatch_async(dispatch_get_main_queue(), ^{
                resBlock(ids);
            });
        });
    }
}

+ (void)getAllRosterWithCompletion:(void (^)(NSArray *arr)) resBlock {
    if (resBlock) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSMutableArray *arr = [[NSMutableArray alloc] init];
            BMXRosterItemList* list = [[BMXRosterItemList alloc] init];
            ListOfLongLong *ids = [[ListOfLongLong alloc] init];
            BMXErrorCode err = [[[BMXClient sharedClient] rosterService] get: ids forceRefresh:YES];
            if (!err) {
                err = [[[BMXClient sharedClient] rosterService] searchWithRosterIdList:ids list:list forceRefresh:YES];
                if (!err) {
                    unsigned long sz = list.size;
                    MAXLog(@"%ld", sz);
                    for (int i=0; i<sz; i++) {
                        [arr addObject:[list get: i]];
                    }
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                resBlock(arr);
            });
        });
    }
}

+ (void)getMemberIdsWithGroup: (BMXGroup *) group completion:(void (^)(ListOfLongLong *list)) resBlock {
    if (resBlock) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            BMXGroupMemberList* list = [[BMXGroupMemberList alloc] init];
            ListOfLongLong *res = [[ListOfLongLong alloc] init];
            BMXErrorCode err = [[[BMXClient sharedClient] groupService] getMembers:group list:list forceRefresh:YES];
            if (!err){
                unsigned long sz = list.size;
                MAXLog(@"%ld", sz);
                for (int i=0; i<sz; i++) {
                    BMXGroupMember *member = [list get: i];
                    long long uid = [member getMUid];
                    [res addWithX: &uid];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                resBlock(res);
            });
        });
    }
}

+ (void)getMemberIdArrayWithGroup: (BMXGroup *) group completion:(void (^)(NSArray *arr)) resBlock {
    if (resBlock) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            BMXGroupMemberList* list = [[BMXGroupMemberList alloc] init];
            NSMutableArray * arr = [[NSMutableArray alloc] init];
            BMXErrorCode err = [[[BMXClient sharedClient] groupService] getMembers:group list:list forceRefresh:YES];
            if (!err){
                unsigned long sz = list.size;
                MAXLog(@"%ld", sz);
                for (int i=0; i<sz; i++) {
                    BMXGroupMember *member = [list get: i];
                    long long uid = [member getMUid];
                    NSString* sUid = [NSString stringWithFormat:@"%lld", uid];
                    [arr addObject:sUid];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                resBlock(arr);
            });
        });
    }
}

+ (void)getRostersByidArray:(ListOfLongLong *)idList completion:(void (^)(NSArray *arr)) resBlock {
    if (resBlock) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            BMXRosterItemList* rosterItems = [[BMXRosterItemList alloc] init];
            NSMutableArray* arr = [NSMutableArray array];
            BMXErrorCode err = [[[BMXClient sharedClient] rosterService] searchWithRosterIdList:idList list:rosterItems forceRefresh:NO];
            if (!err){
                unsigned long sz = rosterItems.size;
                MAXLog(@"%ld", sz);
                for (int i=0; i<sz; i++) {
                    BMXRosterItem *item = [rosterItems get: i];
                    [arr addObject:item];
                }
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                resBlock(arr);
            });
        });
    }
}


@end
