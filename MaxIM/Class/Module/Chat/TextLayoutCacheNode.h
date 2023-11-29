//
//  TextLayoutCacheNode.h
//  MaxIM
//
//  Created by lhr on 2023/10/20.
//  Copyright © 2023 hyt. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TextLayoutCacheNode : NSObject

@property (nonatomic, strong) id key;
@property (nonatomic, strong) id value;
@property (nonatomic, strong) TextLayoutCacheNode *prev;
@property (nonatomic, strong) TextLayoutCacheNode *next;

@end

NS_ASSUME_NONNULL_END
