//
//  JSONResult.h
//  MaxIMDemo
//
//  Created by hanyutong on 16/7/7.
//  ----------------------------------------------------------------------
//
//                    Copyright (C) 2018-2019   MaxIM.Top
//
// You may obtain a copy of the licence at http://www.maxim.top/LICENCE-MAXIM.md
//
//  ----------------------------------------------------------------------
//

#import <Foundation/Foundation.h>

@interface JSONResult : NSObject<NSCoding>

@property (nonatomic,strong) NSString *errcode;
@property (nonatomic,strong) NSString *errmsg;
@property (nonatomic,strong) NSString *errtime;
@property (nonatomic, strong) id data;

-(instancetype)initWithDic:(NSDictionary*)dic;
+(instancetype)resultWithNetworkErr:(NSError*)err;

@end
