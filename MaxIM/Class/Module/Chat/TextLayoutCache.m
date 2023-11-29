//
//  TextLayoutCache.m
//  MaxIM
//
//  Created by lhr on 2023/10/20.
//  Copyright © 2023 hyt. All rights reserved.
//

#import "TextLayoutCache.h"
#import <MMMarkdown/MMMarkdown.h>
#import "LHMessageModel.h"
#import <CommonCrypto/CommonDigest.h>

@implementation TextLayoutCache

static TextLayoutCache *sharedInstance = nil;
static const int CACHE_CAPACITY = 100000;
CGFloat const TEXTLABEL_MAX_WIDTH = 260.0f;

+ (TextLayoutCache *)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] initWithCapacity:CACHE_CAPACITY];
    });
    return sharedInstance;
}

- (instancetype)initWithCapacity:(NSUInteger)capacity {
    self = [super init];
    if (self) {
        _cache = [NSMutableDictionary dictionary];
        _capacity = capacity;
        _head = [[TextLayoutCacheNode alloc] init];
        _tail = [[TextLayoutCacheNode alloc] init];
        _head.next = _tail;
        _tail.prev = _head;
    }
    return self;
}

- (void)moveNodeToHead:(TextLayoutCacheNode *)node {
    [node.prev setNext:node.next];
    [node.next setPrev:node.prev];
    [node setNext:self.head.next];
    [self.head setNext:node];
    [node setPrev:self.head];
    [node.next setPrev:node];
}

- (id)objectForKey:(id)key {
    TextLayoutCacheNode *node = self.cache[key];
    if (node) {
        [self moveNodeToHead:node];
        return node.value;
    } else {
        return nil;
    }
}

- (NSString *)MD5HashOfString:(NSString *)input {
    const char *cStr = [input UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(cStr, (CC_LONG)strlen(cStr), digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}

- (NSMutableAttributedString *)attributedStringForKey:(NSString *)key {
    NSString *tmp = [NSString stringWithFormat:@"ATTR_STR_%@",key];
    NSString *internalKey = [self MD5HashOfString:tmp];
    NSMutableAttributedString *val = [self objectForKey:internalKey];
    if(!val){
        val = [TextLayoutCache attributedStringOfContent:key];
        [self setObject:val forKey:internalKey];
    }
    return val;
}

- (YYTextLayout *)layoutForKey:(NSString *)key {
    NSString *tmp = [NSString stringWithFormat:@"LAYOUT_%@",key];
    NSString *internalKey = [self MD5HashOfString:tmp];
    YYTextLayout *val = [self objectForKey:internalKey];
    if(!val){
        NSMutableAttributedString *attr = [self attributedStringForKey:key];
        val = [TextLayoutCache textLayoutForBubbleWithAttributedString:attr];
        [self setObject:val forKey:internalKey];
    }
    return val;
}

+ (NSMutableAttributedString *)attributedStringOfContent:(NSString *)content{
    NSString *html = [MMMarkdown HTMLStringWithMarkdown:content error:nil];
    NSString *htmlString = [NSString stringWithFormat:@"<head> <style> body { font-family: \"Arial\", sans-serif; font-size: 15%; color: black} </style> </head> %@",html];
    NSData *htmlData = [htmlString dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithData:htmlData options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)} documentAttributes:nil error:nil];
    return attributedString;
}

+ (YYTextLayout *)textLayoutForBubbleWithAttributedString:(NSMutableAttributedString *)attributedString{
    YYTextContainer *container = [YYTextContainer containerWithSize:CGSizeMake(TEXTLABEL_MAX_WIDTH, MAXFLOAT)];
    return [YYTextLayout layoutWithContainer:container text:attributedString];
}

- (void)setObject:(id)object forKey:(id)key {
    TextLayoutCacheNode *node = self.cache[key];
    if (node) {
        node.value = object;
        [self moveNodeToHead:node];
    } else {
        node = [[TextLayoutCacheNode alloc] init];
        node.key = key;
        node.value = object;
        self.cache[key] = node;
        [self moveNodeToHead:node];
        
        if (self.cache.count > self.capacity) {
            TextLayoutCacheNode *removedNode = self.tail.prev;
            [removedNode.prev setNext:self.tail];
            [self.tail setPrev:removedNode.prev];
            [self.cache removeObjectForKey:removedNode.key];
        }
    }
}

@end
