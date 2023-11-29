//
//  NSDate+Judge.m
//  XSTeachEDU
//
//  Created by hyt on 2016/10/17.
//  Copyright © 2016年 xsteach.com. All rights reserved.
//

#import "NSDate+Judge.h"
#import "NSCalendar+Establish.h"
#import "LanyingLangManager.h"

@implementation NSDate (Judge)

/** 是否是今天 */
- (BOOL)lh_isInToDay
{
    NSCalendar *calendar = [NSCalendar lh_calendar];
    
    NSCalendarUnit unit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents *selfDate = [calendar components:unit fromDate:self];
    NSDateComponents *newDate = [calendar components:unit fromDate:[NSDate date]];
    
    return [selfDate isEqual:newDate];
}

/** 是否是明天 */
- (BOOL)lh_isIntTomorrow
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMdd";
    
    NSString *selfString = [formatter stringFromDate:self];
    NSString *newString = [formatter stringFromDate:[NSDate date]];
    
    NSDate *selfDate = [formatter dateFromString:selfString];
    NSDate *newDate = [formatter dateFromString:newString];
    
    NSCalendar *calendar = [NSCalendar lh_calendar];
    
    NSCalendarUnit unit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents *components = [calendar components:unit fromDate:selfDate toDate:newDate options:0];
    
    return components.year == 0
    && components.month == 0
    && components.day == -1;
}

/** 是否是昨天 */
- (BOOL)lh_isInYesterday
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMdd";
    
    NSString *selfString = [formatter stringFromDate:self];
    NSString *newString = [formatter stringFromDate:[NSDate date]];
    
    NSDate *selfDate = [formatter dateFromString:selfString];
    NSDate *newDate = [formatter dateFromString:newString];
    
    NSCalendar *calendar = [NSCalendar lh_calendar];
    
    NSCalendarUnit unit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents *components = [calendar components:unit fromDate:selfDate toDate:newDate options:0];
    
    return components.year == 0
    && components.month == 0
    && components.day == 1;
}

- (NSString *)lh_dayStringOnConversationList
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy/MM/dd"];
    NSString *ret  = [formatter stringFromDate:self];
    
    if (self.lh_isInThisYear) { // 是今年
        formatter.dateFormat = @"yyyyMMdd";
        NSString *selfString = [formatter stringFromDate:self];
        NSString *todayString = [formatter stringFromDate:[NSDate date]];
        
        NSDate *selfDate = [formatter dateFromString:selfString];
        NSDate *todayDate = [formatter dateFromString:todayString];
        
        NSCalendar *calendar = [NSCalendar lh_calendar];
        NSCalendarUnit unit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
        NSDateComponents *components = [calendar components:unit fromDate:selfDate toDate:todayDate options:0];
        
        if (components.year == 0
            && components.month == 0
            && components.day >= 0
            && components.day < 7){ // 一周内
            formatter.dateFormat = @"HH:mm";
            NSString *hhmmString = [formatter stringFromDate:self];
            if(components.day == 0){ // 今天
                ret = hhmmString;
            }else if(components.day == 1){ // 昨天
                ret = [NSString stringWithFormat:NSLocalizedString(@"Yesterday_at", @"昨天 %@"), hhmmString];
            }else{
                NSString *currLan = [LanyingLangManager userLanguage];
                if (currLan.length == 0) {
                    currLan = [NSLocale preferredLanguages].firstObject;
                }


                [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:currLan]];
                formatter.dateFormat = @"EEEE";
                ret = [formatter stringFromDate:selfDate];
            }
            
        }else {
            [formatter setDateFormat:@"MM/dd"];
            ret = [formatter stringFromDate:self];
        }
    }

    return ret;
}

- (NSString *)lh_dayString
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy/MM/dd HH:mm"];
    NSString *ret  = [formatter stringFromDate:self];
    
    if (self.lh_isInThisYear) { // 是今年
        formatter.dateFormat = @"yyyyMMdd";
        NSString *selfString = [formatter stringFromDate:self];
        NSString *todayString = [formatter stringFromDate:[NSDate date]];
        
        NSDate *selfDate = [formatter dateFromString:selfString];
        NSDate *todayDate = [formatter dateFromString:todayString];
        
        NSCalendar *calendar = [NSCalendar lh_calendar];
        NSCalendarUnit unit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
        NSDateComponents *components = [calendar components:unit fromDate:selfDate toDate:todayDate options:0];
        
        if (components.year == 0
            && components.month == 0
            && components.day >= 0
            && components.day < 7){ // 一周内
            formatter.dateFormat = @"HH:mm";
            NSString *hhmmString = [formatter stringFromDate:self];
            if(components.day == 0){ // 今天
                ret = hhmmString;
            }else if(components.day == 1){ // 昨天
                ret = [NSString stringWithFormat:NSLocalizedString(@"Yesterday_at", @"昨天 %@"), hhmmString];
            }else{
                NSString *currLan = [LanyingLangManager userLanguage];
                if (currLan.length == 0) {
                    currLan = [NSLocale preferredLanguages].firstObject;
                }


                [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:currLan]];
                formatter.dateFormat = @"EEEE";
                NSString *weekDay = [formatter stringFromDate:selfDate];
                ret = [NSString stringWithFormat:@"%@ %@", weekDay, hhmmString];
            }
            
        }else {
            [formatter setDateFormat:@"MM/dd HH:mm"];
            ret = [formatter stringFromDate:self];
        }
    }

    return ret;
}

/** 是否是今年 */
- (BOOL)lh_isInThisYear
{
    NSCalendar *calendar = [NSCalendar lh_calendar];
    
    NSDateComponents *selfDate = [calendar components:NSCalendarUnitYear fromDate:self];
    NSDateComponents *newDate = [calendar components:NSCalendarUnitYear fromDate:[NSDate date]];
    
    return [selfDate isEqual:newDate];
}

@end
