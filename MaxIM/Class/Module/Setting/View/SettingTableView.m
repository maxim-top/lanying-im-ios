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
#import <floo-ios/BMXUserProfile.h>
#import <floo-ios/BMXClient.h>
#import "IMAcountInfoStorage.h"
#import "TitleSwitchTableViewCell.h"
#import <floo-ios/BMXMessageSetting.h>
#import "AppDelegate.h"
#import "DeviceManagmentViewController.h"
#import "UIView+BMXframe.h"
#import "CodeImageViewController.h"
#import "AboutUsViewController.h"
#import "ConsoleAppIDStorage.h"
#import "AccountMangementViewController.h"

#import <ZXingObjC.h>

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
@property (nonatomic, strong) UILabel *idLabel;
@property (nonatomic, strong) UILabel *nickNameLabel;
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
    MAXLog(@"%@", configDic);
    NSMutableArray *dataArray = [NSMutableArray array];
    for (NSDictionary *dic in configDic[@"cells"]) {
        [dataArray addObject:dic];
    }
    MAXLog(@"%@", dataArray);
    return dataArray;
}

- (void)logoutclick{
    [[BMXClient sharedClient] signOutWithcompletion:^(BMXError *error) {
        if (!error) {
            
            [ConsoleAppIDStorage clearObject];
            [[BMXClient sharedClient] changeAppID:@"welovemaxim"];
            
            [HQCustomToast showDialog:@"退出成功"];
            
            [self.avatarImageView sd_setImageWithURL:nil placeholderImage:[UIImage imageNamed:@"profileavatar"]];
            self.nameLabel.text = @"请登录";
            [self reloadData];
            [IMAcountInfoStorage clearObject];
            
            AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
            [appDelegate userLogout];
        } else {
            [HQCustomToast showDialog:@"退出失败"];
        }
    }];

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
    self.profile = profile;
    [self reloadData];
    self.nameLabel.text = [profile.nickName length] ? [NSString stringWithFormat:@"%@", profile.nickName] : @"点击设置昵称";
    self.nickNameLabel.text = [NSString stringWithFormat:@"用户名：%@", profile.userName];
    [self.nickNameLabel sizeToFit];

    self.idLabel.text = [NSString stringWithFormat:@"ID: %lld", profile.userId];
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
        [[[BMXClient sharedClient] userService] downloadAvatarWithProfile:profile thumbnail:YES  progress:^(int progress, BMXError *error) {
            
        } completion:^(BMXUserProfile *profile, BMXError *error) {
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
    
    
//    NSString *data = [NSString stringWithFormat:@"R_%lld", profile.userId];
//    if (data == 0) return;
//
//    ZXMultiFormatWriter *writer = [[ZXMultiFormatWriter alloc] init];
//    ZXBitMatrix *result = [writer encode:data
//                                  format:kBarcodeFormatQRCode
//                                   width:self.codeButton.frame.size.width
//                                  height:self.codeButton.frame.size.width
//                                   error:nil];
//
//    if (result) {
//        ZXImage *image = [ZXImage imageWithMatrix:result];
//        [self.codeButton setBackgroundImage:[UIImage imageWithCGImage:image.cgimage] forState:UIControlStateNormal];
//    } else {
//        [self.codeButton setBackgroundImage:nil forState:UIControlStateNormal];
//
//    }
//    self.codeButton.backgroundColor = [UIColor clearColor];
//
    [self.codeButton setImage:[UIImage imageNamed:@"codeicon"] forState:UIControlStateNormal];
    [self.nameLabel sizeToFit];
    self.codeButton.bmx_left = self.nameLabel.bmx_right + 10;
    self.codeButton.bmx_centerY =  self.nameLabel.bmx_centerY ;

}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TitleSwitchTableViewCell *cell = [TitleSwitchTableViewCell cellWithTableView:tableView];
    NSDictionary *dic = self.cellDataArray[indexPath.row];
    cell.titleLabel.text = dic[@"type"];
    cell.delegate = self;
    cell.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:16];
    if ([dic[@"control"] isEqualToString:@"0"]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [cell.mswitch setHidden:YES];
    } else {
        [cell.mswitch setHidden:NO];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    if ([cell.titleLabel.text isEqualToString:@"接受新消息通知"]) {
        [cell.mswitch setOn:self.profile.messageSetting.mPushEnabled];
    } else if ([cell.titleLabel.text isEqualToString:@"震动"]) {
        [cell.mswitch setOn:self.profile.messageSetting.mNotificationVibrate];
    } else if ([cell.titleLabel.text isEqualToString:@"声音"]) {
        [cell.mswitch setOn:self.profile.messageSetting.mNotificationSound];
    } else if ([cell.titleLabel.text isEqualToString:@"是否自动下载缩略图附件"]) {
        [cell.mswitch setOn:self.profile.messageSetting.mAutoDownloadAttachment];
    } else if ([cell.titleLabel.text isEqualToString:@"是否自动接受群邀请"]) {
        [cell.mswitch setOn:self.profile.isAutoAcceptGroupInvite];
    } else if ([cell.titleLabel.text isEqualToString:@"是否推送详情"]) {
        [cell.mswitch setOn:self.profile.messageSetting.mPushDetail];
    } else if ([cell.titleLabel.text isEqualToString:@"关于我们"]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else if ([cell.titleLabel.text isEqualToString:@"设置推送昵称"]) {
        cell.contentLabel.text = self.profile.messageSetting.pushNickname;
        cell.contentLabel.right = MAXScreenW - 50;
    }
    return cell;
}

- (void)cellDidchangeSwitchStatus:(UISwitch *)mswtich cell:(TitleSwitchTableViewCell *)cell {
    NSIndexPath *indexPath = [self indexPathForCell:cell];
    NSDictionary *dic = self.cellDataArray[indexPath.row];
    NSString *str = dic[@"type"];
    BOOL state = mswtich.on ? YES : NO;
    
   if ([str isEqualToString:@"接受新消息通知"]) {
        [[[BMXClient sharedClient] userService] setEnablePushStatus:state completion:^(BMXError *error) {
            if (!error) {
                [HQCustomToast showDialog:@"设置成功"];
            }
        }];
    } else if ([str isEqualToString:@"震动"]) {
        [[[BMXClient sharedClient] userService] setNotificationVibrate:state completion:^(BMXError *error) {
            if (!error) {
                [HQCustomToast showDialog:@"设置成功"];
            }
        }];
    } else if ([str isEqualToString:@"声音"]) {
        [[[BMXClient sharedClient] userService] setNotificationSound:state completion:^(BMXError *error) {
            if (!error) {
                [HQCustomToast showDialog:@"设置成功"];
            }
        }];
    } else if ([str isEqualToString:@"是否推送详情"]) {
        [[[BMXClient sharedClient] userService] setEnablePushDetail:state completion:^(BMXError *error) {
            if (!error) {
                [HQCustomToast showDialog:@"设置成功"];
            }
        }];
    } else if ([str isEqualToString:@"是否自动下载缩略图附件"]) {
        [[[BMXClient sharedClient] userService] setAutoDownloadAttachment:state completion:^(BMXError *error) {
            if (!error) {
                [HQCustomToast showDialog:@"设置成功"];
            }
        }];
    } else if ([str isEqualToString:@"是否自动接受群邀请"]) {
        [[[BMXClient sharedClient] userService] setAutoAcceptGroupInvite:state completion:^(BMXError *error) {
            if (!error) {
                [HQCustomToast showDialog:@"设置成功"];
            }
        }];
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    MAXLog(@"%lu", self.cellDataArray.count);
    return self.cellDataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 158.0 / 3.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = self.cellDataArray[indexPath.row];
    NSString *str = [NSString stringWithFormat:@"%@", dic[@"type"]];
    if ([str isEqualToString:@"切换账号"]) {
        AccountMangementViewController *vc = [[AccountMangementViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.currentViewController.navigationController pushViewController:vc animated:YES];
    } else if ([str isEqualToString:@"黑名单列表"]) {
        MAXBlackListViewController *vc = [[MAXBlackListViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.currentViewController.navigationController pushViewController:vc animated:YES];
    } else if ([str isEqualToString:@"设备管理"]){
        DeviceManagmentViewController *vc = [[DeviceManagmentViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.currentViewController.navigationController pushViewController:vc animated:YES];
    } else if ([str isEqualToString:@"关于我们"]) {
        AboutUsViewController *vc = [[AboutUsViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.currentViewController.navigationController pushViewController:vc animated:YES];
        
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
    [self nickNameLabel];
    [self idLabel];
//    [self subTitleLabel];
    [self avatarImageView];
    [self editImageView];
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
        [_logoutButton setTitle:@"退出" forState:UIControlStateNormal];
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
        _avatarImageView.bmx_top =  self.headerView.size.height - 95 - 18;
        _avatarImageView.bmx_right = MAXScreenW - 36;
        _avatarImageView.image = [UIImage imageNamed:@"mine_avater_placoholder"];
        
    }
    return _avatarImageView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        [self.headerView addSubview:_nameLabel];
        _nameLabel.text = @"Nick";
        _nameLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:26];
        _nameLabel.textColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1/1.0];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        [_nameLabel sizeToFit];
        
        CGFloat nameLabelleft = 36;

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


- (UILabel *)idLabel {
    if (!_idLabel) {
        _idLabel = [[UILabel alloc] init];
        [self.headerView addSubview:_idLabel];
        _idLabel.text = @"";
        _idLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
        _idLabel.textColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1/1.0];
        _idLabel.textAlignment = NSTextAlignmentLeft;
        [_idLabel sizeToFit];
        
        CGFloat nameLabelleft = 36;
        
        _idLabel.size = CGSizeMake(80,20);
        _idLabel.bmx_top =  _nickNameLabel.bmx_bottom + 5;
        _idLabel.bmx_left = nameLabelleft;
        
    }
    return _idLabel;
}

- (UILabel *)nickNameLabel {
    if (!_nickNameLabel) {
        _nickNameLabel = [[UILabel alloc] init];
        [self.headerView addSubview:_nickNameLabel];
        _nickNameLabel.text = @"nick";
        _nickNameLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
        _nickNameLabel.textColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1/1.0];
        _nickNameLabel.textAlignment = NSTextAlignmentLeft;
        [_nickNameLabel sizeToFit];
        
        CGFloat nameLabelleft = 36;
        
        _nickNameLabel.size = CGSizeMake(80,20);
        _nickNameLabel.bmx_top =  _nameLabel.bmx_bottom + 15;
        _nickNameLabel.bmx_left = nameLabelleft;
        
    }
    return _nickNameLabel;
}

@end
