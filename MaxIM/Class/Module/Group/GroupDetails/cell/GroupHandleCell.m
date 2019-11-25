//
//  ----------------------------------------------------------------------
//   File    :  GroupHandleCell.m
//   Author  : shaohui.yang shaohui@bmxlabs.com
//   Purpose :
//   Created : 2019/1/4 by shaohui.yang shaohui@bmxlabs.com
//
//  ----------------------------------------------------------------------
//
//                    Copyright (C) 2018-2019   MaxIM.Top
//
// You may obtain a copy of the licence at http://www.maxim.top/LICENCE-MAXIM.md
//
//  ----------------------------------------------------------------------
    

#import "GroupHandleCell.h"

#import <floo-ios/BMXClient.h>
#import <floo-ios/BMXGroup.h>
#import <floo-ios/BMXRoster.h>
#import <floo-ios/BMXGroupApplication.h>

#import <UIImageView+WebCache.h>

@interface GroupHandleCell()
{
    UIImageView* _groupAvatar;
    UILabel* _groupInfo;
    UILabel* _groupMessage;
    
    UILabel* _actionStatus;
    
    UIButton* _acceptBtn;
    UIButton* _declineBtn;
    void (^_blockHandler)(BOOL isAccept);
    
    BMXRoster* _roster;
    BMXGroup* _group;
}
@end


@implementation GroupHandleCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initViews];
    }
    return self;
}

- (void) initViews
{
    _groupAvatar = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 50, 50)];
    _groupAvatar.layer.masksToBounds = YES;
    _groupAvatar.image = [UIImage imageNamed:@"group_default"];
    _groupAvatar.layer.cornerRadius = 5.0f;
    [self.contentView addSubview:_groupAvatar];
    
    
    _groupInfo = [[UILabel alloc] initWithFrame:CGRectMake(80, 15, MAXScreenW-55-15-55-15-15, 30)];
    _groupInfo.font = _actionStatus.font = [UIFont fontWithName:@"PingFangTC-Regular" size:16];
    [self.contentView addSubview:_groupInfo];
    
    _groupMessage = [[UILabel alloc] initWithFrame:CGRectMake(80, 45, MAXScreenW-55-15-55-15-15, 30)];
    _groupMessage.font = _actionStatus.font = [UIFont fontWithName:@"PingFangTC-Regular" size:12];
    [self.contentView addSubview:_groupMessage];
    
    _acceptBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [_acceptBtn setHidden:YES];
    _acceptBtn.frame = CGRectMake(MAXScreenW-55-15, 20, 55, 40);
    [_acceptBtn setBackgroundColor:[UIColor lh_colorWithHex:0xF7EB5C]];
    [_acceptBtn setTitle:@"同意" forState:UIControlStateNormal];
    [_acceptBtn addTarget:self action:@selector(touchedAccept) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_acceptBtn];
    
    _declineBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [_declineBtn setHidden:YES];
    _declineBtn.frame = CGRectMake(MAXScreenW-55-15-55-15, 20, 55, 40);
    [_declineBtn setTitle:@"拒绝" forState:UIControlStateNormal];
    [_declineBtn setBackgroundColor:[UIColor lh_colorWithHex:0xE8E8E8]];
    [_declineBtn addTarget:self action:@selector(touchedDecline) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_declineBtn];
    
    _actionStatus = [[UILabel alloc] initWithFrame:CGRectMake(MAXScreenW-55-15, 20, 55, 40)];
    [_actionStatus setHidden:YES];
    _actionStatus.textColor = [UIColor lh_colorWithHex:0x6B6B6B];
    _actionStatus.textAlignment = NSTextAlignmentRight;
    _actionStatus.font = [UIFont fontWithName:@"PingFangTC-Regular" size:12];
    [self.contentView addSubview:_actionStatus];
}

- (void) touchedAccept
{
    if(_blockHandler) {
        _blockHandler(true);
    }
}
- (void) touchedDecline
{
    if(_blockHandler) {
        _blockHandler(NO);
    }
}

- (void) cellInviteContentWithRoster:(BMXRoster*) roster group:(BMXGroup*) group inviteStatus:(BMXGroupInvitationStatus) status exp:(long long) expTime actionHandler:(void (^)(BOOL ret)) handler
{
    _blockHandler = handler;
    _roster = roster;
    _group = group;
    [self cellInvitationWithStatus: (NSInteger) status exp:(long long) expTime];
}



- (void) cellInvitationWithStatus: (NSInteger) status exp:(long long) expTime
{
    NSString* avatar = _group.avatarUrl;
    if(avatar != nil && ![avatar isEqualToString:@""]) {
        [_groupAvatar sd_setImageWithURL:[NSURL URLWithString:avatar] placeholderImage:[UIImage imageNamed:@"group_default"]];
    }
    _groupInfo.text = _group.name;
    NSDate* date = [NSDate date];
    NSTimeInterval currInterval = [date timeIntervalSince1970]*1000;
    NSString* rosterName = _roster.nickName;
    if(rosterName == nil || [rosterName isEqualToString:@""]) {
        rosterName = _roster.userName;
    }
    NSString* msg = @"邀请";
    _groupMessage.text = [NSString stringWithFormat:@"%@ 邀请您加入群 %@:%@", rosterName, _group.name, msg];
    if(status == 1) {
        [_actionStatus setHidden:NO];
        [_acceptBtn setHidden:YES];
        [_declineBtn setHidden:YES];
        [_actionStatus setText:@"已同意"];
    }else if(status == 2) {
        [_actionStatus setHidden:NO];
        [_acceptBtn setHidden:YES];
        [_declineBtn setHidden:YES];
        [_actionStatus setText:@"已拒绝"];
    }else if(currInterval > expTime) { //过期
        [_actionStatus setHidden:NO];
        [_acceptBtn setHidden:YES];
        [_declineBtn setHidden:YES];
        [_actionStatus setText:@"已过期"];
    }else if(status == 0) {
        [_actionStatus setHidden:YES];
        [_acceptBtn setHidden:NO];
        [_declineBtn setHidden:NO];
    }
}
////////////////////////////////////////////////

-(void) cellApplicationContentWithRoster:(BMXRoster*) roster group:(BMXGroup*) group applicationStatus:(BMXGroupApplicationStatus) status exp:(long long) expTime actionHandler:(void (^)(BOOL ret)) handler
{
    _blockHandler = handler;
    _group = group;
    _roster = roster;
    [self cellApplyWithStatus: (BMXGroupApplicationStatus) status exp:(long long) expTime];
}

- (void) cellApplyWithStatus: (BMXGroupApplicationStatus) status exp:(long long) expTime
{
    NSString* avatar = _group.avatarUrl;
    if(avatar != nil && ![avatar isEqualToString:@""]) {
        [_groupAvatar sd_setImageWithURL:[NSURL URLWithString:avatar] placeholderImage:[UIImage imageNamed:@"group_default"]];
    }
    _groupInfo.text = _group.name;
    NSDate* date = [NSDate date];
    NSTimeInterval currInterval = [date timeIntervalSince1970]*1000;
    NSString* rosterName = _roster.nickName;
    if(rosterName == nil || [rosterName isEqualToString:@""]) {
        rosterName = _roster.userName;
    }
    NSString* msg = @"";
    _groupMessage.text = [NSString stringWithFormat:@"%@ 申请加入群 %@:%@", rosterName, _group.name, msg];
    if(status == BMXGroupApplicationStatusAccepted) {
        [_actionStatus setHidden:NO];
        [_acceptBtn setHidden:YES];
        [_declineBtn setHidden:YES];
        [_actionStatus setText:@"已同意"];
    }else if(status == BMXGroupApplicationStatusDeclined) {
        [_actionStatus setHidden:NO];
        [_acceptBtn setHidden:YES];
        [_declineBtn setHidden:YES];
        [_actionStatus setText:@"已拒绝"];
    }else if(currInterval > expTime) { //过期
        [_actionStatus setHidden:NO];
        [_acceptBtn setHidden:YES];
        [_declineBtn setHidden:YES];
        [_actionStatus setText:@"已过期"];
    }else if(status == BMXGroupApplicationStatusPending) {
        [_actionStatus setHidden:YES];
        [_acceptBtn setHidden:NO];
        [_declineBtn setHidden:NO];
    }
}

+ (CGFloat) cellHeight
{
    return 80;
}





@end
