//
//  SDKConfigViewController.h
//  MaxIM
//
//  Created by 韩雨桐 on 2020/4/9.
//  Copyright © 2020 hyt. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


typedef void(^CellClick)(NSString *title, NSString *content);

@protocol SDKConfigViewControllerProtocl <NSObject>

- (void)sdkconfigdidClickReturn;

@end

@interface SDKConfigViewController : UIViewController


@property (nonatomic,assign) id<SDKConfigViewControllerProtocl> delegate;


@end



NS_ASSUME_NONNULL_END
