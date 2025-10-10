#import "OnceHappenStorage.h"

@implementation OnceHappenStorage

+ (void)add:(NSString *)objectId byType:(NSString *)type {
    NSUserDefaults *customDefaults = [[NSUserDefaults alloc] initWithSuiteName:type];

    // 存储数据
    [customDefaults setObject:@"1" forKey:objectId];
    [customDefaults synchronize];
}

+ (bool)has:(NSString *)objectId byType:(NSString *)type {
    // 读取数据
    NSUserDefaults *customDefaults = [[NSUserDefaults alloc] initWithSuiteName:type];
    NSString *value = [customDefaults objectForKey:objectId];
    return value!=nil;
}

@end
