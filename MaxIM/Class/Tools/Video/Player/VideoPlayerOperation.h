//
//  VideoOperation.h
//  MaxIM
//
//  Created by 韩雨桐 on 2019/7/4.
//  Copyright © 2019 hyt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>


//G－C－D
#define BACK(block) dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block)
#define MAIN(block) dispatch_async(dispatch_get_main_queue(),block)

typedef void(^VideoCode)(UIImage *imageData,NSString *filePath, CGImageRef tpImage);
typedef void(^VideoStop)(NSString *filePath);


NS_ASSUME_NONNULL_BEGIN

@interface VideoPlayerOperation : NSBlockOperation

@property(nonatomic,copy)VideoCode videoBlock;
@property(nonatomic,copy)VideoStop stopBlock;

-(void)videoPlayTask:(NSString *)filePath;

@end

NS_ASSUME_NONNULL_END
