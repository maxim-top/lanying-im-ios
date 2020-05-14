//
//  IMAcount.h
//  MaxIMDemo
//
//  Created by hanyutong on 16/11/23.
//  ----------------------------------------------------------------------
//
//                    Copyright (C) 2018-2019   MaxIM.Top
//
// You may obtain a copy of the licence at http://www.maxim.top/LICENCE-MAXIM.md
//
//  ----------------------------------------------------------------------
//

#import <Foundation/Foundation.h>
#import "BaseArchiverModel.h"


@interface IMAcount : BaseArchiverModel

@property (nonatomic,assign) BOOL isLogin;
@property (nonatomic,copy) NSString *password;
@property (nonatomic,copy) NSString *usedId;
@property (nonatomic,copy) NSString *userName;

@property (nonatomic, strong) NSString *token;
@property (nonatomic,copy) NSString *appid;

@property (nonatomic, copy) NSString *IMServer;
@property (nonatomic, copy) NSString *IMPort;
@property (nonatomic, copy) NSString *restServer;


@end
