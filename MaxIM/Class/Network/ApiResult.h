//
//  ApiResult.h
//  MaxIMDemo
//
//  Created by hanyutong on 16/8/9.
//  ----------------------------------------------------------------------
//
//                    Copyright (C) 2018-2019   MaxIM.Top
//
// You may obtain a copy of the licence at http://www.maxim.top/LICENCE-MAXIM.md
//
//  ----------------------------------------------------------------------
//

#import <Foundation/Foundation.h>

@interface ApiResult : NSObject

@property (nonatomic, copy) NSString *code;
@property (nonatomic, copy) NSString *errmsg;
@property (nonatomic, copy) NSString *errtime;
@property (nonatomic, strong) id resultData;
@property (nonatomic, strong) id responseObject;

- (BOOL)isOK;
- (BOOL)isInfoChange;
- (instancetype)initWithDictionary:(NSDictionary*)dic;
@end
