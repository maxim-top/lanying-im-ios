//
//  ----------------------------------------------------------------------
//   File    :  GroupBaseController.m
//   Author  : shaohui.yang shaohui@bmxlabs.com
//   Purpose :
//   Created : 2018/12/27 by shaohui.yang shaohui@bmxlabs.com
//
//  ----------------------------------------------------------------------
//
//                    Copyright (C) 2018-2019   MaxIM.Top
//
// You may obtain a copy of the licence at http://www.maxim.top/LICENCE-MAXIM.md
//
//  ----------------------------------------------------------------------
    

#import "GroupBaseController.h"

#import <floo-ios/floo_proxy.h>

#import "IMAcountInfoStorage.h"
#import "IMAcount.h"

@interface GroupBaseController ()

@end

@implementation GroupBaseController

- (instancetype)initWithGroup:(BMXGroup *)group hideMemberInfo:(BOOL)hideMemberInfo {
    if (self = [super init]) {
        self.group = group;
        self.hideMemberInfo = hideMemberInfo;
        MAXLog(@"%lld", self.group.groupId);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];

}

- (BOOL) isOwner
{
    NSString* ownerStr = [NSString stringWithFormat:@"%ld", self.group.ownerId] ;
    IMAcount* acc = [IMAcountInfoStorage loadObject];
    NSString* currentAccId = acc.usedId;
    return [ownerStr isEqualToString:currentAccId];
}

- (BOOL) isSelf:(NSString*) compareId
{
    IMAcount* acc = [IMAcountInfoStorage loadObject];
    NSString* currentAccId = acc.usedId;
    return [compareId isEqualToString:currentAccId];
}



@end
