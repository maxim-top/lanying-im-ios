//  ************************************************************************
//
//  BaseArchiverModel.m
//
//
//  Other specifications:
//
//  ************************************************************************

#import "BaseArchiverModel.h"
#import <objc/message.h>

@interface BaseArchiverModel ()<NSCoding>

@end

@implementation BaseArchiverModel

/**
 *  从文件中归档对象
 */
- (void)encodeWithCoder:(NSCoder *)encoder {
    unsigned int count = 0;
    Ivar *ivars = class_copyIvarList([self class], &count);
    for (int i = 0; i<count; i++) {
        Ivar ivar = ivars[i];
        const char *name = ivar_getName(ivar);
        NSString *key = [NSString stringWithUTF8String:name];
        id value = [self valueForKey:key];
        [encoder encodeObject:value forKey:key];
    }
    free(ivars);
}

/**
 *  从文件中解析对象
 */
- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        unsigned int count = 0;
        Ivar *ivars = class_copyIvarList([self class], &count);
        
        for (int i = 0; i<count; i++) {
            Ivar ivar = ivars[i];
            const char *name = ivar_getName(ivar);
            // 归档
            NSString *key = [NSString stringWithUTF8String:name];
            id value = [decoder decodeObjectForKey:key];
            [self setValue:value forKey:key];
        }
        free(ivars);
    }
    return self;
}

@end
