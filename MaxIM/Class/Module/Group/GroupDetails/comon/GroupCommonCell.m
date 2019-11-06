//
//  ----------------------------------------------------------------------
//   File    :  GroupCommonCell.m
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
    

#import "GroupCommonCell.h"

@interface GroupCommonCell()
{
    UILabel* _mainText;
    UILabel* _detailText;
    UISwitch* _settingSwitch;
    UIView* _line;
}

@end

@implementation GroupCommonCell


-(instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initViews];
    }
    return self;
}

-(void) initViews
{
    _mainText = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, MAXScreenW-200, 50)];
    _mainText.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16];
    _mainText.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1/1.0];
    [self.contentView addSubview:_mainText];

    
    _detailText = [[UILabel alloc] initWithFrame:CGRectMake(MAXScreenW-180-15, 0, 180, 50)];
    _detailText.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16];
    _detailText.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1/1.0];
    _detailText.textAlignment = NSTextAlignmentRight;
    [_detailText setHidden:YES];
    [self.contentView addSubview:_detailText];
    
    _settingSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(MAXScreenW-25-30, 5, 40, 16)];
    _settingSwitch.onTintColor = BMXCOLOR_HEX(0x0079f4);
    _settingSwitch.transform = CGAffineTransformMakeScale(0.65, 0.65);
    [self.contentView addSubview:_settingSwitch];
    
    _line = [[UIView alloc] initWithFrame:CGRectMake(15, 50, MAXScreenW, 0.5)];
    _line.backgroundColor = [UIColor colorWithRed:223/255.0 green:223/255.0 blue:223/255.0 alpha:1/1.0];
    [self.contentView addSubview:_line];
    
    self.avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(MAXScreenW - 80, 5, 40, 40)];
    self.avatarImageView.image = [UIImage imageNamed:@"group_placeHo"];
    [self.avatarImageView  setHidden:YES];
    [self.contentView addSubview: self.avatarImageView ];
}


-(void) setMainText:(NSString*) mainText detailText:(NSString*) detailText switcherFlag:(BOOL) switcherFlag switcherTarget:(__weak id) target switcherSelector:(nullable SEL) selector
{
    [_line setHidden:NO];
    _mainText.text = mainText;
    if(detailText == nil) {
        [_settingSwitch setHidden:NO];
        [_detailText setHidden:YES];
        _settingSwitch.on = switcherFlag;
        if(selector != nil) {
            [_settingSwitch addTarget:target action:selector forControlEvents:UIControlEventValueChanged];
        }
    }else {
        _detailText.text = detailText;
        [_settingSwitch setHidden:YES];
        [_detailText setHidden:NO];
    }
    
}

-(void) showAccesor:(BOOL) isShow
{
    if (isShow) {
        _detailText.frame = CGRectMake(MAXScreenW-180-15, 0, 150, 50);
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else {
        self.accessoryType = UITableViewCellAccessoryNone;
        _detailText.frame = CGRectMake(MAXScreenW-180-15, 0, 180, 50);
    }
}
-(void) showSepLine:(BOOL) isShow
{
    [_line setHidden:!isShow];
}



@end
