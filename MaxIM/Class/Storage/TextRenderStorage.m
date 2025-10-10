#import "TextRenderStorage.h"

@implementation TextRenderStorage

+ (NSString *)modelPath {
    return [NSString stringWithFormat:@"TextRenderStorage"];
}

+ (id)loadObject {
    NSString *renderType  = [super loadObject];
    if (renderType == nil) {
        [super saveObject:@"1"];
        renderType = @"1";
    }
    return renderType;
}

@end
