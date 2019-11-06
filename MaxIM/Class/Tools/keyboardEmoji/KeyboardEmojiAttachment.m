//
//  KeyboardEmojiAttachment.m
//  keyboardEmotion
//
//  Created by hyt on 16/7/11.
//  Copyright © 2016年 hyt. All rights reserved.
//

#import "KeyboardEmojiAttachment.h"
#import "KeyboardEmojiModel.h"


@implementation KeyboardEmojiAttachment

+ (NSAttributedString *)emojiString:(KeyboardEmojiModel *)emoji font:(UIFont *)font {
    KeyboardEmojiAttachment *attachment = [[KeyboardEmojiAttachment alloc] init];
    attachment.image = [UIImage imageWithContentsOfFile:emoji.imagePath];
    attachment.chs = emoji.name;
    
    CGFloat height = font.lineHeight;
    attachment.bounds = CGRectMake(0, -4, height, height);
    return [NSAttributedString attributedStringWithAttachment:attachment];
}

@end
