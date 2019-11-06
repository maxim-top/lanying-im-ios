//  ************************************************************************
//
//  HQToast.m
//  MaxIMDemo
//
//  Created by hyt on 2017/7/29.
//  ----------------------------------------------------------------------
//
//                    Copyright (C) 2018-2019   MaxIM.Top
//
// You may obtain a copy of the licence at http://www.maxim.top/LICENCE-MAXIM.md
//
//  ----------------------------------------------------------------------

#import "HQToast.h"

@interface HQToast ()
@end

@implementation HQToast

bool isShow = NO;
bool isBottom;

+ (void)showDialog:(NSString *)content {
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    
    isBottom = NO;
    [self showDialog:content inView:window];
}

+ (void)showNetworkError {
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    
    isBottom = YES;
    
    [self showDialog:@"网络正在开小差，请稍后重试" inView:window];
}

+ (void)showDialog:(NSString *)content inView:(UIView *)view {
    [self showDialog:content inView:view WithTime:1.5];
}

+ (void)showDialog:(NSString *)content inView:(UIView *)view WithTime:(CGFloat)seconds {
    if (isShow) {
        return;
    }
    isShow = YES;
    NSString *string;
    NSString *functionName = [self p_showOrHideLoadingInfoDetail];
    if (functionName && functionName.length > 0) {
        string = [NSString stringWithFormat:@"%@\n%@",content,functionName];
    } else {
        string = content;
    }
    CGSize contentSize = [self p_contentSizeWithString:string];
    [self p_addToastWithContentSize:contentSize textString:string delay:seconds view:view];
}

+ (void)p_addToastWithContentSize:(CGSize)contentSize
                       textString:(NSString *)string
                            delay:(CGFloat) seconds
                             view:(UIView *)view {
    float yPoint = (view.frame.size.height - contentSize.height) / 2; // 居中
    if (isBottom) {
        yPoint = view.frame.size.height - contentSize.height - 30 - 49; // 靠下
    }
    CGRect rect = CGRectMake((view.frame.size.width - contentSize.width)/2,
                             yPoint, contentSize.width, contentSize.height);
    HQToast *toast = [[self alloc] initWithFrame:rect];
    toast.userInteractionEnabled = NO;
    toast.layer.cornerRadius = 5;
    toast.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    [view addSubview:toast];
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        toast.transform = CGAffineTransformMakeRotation(M_PI_2);
        [toast setTransform:CGAffineTransformScale(toast.transform, 0.8, 0.8)];
        toast.alpha = 0.1;
        [UIView animateWithDuration:0.25
                         animations:^{
                             [toast setTransform:CGAffineTransformScale(toast.transform, 1.1, 1.1)];
                             toast.alpha = 1.0;
                         } completion:^(BOOL finished) {
                             [toast setTransform:CGAffineTransformScale(toast.transform, 1.0, 1.0)];
                         }];
    } else {
        [toast setTransform:CGAffineTransformScale(toast.transform, 0.8, 0.8)];
        toast.alpha = 0.1;
        [UIView animateWithDuration:0.25
                         animations:^{
                             [toast setTransform:CGAffineTransformScale(toast.transform, 1.1, 1.1)];
                             toast.alpha = 1.0;
                         } completion:^(BOOL finished) {
                             [toast setTransform:CGAffineTransformScale(toast.transform, 1.0, 1.0)];
                         }];

    }
    [self p_toastAddLabelWithContentSize:contentSize
                              textString:string
                                   toast:toast
                                   delay:seconds];
}

+ (CGSize)p_contentSizeWithString:(NSString *)string {
    NSDictionary *attribute = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:15]};
    CGSize contentSize =
    [string boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 120, 380)
                         options: NSStringDrawingTruncatesLastVisibleLine |
                                  NSStringDrawingUsesLineFragmentOrigin |
                                  NSStringDrawingUsesFontLeading
                      attributes:attribute context:nil].size;
    contentSize.height += 15;
    contentSize.width += 50;
    return contentSize;
}

+ (void)p_toastAddLabelWithContentSize:(CGSize)contentSize
                            textString:(NSString *)string
                                 toast:(HQToast *) toast
                                 delay:(CGFloat) seconds {
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, contentSize.width - 20,contentSize.height)];
    contentLabel.backgroundColor = [UIColor clearColor];
    contentLabel.font = [UIFont boldSystemFontOfSize:16];
    contentLabel.text = string;
    contentLabel.numberOfLines = 0;
    contentLabel.textAlignment = NSTextAlignmentCenter;
    contentLabel.textColor = [UIColor whiteColor];
    [toast addSubview:contentLabel];
    [toast performSelector:@selector(hiddenDialog) withObject:nil afterDelay:seconds];
}

+ (NSString *)p_showOrHideLoadingInfoDetail {
    NSString *loadingInfoDetail = [[[NSBundle mainBundle] infoDictionary]
                                   objectForKey:@"LoadingInfoDetail"];
    if ([loadingInfoDetail isEqualToString:@"1"]) {
        NSArray *functionsArray = [NSThread callStackSymbols];
        NSString *functionName = functionsArray[3];
        for (NSString *function in functionsArray) {
            BOOL isCaller = !([function containsString:@"Toast"]) &&
            ([function containsString:@"["] && [function containsString:@"]"]);
            if (isCaller) {
                NSRange rangeStart = [function rangeOfString:@"["];
                NSRange rangeEnd = [function rangeOfString:@"]"];
                NSRange range = NSMakeRange(rangeStart.location, rangeEnd.location - rangeStart.location + 1);
                functionName = [function substringWithRange:range];
                break;
            }
        }
        return functionName;
    } else {
        return @"";
    }
}

- (void)hiddenDialog {
    isShow = NO;
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        [UIView animateWithDuration:0.2
                         animations:^{
                             [self setTransform:CGAffineTransformMakeRotation(M_PI_2)];
                             [self setTransform:CGAffineTransformScale(self.transform, 1.4, 1.4)];
                             self.alpha = 0.1;
                         } completion:^(BOOL finished) {
                             [self removeFromSuperview];
                         }];
    } else {
        [UIView animateWithDuration:0.2
                         animations:^{
                             [self setTransform:CGAffineTransformScale(self.transform, 1.4, 1.4)];
                             self.alpha = 0.1;
                         } completion:^(BOOL finished) {
                             [self removeFromSuperview];
                         }];
    }
}

@end
