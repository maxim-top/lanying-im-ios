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
#import "BMXClient.h"
#import "IMAcount.h"
#import "IMAcountInfoStorage.h"
#import "UIViewController+CustomNavigationBar.h"

@interface GroupManageViewController ()<UITableViewDelegate, UITableViewDelegate>
{
    NSArray* _tableTitleArray;
    BOOL _isOwner;
}
@property (nonatomic ,strong) UITableView* tableView;
@property (nonatomic, strong) BMXUserProfile* profile;
@end

@implementation GroupManageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _isOwner = [self isOwner];
    
    [self setNavigationBarTitle:@"群设置" navLeftButtonIcon:@"blackback"];
    
    _tableTitleArray = @[@"上传群头像",
                         @"屏蔽群消息",
                         @"入群申请",
                         @"群消息通知模式",
                         @"入群审批模式",
                         @"邀请入群模式",
                         @"群成员黑名单",
                         @"群成员禁言",
                         @"设置是否发送已读回执",
                         @"群主管理权转让",
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
    NSInteger row = [self isOwner] ? 10 : 9;
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
            [[[BMXClient sharedClient] groupService] downloadAvatarWithGroup:self.group progress:^(int progress, BMXError *error) {
            } completion:^(BMXGroup *resultGroup, BMXError *error) {
                if (error == nil) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        UIImage *image = [UIImage imageWithContentsOfFile:resultGroup.avatarThumbnailPath];
                        cell.avatarImageView.image = image;
                        self.group = resultGroup;
                        if (self.delegate && [self.delegate respondsToSelector:@selector(updateGroup:)]) {
                            [self.delegate updateGroup:self.group];
                        }
                    });
                }
            }];
        }
        
        
        
        
    }else if(row == 1) {
        [cell.avatarImageView setHidden:YES];
        [cell showAccesor:YES];
        
        NSString *modeStr = @"";
        switch (self.group.msgMuteMode) {
            case BMXGroupMsgMuteModeNone:
                modeStr = @"接受并提醒消息";
                break;
            case BMXGroupMsgMuteModeMuteNotification:
                modeStr = @"接受但不提醒消息";
                break;
            case BMXGroupMsgMuteModeMuteChat:
                modeStr = @"不接收任何消息";
                break;
                
            default:
                break;
        }
        [cell setMainText:tableTitle detailText:modeStr switcherFlag:NO switcherTarget:nil switcherSelector:nil];
    }else if(row ==2) {
        [cell.avatarImageView setHidden:YES];

        [cell setMainText:tableTitle detailText:@"" switcherFlag:NO switcherTarget:nil switcherSelector:nil];
        [cell showAccesor:YES];
    }else if(row ==3) {
        [cell.avatarImageView setHidden:YES];

        NSString *modeStr = @"";
        switch (self.group.msgPushMode) {
            case BMXGroupMsgPushModeAt:
                modeStr = @"只通知被@消息";
                break;
            case BMXGroupMsgPushModeNone:
                modeStr = @"所有消息都不通知";
                break;
            case BMXGroupMsgPushModeAll:
                modeStr = @"通知所有群消息";
                break;
            case BMXGroupMsgPushModeAdmin:
                modeStr = @"只通知知管理员消息";
                break;
            case BMXGroupMsgPushModeAdminOrAt:
                modeStr = @"只通知管理员或者被@消息";
                break;

            default:
                break;
        }
        [cell setMainText:tableTitle detailText:modeStr switcherFlag:NO switcherTarget:nil switcherSelector:nil];
        [cell showAccesor:YES];
    }else if(row ==4) {
        [cell.avatarImageView setHidden:YES];

        NSString *modeStr = @"";
        switch (self.group.joinAuthMode) {
            case BMXGroupJoinAuthOpen:
                modeStr = @"无需验证";
                break;
            case BMXGroupJoinAuthNeedApproval:
                modeStr = @"需要管理员批准";
                break;
            case BMXGroupJoinAuthRejectAll:
                modeStr = @"拒绝所有申请";
                break;
                
            default:
                break;
        }
        [cell setMainText:tableTitle detailText:modeStr switcherFlag:NO switcherTarget:nil switcherSelector:nil];
        [cell showAccesor:YES];
    }else if(row ==5) {
        [cell.avatarImageView setHidden:YES];

        NSString *modeStr = @"";
        switch (self.group.inviteMode) {
            case BMXGroupInviteModeOpen://
                modeStr = @"所有群成员都可以修改";
                break;
            case BMXGroupInviteModeAdminOnly:
                modeStr = @"只有管理员可以";
                break;
            default:
                break;
        }
        [cell setMainText:tableTitle detailText:modeStr switcherFlag:NO switcherTarget:nil switcherSelector:nil];
        [cell showAccesor:YES];
    } else if(row ==6) {
        [cell.avatarImageView setHidden:YES];
        [cell setMainText:tableTitle detailText:@"" switcherFlag:NO switcherTarget:nil switcherSelector:nil];
        [cell showAccesor:YES];
    }else if(row ==7) {
        [cell.avatarImageView setHidden:YES];
        [cell setMainText:tableTitle detailText:@"" switcherFlag:NO switcherTarget:nil switcherSelector:nil];
        [cell showAccesor:YES];
        [cell showSepLine:NO];
    } else if (row == 8) {
        [cell setMainText:@"设置是否发送已读回执" detailText:nil switcherFlag:self.group.enableReadAck switcherTarget:self switcherSelector:@selector(p_configEnableRecieveAck)];
        
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
     @"群成员禁言",
     @"群成员黑名单",
     @"群主管理权转让",  5-7
     **/
    if (row == 0) {
        
        [self choiseImage];
        
    }else if(row == 1) {
        
        [self showPushModealert];
    }else if(row == 2) { //入群申请
        GroupApplyViewController* ctrl = [[GroupApplyViewController alloc] initWithGroup:self.group];
        [ctrl hidesBottomBarWhenPushed];
        [self.navigationController pushViewController:ctrl animated:YES];
    } else if (row == 4) {
        [self showAuthJoinAlert];
    } else if (row == 3) {
        [self showsetNotifyAlert];
    } else if (row == 5) {
        [self showInviteModeAlert];
    } else if(row == 6) {
        GroupBlackListViewController* ctrl = [[GroupBlackListViewController alloc] initWithGroup:self.group];
        [ctrl hidesBottomBarWhenPushed];
        [self.navigationController pushViewController:ctrl animated:YES];
    } else if(row == 7) {
        GroupMuteListViewController* ctrl = [[GroupMuteListViewController alloc] initWithGroup:self.group];
        [ctrl hidesBottomBarWhenPushed];
        [self.navigationController pushViewController:ctrl animated:YES];
    } else if(row == 8) {
        
        
    } else if(row == 9) {
        GroupOwnerTransterViewController* ctrl = [[GroupOwnerTransterViewController alloc] initWithGroup:self.group];
        [ctrl hidesBottomBarWhenPushed];
        [self.navigationController pushViewController:ctrl animated:YES];
    }
//    else if (row == 6) {
//        [self showInvitedModeAlert];
//    }
}
- (void)showInvitedModeAlert {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"设置被邀请入群模式" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction* action1 = [UIAlertAction actionWithTitle:@"所有群成员都可以修改" style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action) {
                                                        //响应事件
                                                       
                                                    }];
    UIAlertAction* action2 = [UIAlertAction actionWithTitle:@"只有管理员可以" style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action) {
                                                        //响应事件
                                                        
                                                    }];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel
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
        [[[BMXClient sharedClient] groupService] setAvatarWithGroup:self.group avatarData:imageData progress:^(int progress, BMXError *error) {
            
        } completion:^(BMXGroup *resultGroup, BMXError *error) {
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

- (void)showPushModealert {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"设置群消息屏蔽模式" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction* action1 = [UIAlertAction actionWithTitle:@"接受并提醒消息" style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action) {
                                                        //响应事件
                                                        [self setMsgMuteModeBy:BMXGroupMsgMuteModeNone];
//                                                        [self invitmodeWith:BMXGroupInviteModeOpen];
                                                    }];
    UIAlertAction* action2 = [UIAlertAction actionWithTitle:@"接受但不提醒消息" style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action) {
                                                        //响应事件
                                                        [self setMsgMuteModeBy:BMXGroupMsgMuteModeMuteNotification];

                                                    }];
    UIAlertAction* action3 = [UIAlertAction actionWithTitle:@"不接收任何消息" style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action) {
                                                        //响应事件
                                                        [self setMsgMuteModeBy:BMXGroupMsgMuteModeMuteChat];
                                                    }];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel
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

- (void)p_configEnableRecieveAck {
    [[[BMXClient sharedClient] groupService] setEnableReadAckWithGroup:self.group enable:!self.group.enableReadAck completion:^(BMXError *error) {
        MAXLog(@"设置成功");
        if (error == nil) {
            [HQCustomToast showDialog:@"设置成功"];
            [self.tableView reloadData];
        } else {
            [HQCustomToast showDialog:error.errorMessage];
        }
        
    }];
}

- (void)showInviteModeAlert {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"设置邀请入群模式" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction* action1 = [UIAlertAction actionWithTitle:@"所有群成员" style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action) {
                                                        //响应事件
                                                        [self invitmodeWith:BMXGroupInviteModeOpen];
                                                    }];
    UIAlertAction* action2 = [UIAlertAction actionWithTitle:@"只有管理员" style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action) {
                                                        //响应事件
                                                       [self invitmodeWith:BMXGroupInviteModeAdminOnly];
                                                        
                                                    }];
   
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel
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
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"设置群消息通知模式" message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction* action1 = [UIAlertAction actionWithTitle:@"通知所有群消息" style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action) {
                                                        //响应事件
                                                         [self groupNofiyWith:BMXGroupMsgPushModeAll];
                                                    }];
    UIAlertAction* action2 = [UIAlertAction actionWithTitle:@"所有消息都不通知" style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action) {
                                                        //响应事件
                                                       [self groupNofiyWith:BMXGroupMsgPushModeNone];
                                                        
                                                    }];
    UIAlertAction* action3 = [UIAlertAction actionWithTitle:@"只通知被@消息" style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action) {
                                                        //响应事件
                                                        [self groupNofiyWith:BMXGroupMsgPushModeAt];
                                                    }];
    
    UIAlertAction* action4 = [UIAlertAction actionWithTitle:@"只通知知管理员消息" style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action) {
                                                        //响应事件
                                                         [self groupNofiyWith:BMXGroupMsgPushModeAdmin];
                                                    }];
    UIAlertAction* action5 = [UIAlertAction actionWithTitle:@"只通知管理员或者被@消息" style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action) {
                                                        //响应事件
                                                       
                                                        [self groupNofiyWith:BMXGroupMsgPushModeAdminOrAt];
                                                    }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel
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
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"设置入群审批模式" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* action1 = [UIAlertAction actionWithTitle:@"无需验证" style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action) {
                                                        //响应事件
                                                        [self joinAuthWith:BMXGroupJoinAuthOpen];
                                                        
                                                    }];
    UIAlertAction* action2 = [UIAlertAction actionWithTitle:@"需要管理员批准" style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action) {
                                                        //响应事件
                                                        [self joinAuthWith:BMXGroupJoinAuthNeedApproval];
                                                        
                                                    }];
    UIAlertAction* action3 = [UIAlertAction actionWithTitle:@"拒绝所有申请" style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action) {
                                                        //响应事件
                                                        [self joinAuthWith:BMXGroupJoinAuthRejectAll];
                                                        
                                                    }];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel
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

- (void)groupNofiyWith:(BMXGroupMsgPushMode)mode {
    [[[BMXClient sharedClient] groupService] setMsgPushModeWithGroup:self.group mode:mode completion:^(BMXError *error) {
        if (!error) {
            [HQCustomToast showDialog:@"设置成功"];
            [self getGroupDetailInfo];
            [self.tableView reloadData];
            
        }else {
            [HQCustomToast showDialog:[NSString stringWithFormat:@"%@", error.errorMessage]];
            
        }
    }];
}

- (void)invitmodeWith:(BMXGroupInviteMode)mode {
    [[[BMXClient sharedClient] groupService] setInviteModeWithGroup:self.group mode:mode completion:^(BMXError *error) {
        if (!error) {
            [HQCustomToast showDialog:@"设置成功"];
            [self getGroupDetailInfo];
            [self.tableView reloadData];
            
        }else {
            [HQCustomToast showDialog:[NSString stringWithFormat:@"%@", error.errorMessage]];
            
        }
    }];
    
}

- (void)joinAuthWith:(BMXGroupJoinAuthMode)mode {
    [[[BMXClient sharedClient] groupService] setJoinAuthModeWithGroup:self.group joinAuthMode:mode completion:^(BMXError *error) {
        if (error == nil) {
            [HQCustomToast showDialog:@"设置成功"];
            [self getGroupDetailInfo];
            [self.tableView reloadData];

        }else {
            [HQCustomToast showDialog:[NSString stringWithFormat:@"%@", error.errorMessage]];
        }
    }];
}

-(void)setMsgMuteModeBy:(BMXGroupMsgMuteMode)mode {
    [[[BMXClient sharedClient] groupService] muteMessageByGroup:self.group msgMuteMode:mode completion:^(BMXError *error) {
        if (error == nil) {
            [HQCustomToast showDialog:@"设置成功"];
            [self getGroupDetailInfo];
            [self.tableView reloadData];
        }
    }];
}

// 获取群详情
- (void)getGroupDetailInfo {
    [[[BMXClient sharedClient] groupService] getGroupInfoByGroupId:self.group.groupId forceRefresh:YES completion:^(BMXGroup *group, BMXError *error) {
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
