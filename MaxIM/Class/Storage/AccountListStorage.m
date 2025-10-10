//
//  AccountListStorage.m
//  MaxIM
//
//  Created by 韩雨桐 on 2019/12/17.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "AccountListStorage.h"
#import "IMAcount.h"

@implementation AccountListStorage

+ (NSString *)modelPath {
    return [NSString stringWithFormat:@"AccountListStorage"];
}

+ (void)removeAccount:(IMAcount *)account {
    NSArray * array = [NSArray arrayWithArray:  [AccountListStorage loadObject]];

    for (IMAcount *model  in array) {
        if ([account.usedId isEqualToString:model.usedId]) {
            NSMutableArray *arrM = [NSMutableArray arrayWithArray:array];
            [arrM removeObject:model];
            [AccountListStorage saveObject:[NSArray arrayWithArray:arrM]];
        }
    }
}

@end
