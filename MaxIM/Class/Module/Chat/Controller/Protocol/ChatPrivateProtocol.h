

//
//  ChatPrivateProtocol.h
//  MaxIM
//
//  Created by 韩雨桐 on 2019/7/23.
//  Copyright © 2019 hyt. All rights reserved.
//

#ifndef ChatPrivateProtocol_h
#define ChatPrivateProtocol_h


#endif /* ChatPrivateProtocol_h */


@protocol ChatDataSource <NSObject>

- (void)loadHistoryMessagesWithComplete:(void(^)(NSInteger index, NSArray *messages , NSError *error))handler;




@end
