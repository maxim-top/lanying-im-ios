#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

@interface FraudNoticedIdStorage : NSObject

+ (void)add:(NSString *)noticeId;
+ (bool)has:(NSString *)noticeId;

@end

NS_ASSUME_NONNULL_END
