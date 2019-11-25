//
//  ChatTableViewAdapter.h
//  MaxIM
//
//  Created by 韩雨桐 on 2019/7/24.
//  Copyright © 2019 hyt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <floo-ios/BMXMessageObject.h>


NS_ASSUME_NONNULL_BEGIN

@interface ChatTableViewAdapter : NSObject

@property (nonatomic, strong) NSArray *dataSource;

@property (nonatomic, strong) UIImage *selfImage;

@property (nonatomic,assign) BOOL isMeetRefresh;

@property (nonatomic,assign) BMXMessageType messageType;


@end

NS_ASSUME_NONNULL_END
