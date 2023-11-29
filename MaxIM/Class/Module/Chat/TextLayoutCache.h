//
//  TextLayoutCache.h
//  MaxIM
//
//  Created by lhr on 2023/10/20.
//  Copyright © 2023 hyt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TextLayoutCacheNode.h"
#import "NSAttributedString+YYText.h"
#import "YYTextView.h"

NS_ASSUME_NONNULL_BEGIN
extern CGFloat const TEXTLABEL_MAX_WIDTH;

@interface TextLayoutCache : NSObject

@property (nonatomic, strong) NSMutableDictionary *cache;
@property (nonatomic, assign) NSUInteger capacity;
@property (nonatomic, strong) TextLayoutCacheNode *head;
@property (nonatomic, strong) TextLayoutCacheNode *tail;

+ (TextLayoutCache *)sharedInstance;

- (instancetype)initWithCapacity:(NSUInteger)capacity;
//- (id)objectForKey:(id)key;
//- (void)setObject:(id)object forKey:(id)key;
- (NSMutableAttributedString *)attributedStringForKey:(NSString *)key;
- (YYTextLayout *)layoutForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
