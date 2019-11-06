//
//  ----------------------------------------------------------------------
//   File    :  AnounceCel.m
//   Author  : shaohui.yang shaohui@bmxlabs.com
//   Purpose :
//   Created : 2018/12/25 by shaohui.yang shaohui@bmxlabs.com
//
//  ----------------------------------------------------------------------
//
//                    Copyright (C) 2018-2019   MaxIM.Top
//
// You may obtain a copy of the licence at http://www.maxim.top/LICENCE-MAXIM.md
//
//  ----------------------------------------------------------------------
    

#import "AnounceCel.h"
#import "UIView+BMXframe.h"
#import "NSString+YYAdd.h"

@interface AnounceCel()
{
    UILabel* _title;
    UILabel* _content;
}

@end

@implementation AnounceCel


-(instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initViews];
    }
    return self;
}

-(void) initViews
{
    _title = [[UILabel alloc] init];
    _title.bmx_left = 15;
    _title.bmx_size = CGSizeMake(MAXScreenW-30, 15);
    _title.bmx_top = 10;
    _title.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16];
    [self.contentView addSubview:_title];
    
    _content = [[UILabel alloc] init];
    _content.bmx_left = 15;
    _content.bmx_size = CGSizeMake(MAXScreenW-30, 15);
    _content.bmx_top = 30;
    _content.numberOfLines = 0;
    _content.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [self.contentView addSubview:_content];
}

-(void) cellContentWithTitle:(NSString*) title Content:(NSString*) content
{
    CGFloat sh = [content heightForFont:_content.font width:MAXScreenW-30];
    _title.text = title;
    _content.text = content;
    _content.bmx_size = CGSizeMake(MAXScreenW-30, sh);
}

@end
