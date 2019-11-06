//
//  LHMessageModel.m
//  LHChatUI
//
//  Created by hyt on 2016/12/26.
//  Copyright © 2016年 hyt. All rights reserved.
//

#import "LHMessageModel.h"

@implementation LHMessageModel

- (NSString *)id {
    if ([_id isKindOfClass:[NSString class]]) {
        return _id;
    } else if (!_id) {
        return nil;
    }
    return [NSString stringWithFormat:@"%@", _id];
}

@end
