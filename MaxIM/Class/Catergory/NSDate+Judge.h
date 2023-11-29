//
//  NSDate+Judge.h
//  XSTeachEDU
//
//  Created by hyt on 2016/10/17.
//  Copyright © 2016年 xsteach.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Judge)
/** 是否是今天 */
- (BOOL)lh_isInToDay;

/** 是否是明天 */
- (BOOL)lh_isIntTomorrow;

/** 是否是昨天 */
- (BOOL)lh_isInYesterday;

/** 今年之前返回“年/月/日 时:分”；今天返回“时:分”；一周内返回“昨天 时:分”或者“星期X 时:分”；否则返回“/月/日 时:分”*/
- (NSString *)lh_dayString;

/** 今年之前返回“年/月/日”；今天返回“时:分”；一周内返回“昨天 时:分”或者“星期X”；否则返回“/月/日”*/
- (NSString *)lh_dayStringOnConversationList;

/** 是否是今年 */
- (BOOL)lh_isInThisYear;
@end
