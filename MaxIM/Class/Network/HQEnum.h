//
//  HQEnum.h
//  MaxIMDemo
//
//  Created by hyt on 2017/10/12.
//  ----------------------------------------------------------------------
//
//                    Copyright (C) 2018-2019   MaxIM.Top
//
// You may obtain a copy of the licence at http://www.maxim.top/LICENCE-MAXIM.md
//
//  ----------------------------------------------------------------------
//

typedef enum {
    NotReachable = 0,
    ReachableViaWiFi,
    ReachableViaWWAN,
    ReachableVia4G,
    ReachableVia2G,
    ReachableVia3G
} NetworkStatus;
