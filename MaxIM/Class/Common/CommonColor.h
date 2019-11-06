//
//  CommonColor.m
//  StudentLive
//
//  Created by hyt on 2017/7/26.
//  Copyright © 2017年 hqyxedu. All rights reserved.
//
#define iPhone6PlusBigMode ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2001), [[UIScreen mainScreen] currentMode].size) : NO)

#define iPhone6Plus ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) : NO)

#define kAdapedHeight(height) ((iPhone6Plus || iPhone6PlusBigMode) ? (height * (MAXScreenH / 667)) : height)

#define PADDING_20PX 10.0
#define PADDING_22PX 11.0
#define PADDING_24PX 12.0
#define PADDING_26PX 13.0
#define PADDING_28PX 14.0
#define PADDING_30PX 15.0
#define PADDING_32PX 16.0
#define PADDING_34PX 17.0
#define PADDING_36PX 18.0
#define PADDING_38PX 19.0
#define PADDING_40PX 20.0
#define PADDING_42PX 21.0
#define PADDING_50PX 25.0
#define PADDING_60PX 30.0
#define PADDING_70PX 35.0
// 通用间距
#define MARGIN_COMMON kAdapedHeight(15.0)



#define T10_20PX 10.0
#define T9_22PX 11.0
#define T8_24PX 12.0
#define T7_26PX 13.0
#define T6_28PX 14.0
#define T5_30PX 15.0
#define T4_32PX 16.0
#define T3_34PX 17.0
#define T2_36PX 18.0
#define T1_38PX 19.0
#define T1_40PX 20.0


#define S1_PAGE_PADDING_10PX 5.0
#define S2_PAGE_PADDING_20PX 10.0
#define S3_PAGE_PADDING_30PX 15.0
#define S4_PAGE_PADDING_40PX 20.0


