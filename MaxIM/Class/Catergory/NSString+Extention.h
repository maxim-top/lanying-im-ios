//
//  NSString+Extention.h
//  MaxIM
//
//  Created by 韩雨桐 on 2019/5/21.
//  Copyright © 2019 hyt. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Extention)

+ (NSString *)jsonStringWithDictionary:(NSDictionary *)dictionary;

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;

+ (NSString *)currentName;

@end

NS_ASSUME_NONNULL_END
