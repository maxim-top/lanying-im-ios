#import "AppIDListStorage.h"

@implementation AppIDListStorage

+ (NSString *)modelPath {
    return [NSString stringWithFormat:@"AppIDListStorage"];
}

+ (void)remove:(NSString *)appID {
    NSArray * array = [NSArray arrayWithArray:  [AppIDListStorage loadObject]];

    NSString *temp;
    for (NSString *model  in array) {
        if ([appID isEqualToString:model]) {
            temp = model;
        }
    }
    
    NSMutableArray *arrM = [NSMutableArray arrayWithArray:array];
    [arrM removeObject:temp];
    [AppIDListStorage saveObject:[NSArray arrayWithArray:arrM]];

}

@end
