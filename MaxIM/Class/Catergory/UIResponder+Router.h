//
//  UIResponder+Router.h
//
//
//  Created by hyt on 16/3/17.
//  Copyright © 2016年 hyt All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIResponder (Router)

// router message and the responder who you want will respond this method
- (void)routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo;

@end
