//
//  GroupBaseInfoViewController.m
//  MaxIM
//
//  Created by 韩雨桐 on 2019/3/25.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "GroupBasicInfoViewController.h"
#import <floo-ios/BMXGroup.h>
#import "UIView+BMXframe.h"
#import <floo-ios/BMXClient.h>
#import "QRCodeGroupInviteApi.h"
#import "LHChatVC.h"

@interface GroupBasicInfoViewController ()

@property (nonatomic, strong) BMXGroup *group;
@property (nonatomic, strong) UIView *infoView;
@property (nonatomic, strong) UIImageView *avatarImageview;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIButton *confirmButton;
@property (nonatomic,copy) NSString *info;

@end

@implementation GroupBasicInfoViewController
- (instancetype)initWithGroup:(BMXGroup *)group info:(NSString *)info {
    if (self = [super init]) {
        self.group = group;
        self.info = info;
        MAXLog(@"%lld", self.group.groupId);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.title = @"加入群";
    [self setupSubview];
    
    self.avatarImageview.image = [UIImage imageNamed:@"contact_placeholder"];
    self.nameLabel.text = self.group.name;

    UIImage *avarat = [UIImage imageWithContentsOfFile:self.group.avatarThumbnailPath];
    if (avarat) {
        self.avatarImageview.image = avarat;
    }else {
        [[[BMXClient sharedClient] groupService] downloadAvatarWithGroup:self.group progress:^(int progress, BMXError *error) {
        } completion:^(BMXGroup *resultGroup, BMXError *error) {
            if (!error) {
                UIImage *image = [UIImage imageWithContentsOfFile:resultGroup.avatarThumbnailPath];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.avatarImageview.image = image;
                });
            }
        }];
    }
}

- (void)commitButtonClicked:(UIButton *)button {
    QRCodeGroupInviteApi *api = [[QRCodeGroupInviteApi alloc] initWithQRCodeInfo:self.info];
    [api startWithSuccessBlock:^(ApiResult * _Nullable result) {
        if ([result.code isEqualToString: @"20017"]) {
            [self.navigationController  popToRootViewControllerAnimated:NO];
            
            UITabBarController *bar =  (UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
            UINavigationController *currentNav =  (UINavigationController *)bar.selectedViewController;
            
            LHChatVC *vc = [[LHChatVC alloc] initWithGroupChat:self.group messageType:BMXMessageTypeGroup];
            vc.hidesBottomBarWhenPushed = YES;
            [currentNav pushViewController:vc animated:YES];
        } else  if ([result.code isEqualToString: @"20024"]) {
            [HQCustomToast showDialog:@"无权限加入群组"];
        } else if([result isOK]){
            [HQCustomToast showDialog:@"申请成功"];
            [self.navigationController  popToRootViewControllerAnimated:NO];
            
            UITabBarController *bar =  (UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
            UINavigationController *currentNav =  (UINavigationController *)bar.selectedViewController;
            
            LHChatVC *vc = [[LHChatVC alloc] initWithGroupChat:self.group messageType:BMXMessageTypeGroup];
            vc.hidesBottomBarWhenPushed = YES;
            [currentNav pushViewController:vc animated:YES];
        } else {
            [HQCustomToast showDialog:result.errmsg];
        }
        
    } failureBlock:^(NSError * _Nullable error) {
        [HQCustomToast showNetworkError];
    }];
}

- (void)setupSubview {
    self.infoView.x = 0;
    self.infoView.y = kNavBarHeight;
    self.infoView.width = MAXScreenW;
    self.infoView.height = 180;
    
    self.avatarImageview.x = MAXScreenW / 2.0 - 40;
    self.avatarImageview.y = 30;
    self.avatarImageview.width = 100;
    self.avatarImageview.height = 100;
    
    self.nameLabel.x = 30;
    self.nameLabel.y = self.avatarImageview.bmx_bottom + 10;
    self.nameLabel.bmx_width = MAXScreenW - 30 * 2.0;
    self.nameLabel.height = 40;

    self.contentLabel.x =  15;
    self.contentLabel.y = self.infoView.bmx_bottom + 30;
    self.contentLabel.height = 30;
    self.contentLabel.width = MAXScreenW - 30 /2.0;
    
    self.confirmButton.x =  48;
    self.confirmButton.y = self.contentLabel.bmx_bottom + 30;
    self.confirmButton.height = 55;;
    self.confirmButton.width = MAXScreenW - 48 * 2;;
}

- (UIImageView *)avatarImageview {
    if (_avatarImageview == nil) {
        _avatarImageview = [[UIImageView alloc] init];
        [self.infoView addSubview:self.avatarImageview];
    }
    return _avatarImageview;
}

- (UILabel *)nameLabel {
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.text = @"群名称";

        [self.infoView addSubview:self.nameLabel];
    }
    return _nameLabel;
}

- (UILabel *)contentLabel {
    if (_contentLabel == nil) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.text = @"确定要加入该群？";
        _contentLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:self.contentLabel];
    }
    return _contentLabel;
}

- (UIView *)infoView {
    if (_infoView == nil) {
        _infoView = [[UIView alloc] init];
//        _infoView.backgroundColor = BMXColorBackGround;
        [self.view addSubview:self.infoView];
    }
    return _infoView;
}

- (UIButton *)confirmButton {
    if (_confirmButton == nil) {
        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_confirmButton setTitle:@"确定" forState:UIControlStateNormal];
        _confirmButton.backgroundColor = BMXCOLOR_HEX(0xF7E700);
        [_confirmButton setTitleColor:BMXCOLOR_HEX(0x333333) forState:UIControlStateNormal];
        [_confirmButton addTarget:self action:@selector(commitButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        _confirmButton.layer.masksToBounds = YES;
        _confirmButton.layer.cornerRadius = 12;
        [self.view addSubview:self.confirmButton];
    }
    return _confirmButton;
}

@end
