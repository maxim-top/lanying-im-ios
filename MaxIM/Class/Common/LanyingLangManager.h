//
//  LanyingLangManager.h

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LanyingLangManager : NSObject

@property (class, nonatomic, strong, nullable) NSString *userLanguage;
+ (void)resetSystemLanguage;

@end

NS_ASSUME_NONNULL_END
