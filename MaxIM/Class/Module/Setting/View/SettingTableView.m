//
//  SettingTableView.m
//  BlockMessage
//
//  Created by hyt on 2018/7/22.
//  Copyright © 2018年 HYT. All rights reserved.
//

#import "SettingTableView.h"
#import "UIView+BMXframe.h"
#import "MAXBlackListViewController.h"
#import "ProfileSettingViewController.h"
#import <UIImageView+WebCache.h>
#import "IMAcountInfoStorage.h"
#import "TitleSwitchTableViewCell.h"
#import "AppDelegate.h"
#import "DeviceManagmentViewController.h"
#import "UIView+BMXframe.h"
#import "CodeImageViewController.h"
#import "AboutUsViewController.h"
#import "AccountMangementViewController.h"
#import "AppIDManager.h"
#import "LanyingLangManager.h"
#import "MaxGlobalTool.h"
#import "IMAcount.h"
#import "IMAcountInfoStorage.h"
#import <floo-ios/floo_proxy.h>
#include "TextRenderStorage.h"

//#import <ZXingObjC.h>
static CGFloat nameLabelleft = 36;

@interface SettingTableView()<UITableViewDelegate,UITableViewDataSource, TitleSwitchTableViewCellDelegate>

@property (nonatomic, strong) NSArray *titleArray;
@property (nonatomic, strong) UIView *footView;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIImageView *headerImageView;
@property (nonatomic, strong) UIButton *logoutButton;
@property (nonatomic, strong) UIImageView *editImageView;
@property (nonatomic, strong) UIImageView *codeImageView;
@property (nonatomic, strong) UIButton *codeButton;
@property (nonatomic, strong) BMXUserProfile *profile;
@property (nonatomic, strong) UILabel *idLabelCaption;
@property (nonatomic, strong) CopyableLabel *idLabel;
@property (nonatomic, strong) UILabel *nickNameLabelCaption;
@property (nonatomic, strong) CopyableLabel *nickNameLabel;
//@property (nonatomic, strong) UILabel *subTitleLabel;

@end

@implementation SettingTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    if (self = [super initWithFrame:frame style:style]) {
        [self p_configOwnProperties];
        self.dataSource = self;
        self.delegate = self;
        
        self.tableHeaderView = self.headerView;
        self.tableFooterView = self.footView;
        self.tableFooterView.bmx_height = 50.f;
        
        self.backgroundColor = BMXCOLOR_HEX(0xf8f8f8);
        
        self.estimatedRowHeight = 0;
        self.estimatedSectionHeaderHeight = 0;
        self.estimatedSectionFooterHeight = 0;
        
        self.cellDataArray = [NSArray arrayWithArray:[self getSettingConfigDataArray]];
        MAXLog(@"%ld", self.cellDataArray.count);
    }
    return self;
}

#pragma mark - data
- (NSArray *)getSettingConfigDataArray {
    NSDictionary *configDic = [NSDictionary dictionaryWithDictionary:[self readLocalFileWithName:@"setting"]];
    NSMutableArray *dataArray = [NSMutableArray array];
    for (NSDictionary *dic in configDic[@"cells"]) {
        [dataArray addObject:dic];
    }
    return dataArray;
}

- (void)logoutclick{
    [HQCustomToast showWating];
    [[BMXClient sharedClient] signOutWithUid:(NSInteger)self.profile.userId ignoreUnbindDevice:NO completion:^(BMXError * _Nonnull error) {

        if (!error) {
            [HQCustomToast hideWating];
            
            [self dealWithLogout];
        } else {
            
            [[BMXClient sharedClient] signOutWithUid:(NSInteger)self.profile.userId ignoreUnbindDevice:YES completion:^(BMXError * _Nonnull error) {
                [self dealWithLogout];
            }];
            
            [HQCustomToast hideWating];
        }
    }];

}

- (void)dealWithLogout {
    [AppIDManager clearAppid];
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate reloadAppID:BMXAppID];
    
    [HQCustomToast showDialog:NSLocalizedString(@"Quit_successfully", @"退出成功")];
    
    [self.avatarImageView sd_setImageWithURL:nil placeholderImage:[UIImage imageNamed:@"profileavatar"]];
    self.nameLabel.text = NSLocalizedString(@"login_pls", @"请登录");
    [self reloadData];
    [IMAcountInfoStorage clearObject];
    
    [appDelegate userLogout];
}

- (void)tapCodeImageView:(UITapGestureRecognizer*)tap {
    MAXLog(@"点击显示二维码");
    CodeImageViewController *vc = [[CodeImageViewController alloc] initWithProfile:self.profile];
    vc.hidesBottomBarWhenPushed = YES;
    [self.viewController.navigationController pushViewController:vc animated:YES];
}

- (NSDictionary *)readLocalFileWithName:(NSString *)name {
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"json"];
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    return [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
}

- (void)clickHeaderView {
    ProfileSettingViewController *vc = [[ProfileSettingViewController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.currentViewController.navigationController pushViewController:vc animated:YES];
}

- (void)p_configOwnProperties {
    [self setupHeaderView];
    [self setupFooterView];
    [self registerClass:[UITableViewCell class] forCellReuseIdentifier:@"settingCell"];
}

- (void)refeshProfile:(BMXUserProfile *)profile {
    const int MAX_NICKNAME_LENGTH = 12;
    self.profile = profile;
    [self reloadData];
    NSString *nickname = profile.nickname;
    if (nickname.length > MAX_NICKNAME_LENGTH) {
        nickname = [NSString stringWithFormat:@"%@...", [nickname substringToIndex: MAX_NICKNAME_LENGTH]];
    }
    self.nameLabel.text = [profile.nickname length] ? [NSString stringWithFormat:@"%@", nickname] : NSLocalizedString(@"Click_to_set_nickname", @"点击设置昵称");
    self.nickNameLabel.text = profile.username;
    [self.nickNameLabel sizeToFit];

    self.idLabel.text = [NSString stringWithFormat:@"%lld", profile.userId];
    [self.idLabel sizeToFit];
//    if ([profile.publicInfoJson length] > 0) {
//        self.subTitleLabel.text = [NSString stringWithFormat:@"个性签名：%@", profile.publicInfoJson];
//
//    } else {
//        self.subTitleLabel.text = @"个性签名：赶快去更新签名吧";
//
//    }
//    [self.subTitleLabel sizeToFit];

    
    UIImage *avarat = [UIImage imageWithContentsOfFile:profile.avatarThumbnailPath];
    if (avarat) {
        self.avatarImageView.image  = avarat;
    }else {
        [[[BMXClient sharedClient] userService] downloadAvatarWithProfile:profile thumbnail:YES  callback:^(int progress) {
            
        } completion:^(BMXError *error) {
            if (error== nil) {
                UIImage *image = [UIImage imageWithContentsOfFile:profile.avatarThumbnailPath];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.avatarImageView.image  = image;
                });
                
            } else {
                self.avatarImageView.image  = [UIImage imageNamed:@"mine_avater_placoholder"];

            }
            
        }];
    }

    [self.codeButton setImage:[UIImage imageNamed:@"codeicon"] forState:UIControlStateNormal];
    [self.nameLabel sizeToFit];
    self.codeButton.bmx_left = self.nameLabel.bmx_right + 10;
    self.codeButton.bmx_centerY =  self.nameLabel.bmx_centerY ;

}

#pragma mark == public functions ...
-(UIView*) sectionHeaderViewWithTitle: (NSString*) title
{
    UIView* sv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MAXScreenW, 40)];
    sv.backgroundColor = [UIColor lh_colorWithHex:0xf8f8f8];
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(15, 5, MAXScreenW-100, 30)];
    label.text = title;
    label.font = [UIFont fontWithName:@"PingFangSC-Medium" size:12];
    label.textColor = [UIColor colorWithRed:100/255.0 green:100/255.0 blue:100/255.0 alpha:1/1.0];
    [sv addSubview:label];
    return sv;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

-(UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return [self sectionHeaderViewWithTitle:@""];
        case 1:
            return [self sectionHeaderViewWithTitle:NSLocalizedString(@"In-app_Notification", @"应用内通知")];
        case 2:
            return [self sectionHeaderViewWithTitle:@""];
        default:
            return [self sectionHeaderViewWithTitle:@""];
    }
    return [self sectionHeaderViewWithTitle:@""];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TitleSwitchTableViewCell *cell = [TitleSwitchTableViewCell cellWithTableView:tableView];
    NSInteger previousSectionsRows = 0;
    for (int i=0; i<indexPath.section; i++) {
        NSInteger rows = [self tableView:self numberOfRowsInSection:i];
        previousSectionsRows += rows;
    }
    NSDictionary *dic = self.cellDataArray[previousSectionsRows + indexPath.row];
    cell.titleLabel.text = dic[@"type"];
    cell.delegate = self;
    cell.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:16];
    if ([dic[@"control"] isEqualToString:@"0"] || [dic[@"control"] isEqualToString:@"alert"]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [cell.mswitch setHidden:YES];
    } else {
        [cell.mswitch setHidden:NO];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    if ([cell.titleLabel.text isEqualToString:NSLocalizedString(@"Accept_new_message_notification", @"接受推送提醒")]) {
        [cell.mswitch setOn:self.profile.messageSetting.getMPushEnabled];
    } else if ([cell.titleLabel.text isEqualToString:NSLocalizedString(@"Vibrate", @"震动")]) {
        [cell.mswitch setOn:self.profile.messageSetting.getMNotificationVibrate];
    } else if ([cell.titleLabel.text isEqualToString:NSLocalizedString(@"Sound", @"声音")]) {
        [cell.mswitch setOn:self.profile.messageSetting.getMNotificationSound];
    } else if ([cell.titleLabel.text isEqualToString:NSLocalizedString(@"Whether_to_render_text_in_markdown", @"自动识别Markdown消息")]) {
        NSString *renderType  = [TextRenderStorage loadObject];
        [cell.mswitch setOn:![renderType isEqualToString:@"0"]];
    } else if ([cell.titleLabel.text isEqualToString:NSLocalizedString(@"Whether_to_download_thumbnail_attachments_automatically", @"是否自动下载缩略图附件")]) {
        [cell.mswitch setOn:self.profile.messageSetting.getMAutoDownloadAttachment];
    } else if ([cell.titleLabel.text isEqualToString:NSLocalizedString(@"Whether_to_accept_group_invitation_automatically", @"是否自动接受群邀请")]) {
        [cell.mswitch setOn:self.profile.isAutoAcceptGroupInvite];
    } else if ([cell.titleLabel.text isEqualToString:NSLocalizedString(@"Whether_to_push_details", @"是否推送详情")]) {
        [cell.mswitch setOn:self.profile.messageSetting.getMPushDetail];
    }  else if ([cell.titleLabel.text isEqualToString:NSLocalizedString(@"About_Us", @"关于我们")]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else if ([cell.titleLabel.text isEqualToString:NSLocalizedString(@"Del_Account", @"删除账号")]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else if ([cell.titleLabel.text isEqualToString:NSLocalizedString(@"Set_push_nickname", @"设置推送昵称")]) {
        cell.contentLabel.text = self.profile.messageSetting.getMPushNickname;
        cell.contentLabel.right = MAXScreenW - 50;
    }
    if ([cell.titleLabel.text isEqualToString:NSLocalizedString(@"Language", @"语言")]) {
        NSString *currLan = [LanyingLangManager userLanguage];
        if (currLan.length == 0) {
            currLan = [NSLocale preferredLanguages].firstObject;
        }
        if ([currLan hasPrefix:@"en-"] || [currLan isEqualToString:@"en"]) {
            cell.contentLabel.text = [NSString stringWithFormat:NSLocalizedString(@"English", @"English")];
        } else {
            cell.contentLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Chinese", @"简体中文")];
        }
        [cell.mswitch setHidden:YES];
    } else {
        cell.contentLabel.text = @"";
    }
    return cell;
}

- (void)cellDidchangeSwitchStatus:(UISwitch *)mswtich cell:(TitleSwitchTableViewCell *)cell {
    NSIndexPath *indexPath = [self indexPathForCell:cell];
    NSInteger previousSectionsRows = 0;
    for (int i=0; i<indexPath.section; i++) {
        NSInteger rows = [self tableView:self numberOfRowsInSection:i];
        previousSectionsRows += rows;
    }
    NSDictionary *dic = self.cellDataArray[previousSectionsRows + indexPath.row];
    NSString *str = dic[@"type"];
    BOOL state = mswtich.on ? YES : NO;
    
   if ([str isEqualToString:NSLocalizedString(@"Accept_new_message_notification", @"接受推送提醒")]) {
        [[[BMXClient sharedClient] userService] setEnablePush:state completion:^(BMXError *error) {
            if (!error) {
                [HQCustomToast showDialog:NSLocalizedString(@"Set_successfully", @"设置成功")];
            }
        }];
    } else if ([str isEqualToString:NSLocalizedString(@"Vibrate", @"震动")]) {
        [[[BMXClient sharedClient] userService] setNotificationVibrate:state completion:^(BMXError *error) {
            if (!error) {
                [HQCustomToast showDialog:NSLocalizedString(@"Set_successfully", @"设置成功")];
            }
        }];
    } else if ([str isEqualToString:NSLocalizedString(@"Sound", @"声音")]) {
        [[[BMXClient sharedClient] userService] setNotificationSound:state completion:^(BMXError *error) {
            if (!error) {
                [HQCustomToast showDialog:NSLocalizedString(@"Set_successfully", @"设置成功")];
            }
        }];
    } else if ([str isEqualToString:NSLocalizedString(@"Whether_to_push_details", @"是否推送详情")]) {
        [[[BMXClient sharedClient] userService] setEnablePushDetaile:state completion:^(BMXError *error) {
            if (!error) {
                [HQCustomToast showDialog:NSLocalizedString(@"Set_successfully", @"设置成功")];
            }
        }];
    } else if ([str isEqualToString:NSLocalizedString(@"Whether_to_render_text_in_markdown", @"自动识别Markdown消息")]) {
        NSString *renderType  = [TextRenderStorage loadObject];
        NSString *newType = [renderType isEqualToString:@"0"] ? @"1" : @"0";
        [TextRenderStorage saveObject: newType];
    } else if ([str isEqualToString:NSLocalizedString(@"Whether_to_download_thumbnail_attachments_automatically", @"是否自动下载缩略图附件")]) {
        [[[BMXClient sharedClient] userService] setAutoDownloadAttachment:state completion:^(BMXError *error) {
            if (!error) {
                [HQCustomToast showDialog:NSLocalizedString(@"Set_successfully", @"设置成功")];
            }
        }];
    } else if ([str isEqualToString:NSLocalizedString(@"Whether_to_accept_group_invitation_automatically", @"是否自动接受群邀请")]) {
        [[[BMXClient sharedClient] userService] setAutoAcceptGroupInvite:state completion:^(BMXError *error) {
            if (!error) {
                [HQCustomToast showDialog:NSLocalizedString(@"Set_successfully", @"设置成功")];
            }
        }];
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 3;
        case 1:
            return 2;
        case 2:
            return 9;
        default:
            return 0;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 158.0 / 3.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.001f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 0.001f;
        case 1:
            return 35.0f;
        case 2:
            return 10;
        default:
            return 10;
    }
    return 10;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger previousSectionsRows = 0;
    for (int i=0; i<indexPath.section; i++) {
        NSInteger rows = [self tableView:self numberOfRowsInSection:i];
        previousSectionsRows += rows;
    }
    NSDictionary *dic = self.cellDataArray[previousSectionsRows + indexPath.row];
    NSString *str = [NSString stringWithFormat:@"%@", dic[@"type"]];
    if ([str isEqualToString:NSLocalizedString(@"Switch_account", @"切换账号")]) {
        AccountMangementViewController *vc = [[AccountMangementViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.currentViewController.navigationController pushViewController:vc animated:YES];
    } else if ([str isEqualToString:NSLocalizedString(@"Personal_profile", @"个人资料")]) {
        ProfileSettingViewController *vc = [[ProfileSettingViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.currentViewController.navigationController pushViewController:vc animated:YES];
    } else if ([str isEqualToString:NSLocalizedString(@"List_of_blacklists", @"黑名单列表")]) {
        MAXBlackListViewController *vc = [[MAXBlackListViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.currentViewController.navigationController pushViewController:vc animated:YES];
    } else if ([dic[@"type"] isEqualToString:NSLocalizedString(@"Language", @"语言")]) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Switch_language", @"设置语言") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
       
        UIAlertAction* action1 = [UIAlertAction actionWithTitle:NSLocalizedString(@"English", @"English") style:UIAlertActionStyleDefault                                                        handler:^(UIAlertAction * action) {
            [LanyingLangManager setUserLanguage:@"en"];
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [appDelegate userLogout];
            [[MAXGlobalTool share].rootViewController addIMListener];
        }];
        UIAlertAction* action2 = [UIAlertAction actionWithTitle:NSLocalizedString(@"Chinese", @"简体中文") style:UIAlertActionStyleDefault
            handler:^(UIAlertAction * action) {
            [LanyingLangManager setUserLanguage:@"zh-Hans"];
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [appDelegate userLogout];
            [[MAXGlobalTool share].rootViewController addIMListener];
       }];
       UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"取消") style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction * action) {
                                                             }];
        [alert addAction:action1];
        [alert addAction:action2];
        [alert addAction:cancelAction];
        [self.currentViewController presentViewController:alert animated:YES completion:nil];
        
    } else if ([str isEqualToString:NSLocalizedString(@"Device_management", @"设备管理")]){
        DeviceManagmentViewController *vc = [[DeviceManagmentViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.currentViewController.navigationController pushViewController:vc animated:YES];
    } else if ([str isEqualToString:NSLocalizedString(@"About_Us", @"关于我们")]) {
        AboutUsViewController *vc = [[AboutUsViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.currentViewController.navigationController pushViewController:vc animated:YES];
        
    } else if ([str isEqualToString:NSLocalizedString(@"Del_Account", @"删除账号")]) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Del_Account", @"删除账号") message:NSLocalizedString(@"Deletion_can_not_recover", @"账号删除后，您的所有数据都将擦除，不可恢复。确定要删除吗？") preferredStyle:UIAlertControllerStyleActionSheet];
       
        UIAlertAction* action1 = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", @"确定") style:UIAlertActionStyleDefault                                                        handler:^(UIAlertAction * action) {
            [HQCustomToast showWating];
            IMAcount *accout = [IMAcountInfoStorage loadObject];
            if (accout) {
                [[BMXClient sharedClient] deleteAccountWithPassword:accout.password completion:^(BMXError * _Nonnull error) {
                    if (!error) {
                        [HQCustomToast hideWating];
                        [self dealWithLogout];
                    }
                }];
            }
        }];
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"取消") style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction * action) {
                                                             }];
        [alert addAction:action1];
        [alert addAction:cancelAction];
        [self.currentViewController presentViewController:alert animated:YES completion:nil];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat width = self.frame.size.width; // 图片宽度
    UIImage *image = [UIImage imageNamed:@"Backgroud"];
    
    CGFloat yOffset = scrollView.contentOffset.y;  // 偏移的y值
    
    if (yOffset < 0) {
        
        CGFloat totalOffset = image.size.height + ABS(yOffset);
        
        CGFloat f = totalOffset / image.size.height;
        
        self.headerImageView.frame =  CGRectMake(- (width * f - width) / 2, yOffset, width * f, totalOffset); //拉伸后的图片的frame应该是同比例缩放。
        
    }
}
- (void)setupHeaderView {
    UIImage *image = [UIImage imageNamed:@"Backgroud"];

    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MAXScreenW, image.size.height + 18)];
    self.headerView.backgroundColor = BMXCOLOR_HEX(0xf8f8f8);

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickHeaderView)];
    [self.headerView addGestureRecognizer:tap];
    
    self.headerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Backgroud"]];
    self.headerImageView.frame = CGRectMake(0, 0, MAXScreenW, image.size.height);
    self.headerImageView.tag = 101;
    self.headerImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.headerImageView.clipsToBounds = YES;
    [self.headerView addSubview:self.headerImageView];
    
    [self nameLabel];
    [self codeButton];
    [self nickNameLabelCaption];
    [self nickNameLabel];
    [self idLabelCaption];
    [self idLabel];
//    [self subTitleLabel];
    [self avatarImageView];
}

- (void)setupFooterView {
    self.footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MAXScreenW, MaxNavHeight)];
    self.footView.backgroundColor = [UIColor whiteColor];
    
    [self logoutButton];
}

#pragma mark - lazy load
- (UIImageView *)editImageView {
    if (!_editImageView) {
        _editImageView = [[UIImageView alloc] init];
        [self.headerView addSubview:_editImageView];
        _editImageView.image = [UIImage imageNamed:@"edit"];
        
//        CGSize arrowImageViewSize = CGSizeMake(_editImageView.image.size.width, _editImageView.image.size.height);
        CGSize arrowImageViewSize = CGSizeMake(15, 15); // 临时

        _editImageView.bmx_right = MAXScreenW - 30;
        _editImageView.bmx_size = arrowImageViewSize;
        _editImageView.bmx_top = 20;
    }
    return _editImageView;
}

- (UIButton *)logoutButton {
    if (!_logoutButton) {
        _logoutButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_logoutButton addTarget:self action:@selector(logoutclick) forControlEvents:UIControlEventTouchUpInside];
        [self.footView addSubview:_logoutButton];
        [_logoutButton setTitle:NSLocalizedString(@"Quit", @"退出") forState:UIControlStateNormal];
        [_logoutButton setTitleColor:BMXCOLOR_HEX(0xff475a) forState:UIControlStateNormal];
        _logoutButton.titleLabel.font =  [UIFont fontWithName:@"PingFangSC-Regular" size:17];
        _logoutButton.bmx_size = CGSizeMake(80, 50);
        _logoutButton.bmx_centerX = MAXScreenW / 2.0;
        _logoutButton.bmx_centerY = 50 / 2.0;
    }
    return _logoutButton;
}

- (UIImageView *)avatarImageView {
    if (!_avatarImageView) {
     
        _avatarImageView = [[UIImageView alloc] init];
        [self.headerView addSubview:_avatarImageView];
    
        CGFloat avatarImageViewLeft = 15;
        CGSize avatarImageViewSize = CGSizeMake(100, 100);
        _avatarImageView.clipsToBounds = YES;
        _avatarImageView.layer.cornerRadius = 50;
        _avatarImageView.bmx_size = avatarImageViewSize;
        _avatarImageView.bmx_top =  self.headerView.size.height - 95 - 30;
        _avatarImageView.bmx_right = MAXScreenW - 16;
        _avatarImageView.image = [UIImage imageNamed:@"mine_avater_placoholder"];
        
    }
    return _avatarImageView;
}

- (CopyableLabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[CopyableLabel alloc] init];
        [self.headerView addSubview:_nameLabel];
        _nameLabel.text = @"Nick";
        _nameLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:20];
        _nameLabel.textColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1/1.0];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        [_nameLabel sizeToFit];
        
        _nameLabel.size = CGSizeMake(60,30);
        _nameLabel.bmx_centerY = 120 / 2.0 + 10 - 10;
        _nameLabel.bmx_left = nameLabelleft;
        
    }
    return _nameLabel;
}

- (UIButton *)codeButton {
    if (!_codeButton) {
        _codeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.headerView addSubview:_codeButton];
        CGFloat avatarImageViewLeft = 15;
        CGSize avatarImageViewSize = CGSizeMake(25, 25);
        _codeButton.bmx_size = avatarImageViewSize;
        _codeButton.bmx_centerY = _nameLabel.bmx_centerY ;
        _codeButton.bmx_left = _nameLabel.bmx_right + 8;
        [_codeButton addTarget:self action:@selector(tapCodeImageView:) forControlEvents:UIControlEventTouchUpInside];
        _codeButton.backgroundColor = [UIColor clearColor];
    }
    return _codeButton;
}


- (UILabel *)idLabelCaption {
    if (!_idLabelCaption) {
        _idLabelCaption = [[UILabel alloc] init];
        [self.headerView addSubview:_idLabelCaption];
        _idLabelCaption.text = @"ID:";
        _idLabelCaption.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
        _idLabelCaption.textColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1/1.0];
        _idLabelCaption.textAlignment = NSTextAlignmentLeft;
        [_idLabelCaption sizeToFit];
        
        _idLabelCaption.bmx_top =  _nickNameLabel.bmx_bottom + 5;
        _idLabelCaption.bmx_left = nameLabelleft;
        
    }
    return _idLabelCaption;
}

- (CopyableLabel *)idLabel {
    if (!_idLabel) {
        _idLabel = [[CopyableLabel alloc] init];
        [self.headerView addSubview:_idLabel];
        _idLabel.text = @"";
        _idLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
        _idLabel.textColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1/1.0];
        _idLabel.textAlignment = NSTextAlignmentLeft;
        [_idLabel sizeToFit];
        
        _idLabel.bmx_top =  _idLabelCaption.bmx_top;
        _idLabel.bmx_left = _idLabelCaption.bmx_right + 2;
        
    }
    return _idLabel;
}

- (UILabel *)nickNameLabelCaption {
    if (!_nickNameLabelCaption) {
        _nickNameLabelCaption = [[UILabel alloc] init];
        [self.headerView addSubview:_nickNameLabelCaption];
        _nickNameLabelCaption.text = NSLocalizedString(@"Username_colon", @"用户名：");
        _nickNameLabelCaption.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
        _nickNameLabelCaption.textColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1/1.0];
        _nickNameLabelCaption.textAlignment = NSTextAlignmentLeft;
        [_nickNameLabelCaption sizeToFit];
        
        _nickNameLabelCaption.bmx_top =  _nameLabel.bmx_bottom + 15;
        _nickNameLabelCaption.bmx_left = nameLabelleft;
        
    }
    return _idLabelCaption;
}

- (CopyableLabel *)nickNameLabel {
    if (!_nickNameLabel) {
        _nickNameLabel = [[CopyableLabel alloc] init];
        [self.headerView addSubview:_nickNameLabel];
        _nickNameLabel.text = @"";
        _nickNameLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
        _nickNameLabel.textColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1/1.0];
        _nickNameLabel.textAlignment = NSTextAlignmentLeft;
        [_nickNameLabel sizeToFit];
        
        _nickNameLabel.size = CGSizeMake(80,20);
        _nickNameLabel.bmx_top =  _nickNameLabelCaption.bmx_top;
        _nickNameLabel.bmx_left = _nickNameLabelCaption.bmx_right + 2;
        
    }
    return _nickNameLabel;
}

@end
