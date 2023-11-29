//
//  LHChatTextBubbleView.m
//  LHChatUI
//
//  Created by hyt on 2016/12/26.
//  Copyright © 2016年 hyt. All rights reserved.
//

#import "LHChatTextBubbleView.h"
#import "YYTextView.h"
#import "YYImage.h"
#import "YYAnimatedImageView.h"
#import "NSAttributedString+YYText.h"
#import "FaceDefine.h"
#import <MMMarkdown/MMMarkdown.h>
#import "TextLayoutCache.h"

//　textLaebl 最大宽度
CGFloat const LABEL_FONT_SIZE = 15.0f;

@interface LHChatTextBubbleView () {
    NSDataDetector *_detector;
    NSArray *_urlMatches;
}

@property (nonatomic, strong) YYTextView *textLabel;

@end

@implementation LHChatTextBubbleView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _textLabel = [[YYTextView alloc] initWithFrame:CGRectZero];
        _textLabel.userInteractionEnabled = YES;
        _textLabel.font = [UIFont systemFontOfSize:LABEL_FONT_SIZE];
        _textLabel.multipleTouchEnabled = NO;
        _textLabel.tag = 1000;
        _textLabel.textVerticalAlignment = YYTextVerticalAlignmentTop;
        _textLabel.scrollEnabled = NO;
        _textLabel.textContainerInset = UIEdgeInsetsZero;
        [self addSubview:_textLabel];
        
        _detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect frame = self.bounds;
    frame.size.width -= BUBBLE_ARROW_WIDTH;
    frame = CGRectInset(frame, BUBBLE_VIEW_PADDING, BUBBLE_VIEW_PADDING);
    if (self.messageModel.isSender) {
        frame.origin.x = BUBBLE_VIEW_PADDING;
    }else{
        frame.origin.x = BUBBLE_VIEW_PADDING + BUBBLE_ARROW_WIDTH;
    }
    
    frame.origin.y = BUBBLE_VIEW_PADDING;
    [self.textLabel setFrame:frame];
}


#pragma mark - setter

+ (CGSize)getSizeWithKey:(LHMessageModel *)object{
    NSString *key = object.content;
    YYTextLayout *textLayout = [[TextLayoutCache sharedInstance] layoutForKey: key];
    return textLayout.textBoundingSize;
}

- (void)handleTap:(UITapGestureRecognizer *)gestureRecognizer {
    YYTextView *label = (YYTextView *)gestureRecognizer.view;
    NSAttributedString *attributedText = label.attributedText;
    if (!label || !attributedText) {
        return;
    }

    // 检查点击的位置是否在某个链接范围内
    CGPoint location = [gestureRecognizer locationInView:label];
    NSInteger characterIndex = [self characterIndexAt:location attributedText:attributedText];
    NSDictionary *attributes = [attributedText attributesAtIndex:characterIndex effectiveRange:nil];
    NSURL *url = attributes[NSLinkAttributeName];
    if (url) {
        NSString *urlString = url.absoluteString;
        [self routerEventWithName:kRouterEventTextURLTapEventName
                         userInfo:@{@"url" : urlString}];
    }
}

- (void)setMessageModel:(LHMessageModel *)messageModel {
    [super setMessageModel:messageModel];
    NSMutableAttributedString *attributedString = [[TextLayoutCache sharedInstance] attributedStringForKey: self.messageModel.content];
    self.textLabel.attributedText = attributedString;
    YYTextLayout *textLayout = [[TextLayoutCache sharedInstance] layoutForKey: self.messageModel.content];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [_textLabel addGestureRecognizer:tapGesture];
    _textLabel.size = textLayout.textBoundingSize;
}

#pragma mark - 私有
+ (NSAttributedString *)processModel:(LHMessageModel *)model {
    if (!model.content) {
        model.content = @"";
    }
    NSMutableAttributedString * mAttributedString = [[NSMutableAttributedString alloc]init];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:4];//调整行间距
    [paragraphStyle setParagraphSpacing:4];//调整行间距
    
    NSDictionary *attri = [NSDictionary dictionaryWithObjects:@[[UIFont systemFontOfSize:15],model.isSender ? [UIColor whiteColor] : [UIColor lh_colorWithHex:0x47474a],paragraphStyle] forKeys:@[NSFontAttributeName,NSForegroundColorAttributeName,NSParagraphStyleAttributeName]];
    [mAttributedString appendAttributedString:[[NSAttributedString alloc] initWithString:model.content attributes:attri]];
    
    //创建匹配正则表达式的类型描述模板
    NSString * pattern = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";
    //创建匹配对象
    NSError * error;
    NSRegularExpression * regularExpression = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    //判断
    if (!regularExpression) {
        //如果匹配规则对象为nil
        MAXLog(@"正则创建失败！");
        MAXLog(@"error = %@",[error localizedDescription]);
        return nil;
    } else {
        NSArray * resultArray = [regularExpression matchesInString:mAttributedString.string options:NSMatchingReportCompletion range:NSMakeRange(0, mAttributedString.string.length)];
        
        NSInteger index = resultArray.count;
        while (index > 0) {
            index --;
            NSTextCheckingResult *result = resultArray[index];
            //根据range获取字符串
            NSString * rangeString = [mAttributedString.string substringWithRange:result.range];
            DLog(@"rangge is %@",rangeString);
            
            
            NSString *imageName =  [FaceDict objectForKey:rangeString];
            if (imageName) {
                //获取图片
                YYImage * image = [LHChatTextBubbleView getImageWithRangeString:imageName];//这是个自定义的方法
                if (image != nil) {
                    YYAnimatedImageView *imageView = [[YYAnimatedImageView alloc] initWithImage:image];
                    imageView.width = 50;
                    imageView.height = 50;
                    
                    NSMutableAttributedString *attachText = [NSMutableAttributedString yy_attachmentStringWithContent:imageView contentMode:UIViewContentModeCenter attachmentSize:imageView.size alignToFont:[UIFont systemFontOfSize:15] alignment:YYTextVerticalAlignmentCenter];
                    //开始替换
                    [mAttributedString replaceCharactersInRange:result.range withAttributedString:attachText];
                }
            }
        }
    }
    
    return mAttributedString;
}

//根据rangeString获取plist中的图片
+ (YYImage *)getImageWithRangeString:(NSString *)rangeString {
    YYImage *image = [YYImage imageNamed:rangeString];
    image.preloadAllAnimatedImageFrames = YES;
    return image;
}

+ (CGFloat)heightForBubbleWithObject:(LHMessageModel *)object {
    CGSize textBoundingSize = [LHChatTextBubbleView getSizeWithKey:object];
    CGFloat height = 2 * BUBBLE_VIEW_PADDING + textBoundingSize.height + 30;
    return height;
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize textBoundingSize = [LHChatTextBubbleView getSizeWithKey:self.messageModel];
    CGFloat height = 2*BUBBLE_VIEW_PADDING + textBoundingSize.height;
    if (height < 40) {
        height = 40;
    }
    
    CGFloat width = textBoundingSize.width + BUBBLE_VIEW_PADDING*2 + BUBBLE_VIEW_PADDING;
    if (width < 46.5) {
        width = 46.5;
    }
    
    return CGSizeMake(width, height);
}

#pragma mark 处理超链接
- (BOOL)isIndex:(CFIndex)index inRange:(NSRange)range {
    return index > range.location && index < range.location+range.length;
}

- (void)highlightLinksWithIndex:(CFIndex)index {
    
    NSMutableAttributedString* attributedString = [_textLabel.attributedText mutableCopy];
    for (NSTextCheckingResult *match in _urlMatches) {
        
        if ([match resultType] == NSTextCheckingTypeLink) {
            
            NSRange matchRange = [match range];
            
            if ([self isIndex:index inRange:matchRange]) {
                [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:matchRange];
            } else {
                [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:matchRange];
            }
            [attributedString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:matchRange];
        }
    }
    
    _textLabel.attributedText = attributedString;
}

- (NSInteger)characterIndexAt:(CGPoint)point attributedText:(NSAttributedString *)attributedText {
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:attributedText];
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    [textStorage addLayoutManager:layoutManager];

    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:CGSizeMake(TEXTLABEL_MAX_WIDTH, MAXFLOAT)];
    [layoutManager addTextContainer:textContainer];
    textContainer.lineFragmentPadding = 0;

    NSUInteger glyphIndex = [layoutManager glyphIndexForPoint:point inTextContainer:textContainer];
    NSInteger characterIndex = [layoutManager characterIndexForGlyphAtIndex:glyphIndex];

    return characterIndex;
}


#pragma mark - public

-(void)bubbleViewLongPressed:(id)sender {

    NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc]initWithAttributedString:_textLabel.attributedText];
        NSRange matchRange = NSMakeRange(0, _textLabel.text.length);
        [attributedString addAttribute:NSBackgroundColorAttributeName
                                 value:[UIColor lh_colorWithHexString:@"54B8FA"]
                                 range:matchRange];
//    [attributedString yy_setBackgroundColor:[UIColor blueColor] range:matchRange];
    _textLabel.attributedText = attributedString;
     [self routerEventWithName:kRouterEventLongPressName userInfo:@{kMessageKey : self.messageModel,@"ges":sender}];
}


+ (UIFont *)textLabelFont {
    return [UIFont systemFontOfSize:LABEL_FONT_SIZE];
}

+ (NSLineBreakMode)textLabelLineBreakModel {
    return NSLineBreakByCharWrapping;
}
- (BOOL)resignFirstResponder {
    
    self.textLabel.attributedText = nil;
    [self setMessageModel:self.messageModel];
    return YES;
}

@end
