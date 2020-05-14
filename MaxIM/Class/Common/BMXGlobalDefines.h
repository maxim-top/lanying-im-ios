//
//  BMXGlobalDefines.h
//  MaxIM
//
//  Created by hyt on 2018/11/15.
//  Copyright © 2018年 hyt. All rights reserved.
//

#ifndef BMXGlobalDefines_h
#define BMXGlobalDefines_h

#import <Foundation/Foundation.h>


#define kDiscvoerVideoPath @"Download/Video"  // video子路径
#define kChatVideoPath @"Chat/Video"  // video子路径
#define kVideoType @".mp4"        // video类型
#define kRecoderType @".wav"


extern NSString *const VideoPathKey;
extern NSString *const GXRouterEventVideoRecordFinish;
extern NSString *const GXRouterEventVideoRecordExit;

typedef enum : NSUInteger {
    EditTypePhone,
    EditTypePassword
} EditType;



#endif /* BMXGlobalDefines_h */
