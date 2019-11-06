//
//  BaseStorage.h
//  BlockMessage
//
//  Created by hyt on 2018/8/1.
//  Copyright © 2018年 HYT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseStorage : NSObject

+ (NSString *)modelPath;
+ (void)saveObject:(id)object;
+ (id)loadObject;
+ (void)clearObject;

@end
