#import "AppIDListStorage.h"

@implementation AppIDListStorage

+ (NSString *)modelPath {
    return [NSString stringWithFormat:@"AppIDListStorage"];
}

+ (void)remove:(NSString *)appID {
    NSArray * array = [NSArray arrayWithArray:  [AppIDListStorage loadObject]];

    for (NSString *model  in array) {
        if ([appID isEqualToString:model]) {
            NSString *temp = model;
            NSMutableArray *arrM = [NSMutableArray arrayWithArray:array];
            [arrM removeObject:temp];
            [AppIDListStorage saveObject:[NSArray arrayWithArray:arrM]];
        }
    }
}

@end
