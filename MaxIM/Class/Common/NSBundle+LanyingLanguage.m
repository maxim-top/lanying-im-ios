//
//  NSBundle+LanyingLanguage.m

#import "NSBundle+LanyingLanguage.h"
#import <objc/runtime.h>
#import "LanyingLangManager.h"

@interface LanyingBundle : NSBundle

@end


@implementation LanyingBundle

- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName {
    if ([LanyingBundle getBundle]) {
        return [[LanyingBundle getBundle] localizedStringForKey:key value:value table:tableName];
    } else {
        return [super localizedStringForKey:key value:value table:tableName];
    }
}
- (nullable NSString *)pathForResource:(nullable NSString *)name ofType:(nullable NSString *)ext {
    if ([ext isEqualToString: @"json"] || [ext isEqualToString: @"png"]) {
        NSString *lan = [LanyingLangManager userLanguage];
        if (lan.length == 0) {
            return [super pathForResource:name ofType:ext];
        }
        NSString *path = [[NSBundle mainBundle] pathForResource:[LanyingLangManager userLanguage] ofType:@"lproj"];
        if (path.length) {
            return [[NSBundle bundleWithPath:path]pathForResource:name ofType:ext];
        }
    }
    return [super pathForResource:name ofType:ext];
}

+ (NSBundle *)getBundle {
    if ([LanyingLangManager userLanguage].length) {
        NSString *path = [[NSBundle mainBundle] pathForResource:[LanyingLangManager userLanguage] ofType:@"lproj"];
        if (path.length) {
            return [NSBundle bundleWithPath:path];
        }
    }
    return nil;
}

@end

@implementation NSBundle (LanyingLanguage)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        object_setClass([NSBundle mainBundle], [LanyingBundle class]);
    });
}

@end
