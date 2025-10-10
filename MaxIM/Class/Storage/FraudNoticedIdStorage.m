#import "FraudNoticedIdStorage.h"

@implementation FraudNoticedIdStorage

+ (void)add:(NSString *)noticeId {
    NSUserDefaults *customDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"FraudNoticedId"];

    // 存储数据
    [customDefaults setObject:@"1" forKey:noticeId];
    [customDefaults synchronize];
}

+ (bool)has:(NSString *)noticeId {
    // 读取数据
    NSUserDefaults *customDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"FraudNoticedId"];
    NSString *value = [customDefaults objectForKey:noticeId];
    return value!=nil;
}

@end
