#import "SupportsStorage.h"

@implementation SupportsStorage

+ (NSString *)modelPath {
    return @"SupportsStorage";
}

+ (void)saveObject:(nonnull id)object {
    
    if (object == nil) {
        return;
    }
    
    if ([object isKindOfClass:[NSArray class]]) {
        [super saveObject:object];
    }
}

@end
