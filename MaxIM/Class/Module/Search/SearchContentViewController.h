//
//  ----------------------------------------------------------------------
//   File    :  SearchContentViewController.h
//   Author  : HYT yutong@bmxlabs.com
//   Purpose :
//   Created : 2019/1/10 by HYT yutong@bmxlabs.com
//
//  ----------------------------------------------------------------------
//
//                    Copyright (C) 2018-2019   MaxIM.Top
//
// You may obtain a copy of the licence at http://www.maxim.top/LICENCE-MAXIM.md
//
//  ----------------------------------------------------------------------
    

#import <UIKit/UIKit.h>
#import <floo-ios/BMXMessageObject.h>
@class BMXConversation;

NS_ASSUME_NONNULL_BEGIN

@interface SearchContentViewController : UIViewController

- (instancetype)initWithSearchContentType:(BMXContentType)contentType conversation:(BMXConversation *)conversation;
@property (nonatomic,assign) BOOL isConversation;



@end

NS_ASSUME_NONNULL_END
