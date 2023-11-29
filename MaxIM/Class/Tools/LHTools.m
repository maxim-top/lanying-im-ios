//
//  LHTools.m
//  LHChatUI
//
//  Created by hyt on 2016/12/23.
//  Copyright © 2016年 hyt. All rights reserved.
//

#import "LHTools.h"
#import <AVFoundation/AVFoundation.h>
#import "NSDate+Judge.h"

@implementation LHTools

+ (BOOL)photoLimit {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        return YES;
    } else {
        return NO;
    }
}


+ (BOOL)cameraLimit {
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if (authStatus == AVAuthorizationStatusRestricted ||
        authStatus == AVAuthorizationStatusDenied){
        
        MAXLog(@"相机权限受限");
        
        return NO;
        
    } else {
        return YES;
    }
}

+ (NSString *)dayStringWithDate:(NSString *)date {
    date = date.length > 10 ? date : [NSString stringWithFormat:@"%@",[NSDate dateWithTimeIntervalSince1970:0]];
    NSTimeInterval time = [[date substringToIndex:10] doubleValue];//因为时差问题要加8小时
    NSDate *sinceDate = [NSDate dateWithTimeIntervalSince1970:time];
    return [sinceDate lh_dayString];
}

+ (NSString *)dayStringOnConversationListWithDate:(NSString *)date {
    date = date.length > 10 ? date : [NSString stringWithFormat:@"%@",[NSDate dateWithTimeIntervalSince1970:0]];
    NSTimeInterval time = [[date substringToIndex:10] doubleValue];//因为时差问题要加8小时
    NSDate *sinceDate = [NSDate dateWithTimeIntervalSince1970:time];
    return [sinceDate lh_dayStringOnConversationList];
}

@end
