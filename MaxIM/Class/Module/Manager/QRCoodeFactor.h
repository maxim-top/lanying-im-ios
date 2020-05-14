//
//  QRCoodeFactor.h
//  MaxIM
//
//  Created by 韩雨桐 on 2020/4/23.
//  Copyright © 2020 hyt. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QRCoodeFactor : NSObject

+ (UIImage *)generateQRCodeWithString:(NSString *)string Size:(CGFloat)size;

@end

NS_ASSUME_NONNULL_END
