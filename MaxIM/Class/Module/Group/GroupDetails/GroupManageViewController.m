//
//  ----------------------------------------------------------------------
//   File    :  GroupManageViewController.m
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
    

#import "GroupManageViewController.h"
#import "GroupCommonCell.h"
#import "GroupOwnerTransterViewController.h"
#import "GroupBlackListViewController.h"
#import "GroupMuteListViewController.h"
#import "GroupApplyViewController.h"

#import <TZImagePickerController.h>
#import <floo-ios/floo_proxy.h>

#import "IMAcount.h"
#import "IMAcountInfoStorage.h"
#import "UIViewController+CustomNavigationBar.h"
#import "MAXUtils.h"

@interface GroupManageViewController ()<UITableViewDelegate, UITableViewDelegate>
{
    NSArray* _tableTitleArray;
    BOOL _isOwner;
}
@property (nonatomic ,strong) UITableView* tableView;
@property (nonatomic, strong) BMXUserProfile* profile;
@property (nonatomic,assign) BOOL isGroupBanned;
@property (nonatomic,assign) BOOL hideMemberInfo;
@end

@implementation GroupManageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _isOwner = [self isOwner];
    
    [self setNavigationBarTitle:NSLocalizedString(@"Group_settings", @"群设置") navLeftButtonIcon:@"blackback"];
    
    _tableTitleArray = @[NSLocalizedString(@"Upload_group_avatar", @"上传群头像"),
                         NSLocalizedString(@"Join_group_application", @"入群申请"),
                         NSLocalizedString(@"Group_message_notification_mode", @"群消息通知模式"),
                         NSLocalizedString(@"Join_group_approval_mode", @"入群审批模式"),
                         NSLocalizedString(@"Group_invitation_mode", @"邀请入群模式"),
                         NSLocalizedString(@"Blacklist_of_group_members", @"群成员黑名单"),
                         NSLocalizedString(@"Banned_group_members", @"群成员禁言"),
                         NSLocalizedString(@"Set_whether_to_send_read_acknowledgement", @"设置是否发送已读回执"),
                         NSLocalizedString(@"Group_owner_permission_transferred", @"群主管理权转让"),
                         NSLocalizedString(@"Ban_all_group_members", @"全群禁言"),
                         NSLocalizedString(@"Hide_member_info", @"隐藏群成员信息"),
                         ];
    [self initViews];
    [self getGroupDetailInfo];
    
}

-(void) initViews
{
    [self.view addSubview:self.tableView];
}

#pragma mark == tableview delegate
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger row = [self isOwner] ? _tableTitleArray.count : _tableTitleArray.count - 1;
    return row;
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    return 50;
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    GroupCommonCell* cell = [tableView dequeueReusableCellWithIdentifier:@"GroupCommonCell"];
    if(cell == nil) {
        cell = [[GroupCommonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GroupCommonCell"];
    }
    NSString* tableTitle = [_tableTitleArray objectAtIndex:row];
    if (row == 0) {
        [cell setMainText:tableTitle detailText:@"" switcherFlag:NO switcherTarget:nil switcherSelector:nil];
        [cell showAccesor:YES];
        [cell.avatarImageView setHidden:NO];
        
        if (self.group.avatarThumbnailPath > 0 && [[NSFileManager defaultManager] fileExistsAtPath:self.group.avatarThumbnailPath]) {
            cell.avatarImageView.image = [UIImage imageWithContentsOfFile:self.group.avatarThumbnailPath];
        }else {
            [[[BMXClient sharedClient] groupService] downloadAvatarWithGroup:self.group thumbnail:YES callback:^(int progress) {
            } completion:^(BMXError *error) {
                if (error == nil) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        UIImage *image = [UIImage imageWithContentsOfFile:self.group.avatarThumbnailPath];
                        cell.avatarImageView.image = image;
//                        self.group = group;
                        if (self.delegate && [self.delegate respondsToSelector:@selector(updateGroup:)]) {
                            [self.delegate updateGroup:self.group];
                        }
                    });
                }
            }];
        }
        
        
        
        
    }else if(row ==1) {
        [cell.avatarImageView setHidden:YES];

        [cell setMainText:tableTitle detailText:@"" switcherFlag:NO switcherTarget:nil switcherSelector:nil];
        [cell showAccesor:YES];
    }else if(row ==2) {
        [cell.avatarImageView setHidden:YES];

        NSString *modeStr = @"";
        switch (self.group.msgPushMode) {
            case BMXGroup_MsgPushMode_At:
                modeStr = NSLocalizedString(@"Notify_only_for_at_messages", @"只通知被@消息");
                break;
            case BMXGroup_MsgPushMode_None:
                modeStr = NSLocalizedString(@"No_notification_for_all_messages", @"所有消息都不通知");
                break;
            case BMXGroup_MsgPushMode_All:
                modeStr = NSLocalizedString(@"Notify_all_group_messages", @"通知所有群消息");
                break;
            case BMXGroup_MsgPushMode_Admin:
                modeStr = NSLocalizedString(@"Notify_only_for_admin_messages", @"只通知知管理员消息");
                break;
            case BMXGroup_MsgPushMode_AdminOrAt:
                modeStr = NSLocalizedString(@"Notify_only_for_admin_or_messages", @"只通知管理员或者被@消息");
                break;

            default:
                break;
        }
        [cell setMainText:tableTitle detailText:modeStr switcherFlag:NO switcherTarget:nil switcherSelector:nil];
        [cell showAccesor:YES];
    }else if(row ==3) {
        [cell.avatarImageView setHidden:YES];

        NSString *modeStr = @"";
        switch (self.group.joinAuthMode) {
            case BMXGroup_JoinAuthMode_Open:
                modeStr = NSLocalizedString(@"No_verification_required", @"无需验证");
                break;
            case BMXGroup_JoinAuthMode_NeedApproval:
                modeStr = NSLocalizedString(@"Admin_approval_required", @"需要管理员批准");
                break;
            case BMXGroup_JoinAuthMode_RejectAll:
                modeStr = NSLocalizedString(@"Reject_all_applications", @"拒绝所有申请");
                break;
                
            default:
                break;
        }
        [cell setMainText:tableTitle detailText:modeStr switcherFlag:NO switcherTarget:nil switcherSelector:nil];
        [cell showAccesor:YES];
    }else if(row ==4) {
        [cell.avatarImageView setHidden:YES];

        NSString *modeStr = @"";
        switch (self.group.inviteMode) {
            case BMXGroup_InviteMode_Open://
                modeStr = NSLocalizedString(@"All_group_members_can_modify", @"所有群成员都可以修改");
                break;
            case BMXGroup_InviteMode_AdminOnly:
                modeStr = NSLocalizedString(@"Admin_allowed_only", @"只有管理员可以");
                break;
            default:
                break;
        }
        [cell setMainText:tableTitle detailText:modeStr switcherFlag:NO switcherTarget:nil switcherSelector:nil];
        [cell showAccesor:YES];
    } else if(row ==5) {
        [cell.avatarImageView setHidden:YES];
        [cell setMainText:tableTitle detailText:@"" switcherFlag:NO switcherTarget:nil switcherSelector:nil];
        [cell showAccesor:YES];
    }else if(row ==6) {
        [cell.avatarImageView setHidden:YES];
        [cell setMainText:tableTitle detailText:@"" switcherFlag:NO switcherTarget:nil switcherSelector:nil];
        [cell showAccesor:YES];
        [cell showSepLine:NO];
    } else if (row == 7) {
        [cell showAccesor:NO];
        [cell setMainText:NSLocalizedString(@"Set_whether_to_send_read_acknowledgement", @"设置是否发送已读回执") detailText:nil switcherFlag:self.group.enableReadAck switcherTarget:self switcherSelector:@selector(p_configEnableRecieveAck)];
        
    } else if (row == 9) {
        [cell showAccesor:NO];
        long long currentTime = (long long) [[NSDate date] timeIntervalSince1970];
        self.isGroupBanned = self.group.banExpireTime > currentTime;
        [cell setMainText:NSLocalizedString(@"Ban_all_group_members", @"全群禁言") detailText:nil switcherFlag:self.isGroupBanned switcherTarget:self switcherSelector:@selector(p_configBanGroup)];

    } else if (row == 10) {
        [cell showAccesor:NO];
        self.hideMemberInfo = self.group.hideMemberInfo;
        [cell setMainText:NSLocalizedString(@"Hide_member_info", @"隐藏群成员信息") detailText:nil switcherFlag:self.hideMemberInfo switcherTarget:self switcherSelector:@selector(p_configHideMemberInfo)];

    } else {
        [cell.avatarImageView setHidden:YES];

        [cell setMainText:tableTitle detailText:@"" switcherFlag:NO switcherTarget:nil switcherSelector:nil];
        [cell showAccesor:YES];
        [cell showSepLine:NO];
    }
    
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    /**
     NSLocalizedString(@"Banned_group_members", @"群成员禁言"),
     NSLocalizedString(@"Blacklist_of_group_members", @"群成员黑名单"),
     NSLocalizedString(@"Group_owner_permission_transferred", @"群主管理权转让"),  5-7
     **/
    if (row == 0) {
        
        [self choiseImage];
        
    }else if(row == 1) { //入群申请
        GroupApplyViewController* ctrl = [[GroupApplyViewController alloc] initWithGroup:self.group hideMemberInfo:NO];
        [ctrl hidesBottomBarWhenPushed];
        [self.navigationController pushViewController:ctrl animated:YES];
    } else if (row == 3) {
        [self showAuthJoinAlert];
    } else if (row == 2) {
        [self showsetNotifyAlert];
    } else if (row == 4) {
        [self showInviteModeAlert];
    } else if(row == 5) {
        GroupBlackListViewController* ctrl = [[GroupBlackListViewController alloc] initWithGroup:self.group hideMemberInfo:NO];
        [ctrl hidesBottomBarWhenPushed];
        [self.navigationController pushViewController:ctrl animated:YES];
    } else if(row == 6) {
        GroupMuteListViewController* ctrl = [[GroupMuteListViewController alloc] initWithGroup:self.group hideMemberInfo:NO];
        [ctrl hidesBottomBarWhenPushed];
        [self.navigationController pushViewController:ctrl animated:YES];
    } else if(row == 7) {
        
        
    } else if(row == 8) {
        GroupOwnerTransterViewController* ctrl = [[GroupOwnerTransterViewController alloc] initWithGroup:self.group hideMemberInfo:NO];
        [ctrl hidesBottomBarWhenPushed];
        [self.navigationController pushViewController:ctrl animated:YES];
    }
//    else if (row == 6) {
//        [self showInvitedModeAlert];
//    }
}
- (void)showInvitedModeAlert {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Set_group_invitation_mode_for_invitee", @"设置被邀请入群模式") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction* action1 = [UIAlertAction actionWithTitle:NSLocalizedString(@"All_group_members_can_modify", @"所有群成员都可以修改") style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action) {
                                                        //响应事件
                                                       
                                                    }];
    UIAlertAction* action2 = [UIAlertAction actionWithTitle:NSLocalizedString(@"Admin_allowed_only", @"只有管理员可以") style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action) {
                                                        //响应事件
                                                        
                                                    }];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"取消") style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {
                                                             //响应事件
                                                             //
                                                             
                                                         }];
    [alert addAction:action1];
    [alert addAction:action2];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)choiseImage {
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:self];
    imagePickerVc.allowCrop = YES;
     imagePickerVc.cropRect = CGRectMake(0, (MAXScreenH - MAXScreenW) / 2 , MAXScreenW, MAXScreenW);
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        UIImage *image = [photos firstObject];
        NSData *imageData = UIImagePNGRepresentation(image);
        
        NSString *localPath = nil;
        long long time = [[NSDate date] timeIntervalSince1970] * 1000;
        if ([imageData length]) {
            NSString *dirName = [NSString stringWithFormat:@"%lld",time];
            NSString *base = [[[BMXClient sharedClient] chatService] attachmentDir];
            NSString *dir = [base stringByAppendingPathComponent:dirName];
            localPath = [NSString stringWithFormat:@"%@/%@",dir,@"img"];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            [fileManager createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
            [imageData writeToFile:localPath atomically:YES];
        }

        [[[BMXClient sharedClient] groupService] setAvatar:self.group avatarPath:localPath arg3:^(int progress) {
            
        } completion:^(BMXError *error) {
            if (!error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    GroupCommonCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    cell.avatarImageView.image = image;
                });
            }
        }];
    }];
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}

- (void)p_configEnableRecieveAck {
    [[[BMXClient sharedClient] groupService] setEnableReadAck:self.group enable:!self.group.enableReadAck completion:^(BMXError *error) {
        MAXLog(@"设置成功");
        if (error == nil) {
            [HQCustomToast showDialog:NSLocalizedString(@"Set_successfully", @"设置成功")];
            [self.tableView reloadData];
        } else {
            [HQCustomToast showDialog:error.description];
        }
        
    }];
}

- (void)p_configBanGroup {
    void(^aCompletionBlock)(BMXError *error) =^(BMXError *error) {
        if (error == nil) {
            MAXLog(@"设置成功");
            [HQCustomToast showDialog:NSLocalizedString(@"Set_successfully", @"设置成功")];
            [self.tableView reloadData];
        } else {
            [HQCustomToast showDialog:error.description];
        }
    };
    if (self.isGroupBanned){
        [[[BMXClient sharedClient] groupService] unbanGroupWithGroup:self.group completion:aCompletionBlock];
    }else{
        [[[BMXClient sharedClient] groupService] banGroupWithGroup:self.group duration:600 completion:aCompletionBlock];
    }
    self.isGroupBanned = !self.isGroupBanned;
}

-(void)showAlertForPermissionError {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"permission_required", @"权限不足") message:NSLocalizedString(@"permission_need_enabled", @"此业务需要开通，请联系App管理员。") preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", @"确定") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)p_configHideMemberInfo {
    bool hideMemberInfo = [MAXUtils getAppSwitch:@"hide_member_info"];
    if (hideMemberInfo) {
        [self showAlertForPermissionError];
        [self.tableView reloadData];
        return;
    }
    void(^aCompletionBlock)(BMXError *error) =^(BMXError *error) {
        if (error == nil) {
            MAXLog(@"设置成功");
            self.hideMemberInfo = !self.hideMemberInfo;
            [HQCustomToast showDialog:NSLocalizedString(@"Set_successfully", @"设置成功")];
            [self.tableView reloadData];
        } else {
            [HQCustomToast showDialog:error.description];
        }
    };
    [[[BMXClient sharedClient] groupService] setHideMemberInfo:self.group enable:!self.hideMemberInfo completion:aCompletionBlock];
}

- (void)showInviteModeAlert {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Set_group_invitation_mode_for_inviter", @"设置邀请入群模式") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction* action1 = [UIAlertAction actionWithTitle:NSLocalizedString(@"All_group_members", @"所有群成员") style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action) {
                                                        //响应事件
                                                        [self invitmodeWith:BMXGroup_InviteMode_Open];
                                                    }];
    UIAlertAction* action2 = [UIAlertAction actionWithTitle:NSLocalizedString(@"Admin_only", @"只有管理员") style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action) {
                                                        //响应事件
                                                       [self invitmodeWith:BMXGroup_InviteMode_AdminOnly];
                                                        
                                                    }];
   
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"取消") style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {
                                                             //响应事件
                                                             //
                                                             
                                                         }];
    [alert addAction:action1];
    [alert addAction:action2];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
    
    
}

- (void)showsetNotifyAlert {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Set_group_message_notification_mode", @"设置群消息通知模式") message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction* action1 = [UIAlertAction actionWithTitle:NSLocalizedString(@"Notify_all_group_messages", @"通知所有群消息") style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action) {
                                                        //响应事件
                                                         [self groupNofiyWith:BMXGroup_MsgPushMode_All];
                                                    }];
    UIAlertAction* action2 = [UIAlertAction actionWithTitle:NSLocalizedString(@"No_notification_for_all_messages", @"所有消息都不通知") style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action) {
                                                        //响应事件
                                                       [self groupNofiyWith:BMXGroup_MsgPushMode_None];
                                                        
                                                    }];
    UIAlertAction* action3 = [UIAlertAction actionWithTitle:NSLocalizedString(@"Notify_only_for_at_messages", @"只通知被@消息") style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action) {
                                                        //响应事件
                                                        [self groupNofiyWith:BMXGroup_MsgPushMode_At];
                                                    }];
    
    UIAlertAction* action4 = [UIAlertAction actionWithTitle:NSLocalizedString(@"Notify_only_for_admin_messages", @"只通知知管理员消息") style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action) {
                                                        //响应事件
                                                         [self groupNofiyWith:BMXGroup_MsgPushMode_Admin];
                                                    }];
    UIAlertAction* action5 = [UIAlertAction actionWithTitle:NSLocalizedString(@"Notify_only_for_admin_or_messages", @"只通知管理员或者被@消息") style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action) {
                                                        //响应事件
                                                       
                                                        [self groupNofiyWith:BMXGroup_MsgPushMode_AdminOrAt];
                                                    }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"取消") style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {
                                                             //响应事件
                                                             //
                                                             
                                                         }];
    [alert addAction:action1];
    [alert addAction:action2];
    [alert addAction:action3];
    [alert addAction:action4];
    [alert addAction:action5];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
    
    
}

- (void)showAuthJoinAlert {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Set_join_group_approval_mode", @"设置入群审批模式") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* action1 = [UIAlertAction actionWithTitle:NSLocalizedString(@"No_verification_required", @"无需验证") style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action) {
                                                        //响应事件
                                                        [self joinAuthWith:BMXGroup_JoinAuthMode_Open];
                                                        
                                                    }];
    UIAlertAction* action2 = [UIAlertAction actionWithTitle:NSLocalizedString(@"Admin_approval_required", @"需要管理员批准") style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action) {
                                                        //响应事件
                                                        [self joinAuthWith:BMXGroup_JoinAuthMode_NeedApproval];
                                                        
                                                    }];
    UIAlertAction* action3 = [UIAlertAction actionWithTitle:NSLocalizedString(@"Reject_all_applications", @"拒绝所有申请") style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action) {
                                                        //响应事件
                                                        [self joinAuthWith:BMXGroup_JoinAuthMode_RejectAll];
                                                        
                                                    }];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"取消") style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {
                                                             //响应事件
                                                             //
                                                             
                                                         }];
    [alert addAction:action1];
    [alert addAction:action2];
    [alert addAction:action3];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (void)groupNofiyWith:(BMXGroup_MsgPushMode)mode {
    [[[BMXClient sharedClient] groupService] setMsgPushMode:self.group mode:mode completion:^(BMXError *error) {
        if (!error) {
            [HQCustomToast showDialog:NSLocalizedString(@"Set_successfully", @"设置成功")];
            [self getGroupDetailInfo];
            [self.tableView reloadData];
            
        }else {
            [HQCustomToast showDialog:[NSString stringWithFormat:@"%@", error.description]];
            
        }
    }];
}

- (void)invitmodeWith:(BMXGroup_InviteMode)mode {
    [[[BMXClient sharedClient] groupService] setInviteMode:self.group mode:mode completion:^(BMXError *error) {
        if (!error) {
            [HQCustomToast showDialog:NSLocalizedString(@"Set_successfully", @"设置成功")];
            [self getGroupDetailInfo];
            [self.tableView reloadData];
            
        }else {
            [HQCustomToast showDialog:[NSString stringWithFormat:@"%@", error.description]];
            
        }
    }];
    
}

- (void)joinAuthWith:(BMXGroup_JoinAuthMode)mode {
    [[[BMXClient sharedClient] groupService] setJoinAuthMode:self.group mode:mode completion:^(BMXError *error) {
        if (error == nil) {
            [HQCustomToast showDialog:NSLocalizedString(@"Set_successfully", @"设置成功")];
            [self getGroupDetailInfo];
            [self.tableView reloadData];

        }else {
            [HQCustomToast showDialog:[NSString stringWithFormat:@"%@", error.description]];
        }
    }];
}

// 获取群详情
- (void)getGroupDetailInfo {
    [[[BMXClient sharedClient] groupService] fetchGroupByIdWithGroupId:self.group.groupId forceRefresh:YES completion:^(BMXGroup *group, BMXError *error) {
        self.group = group;
        [self.tableView reloadData];
    }];
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NavHeight, MAXScreenW, MAXScreenH - NavHeight) style:UITableViewStylePlain];
//        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, MAXScreenW, MAXScreenH - kNavBarHeight) style:UITableViewStyleGrouped];
        _tableView.backgroundColor = [UIColor lh_colorWithHex:0xffffff];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableHeaderView = [[UIView alloc] init];
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}

- (BOOL) isOwner
{
    NSString* ownerStr = [NSString stringWithFormat:@"%ld", self.group.ownerId] ;
    IMAcount* acc = [IMAcountInfoStorage loadObject];
    NSString* currentAccId = acc.usedId;
    return [ownerStr isEqualToString:currentAccId];
}



@end
