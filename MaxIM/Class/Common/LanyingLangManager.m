//
//  LanyingLangManager.m

#import "LanyingLangManager.h"

static NSString *LanyingLanguage = @"LanyingLanguage";


@implementation LanyingLangManager

+ (void)setUserLanguage:(NSString *)userLanguage {
    if (!userLanguage.length) {
        [self resetSystemLanguage];
        return;
    }

    [[NSUserDefaults standardUserDefaults] setValue:userLanguage forKey:LanyingLanguage];
    [[NSUserDefaults standardUserDefaults] setValue:@[userLanguage] forKey:@"AppleLanguages"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)userLanguage {
    NSString *language = [[NSUserDefaults standardUserDefaults] valueForKey:LanyingLanguage];
    return  language;
}


+ (void)resetSystemLanguage {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:LanyingLanguage];
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"AppleLanguages"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
