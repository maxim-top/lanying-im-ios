#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

@interface OnceHappenStorage : NSObject

+ (void)add:(NSString *)objectId byType:(NSString *)type;
+ (bool)has:(NSString *)objectId byType:(NSString *)type;

@end

NS_ASSUME_NONNULL_END
