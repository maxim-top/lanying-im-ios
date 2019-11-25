//
//  CodeImageViewController.m
//  MaxIM
//
//  Created by 韩雨桐 on 2019/3/20.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "CodeImageViewController.h"
#import "UIView+BMXframe.h"
#import <floo-ios/BMXUserProfile.h>
#import <ZXingObjC.h>
#import <floo-ios/BMXClient.h>
#import <floo-ios/BMXGroup.h>
#import "GroupQRcodeInfoApi.h"
#import "UIViewController+CustomNavigationBar.h"

@interface CodeImageViewController ()


@property (nonatomic, strong) UIView *cardView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *idLabel;
@property (nonatomic, strong) UIImageView *codeImageView;
@property (nonatomic, strong) UIImageView *avatarImageView;

@property (nonatomic, strong) BMXUserProfile *profile;
@property (nonatomic, strong) BMXGroup *group;

@end

@implementation CodeImageViewController

- (instancetype)initWithProfile:(BMXUserProfile *)profile {
    if (self = [super init]) {
        self.profile = profile;
    }
    return self;
}

- (instancetype)initWithGroup:(BMXGroup *)group {
    if (self = [super init]) {
        self.group = group;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setUpNavItem];
    [self setUpSubview];
    [self configContent];
}

- (void)configContent {
    if (self.profile != nil) {
        [self configUserCodeAndContent];
    } else {
        [self configGrouopCodeAndContent];
        [self getGroupQRCodeInfo];
    }
}

- (void)getGroupQRCodeInfo {
    GroupQRcodeInfoApi *api = [[GroupQRcodeInfoApi alloc] initWithGroupId:[ NSString stringWithFormat:@"%lld", self.group.groupId]];
    [HQCustomToast showWating];
    [api startWithSuccessBlock:^(ApiResult * _Nullable result) {
        [HQCustomToast hideWating];
        if (result.isOK) {
            NSString *qrCodeInfo = [NSString stringWithFormat:@"%@", result.resultData[@"qr_info"]];
            [self configGroupQRCodeWithQRCodeInfo:qrCodeInfo];
        } 
    } failureBlock:^(NSError * _Nullable error) {
        [HQCustomToast hideWating];
    }];
}

- (void)configGrouopCodeAndContent {
    self.idLabel.text = [NSString stringWithFormat:@"id : %lld", self.group.groupId];
    self.nameLabel.text = [NSString stringWithFormat:@"昵称 : %@", self.group.name];
    
    self.avatarImageView.image = [UIImage imageNamed:@"group_placeHo"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.group.avatarThumbnailPath]) {
        UIImage *avarat = [UIImage imageWithContentsOfFile:self.group.avatarThumbnailPath];
        self.avatarImageView.image = avarat;
    } else {
        [[[BMXClient sharedClient] groupService] downloadAvatarWithGroup:self.group progress:^(int progress, BMXError *error) {
            
        } completion:^(BMXGroup *resultGroup, BMXError *error) {
            if (error== nil) {
                UIImage *image = [UIImage imageWithContentsOfFile:resultGroup.avatarThumbnailPath];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.avatarImageView.image  = image;
                });
            }
        }];
    }
}

- (void)configGroupQRCodeWithQRCodeInfo:(NSString *)info {
    NSString *data = [self p_configGroupQRCodeInfo:info];
    if (![data length]) return;
    
    ZXMultiFormatWriter *writer = [[ZXMultiFormatWriter alloc] init];
    ZXBitMatrix *r = [writer encode:data
                                  format:kBarcodeFormatQRCode
                                   width:self.codeImageView.frame.size.width
                                  height:self.codeImageView.frame.size.width
                                   error:nil];
    if (info) {
        ZXImage *image = [ZXImage imageWithMatrix:r];
        self.codeImageView.image = [UIImage imageWithCGImage:image.cgimage];
    } else {
        self.codeImageView.image = nil;
    }
}

- (NSString *)p_configGroupQRCodeInfo:(NSString *)info {
    NSDictionary *dic  = @{@"source": @"app",
                           @"action": @"group",
                           @"info": @{
                                   @"group_id": [NSString stringWithFormat:@"%lld", self.group.groupId],
                                   @"info": info
                                   }
                           };
    return [self convertJSONWithDic:dic];
}


- (NSString *)p_configUserQRCodeInfo {
    NSDictionary *dic  = @{@"source": @"app",
                           @"action": @"profile",
                           @"info": @{
                                   @"uid": [NSString stringWithFormat:@"%lld", self.profile.userId],
                                   }
                           };
    return [self convertJSONWithDic:dic];
}



//字典转JSON
- (NSString *)convertJSONWithDic:(NSDictionary *)dic {
    NSError *err;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&err];
    if (err) {
        return @"字典转JSON出错";
    }
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (void)configUserCodeAndContent {
    self.idLabel.text = [NSString stringWithFormat:@"id : %lld", self.profile.userId];
    self.nameLabel.text = [NSString stringWithFormat:@"昵称 : %@", self.profile.userName];
    
    self.avatarImageView.image = [UIImage imageNamed:@"profileavatar"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.profile.avatarThumbnailPath]) {
        UIImage *avarat = [UIImage imageWithContentsOfFile:self.profile.avatarThumbnailPath];
        self.avatarImageView.image = avarat;
    } else {
        [[[BMXClient sharedClient] userService] downloadAvatarWithProfile:self.profile thumbnail:YES progress:^(int progress, BMXError *error) {
        } completion:^(BMXUserProfile *profile, BMXError *error) {
            if (error== nil) {
                UIImage *image = [UIImage imageWithContentsOfFile:profile.avatarThumbnailPath];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.avatarImageView.image  = image;
                });
            }
        }];
    }
    
    NSString *data = [self p_configUserQRCodeInfo];
    if (![data length]) return;
    ZXMultiFormatWriter *writer = [[ZXMultiFormatWriter alloc] init];
    ZXBitMatrix *r = [writer encode:data
                             format:kBarcodeFormatQRCode
                              width:self.codeImageView.frame.size.width
                             height:self.codeImageView.frame.size.width
                              error:nil];
    ZXImage *image = [ZXImage imageWithMatrix:r];
    self.codeImageView.image = [UIImage imageWithCGImage:image.cgimage];
}

- (void)setUpSubview {
    [self avatarImageView];
    [self cardView];
    [self nameLabel];
    [self idLabel];
    [self codeImageView];
}


- (UIImageView *)avatarImageView {
    if (!_avatarImageView) {
        _avatarImageView = [[UIImageView alloc] init];
        _avatarImageView.bmx_top =  25;
        _avatarImageView.bmx_left = 10;
        _avatarImageView.bmx_size = CGSizeMake(55, 55);
        [self.cardView addSubview:_avatarImageView];
    }
    return _avatarImageView;
}


- (UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.bmx_top = 15;
        _nameLabel.bmx_left = 80;
        _nameLabel.bmx_size = CGSizeMake(200, 40);
        _nameLabel.font = [UIFont systemFontOfSize:17];
        _nameLabel.text = @"张三";
        [self.cardView addSubview:_nameLabel];
    }
    return _nameLabel;
}

- (UILabel *)idLabel {
    if (!_idLabel) {
        _idLabel = [[UILabel alloc] init];
        _idLabel.bmx_top = _nameLabel.bmx_bottom + 5;
        _idLabel.bmx_left = 80;
        _idLabel.bmx_size = CGSizeMake(200, 30);
        _idLabel.text = @"我的id";
        _idLabel.font = [UIFont systemFontOfSize:14];
        [self.cardView addSubview:_idLabel];
    }
    return _idLabel;
}

- (UIImageView *)codeImageView {
    if (!_codeImageView) {
        _codeImageView = [[UIImageView alloc] init];
        _codeImageView.bmx_top = _idLabel.bmx_bottom + 10;
        _codeImageView.bmx_left = 30;
        _codeImageView.bmx_size = CGSizeMake(MAXScreenW - 100, MAXScreenW - 80);
        [self.cardView addSubview:_codeImageView];
    }
    return _codeImageView;
}

- (UIView *)cardView {
    if (!_cardView ) {
        _cardView = [[UIView alloc] init];
        [self.view addSubview:_cardView];
        _cardView.bmx_left = 20;
        _cardView.bmx_size = CGSizeMake(MAXScreenW - 40, 450);
        _cardView.bmx_top = kNavBarHeight + 100;
        _cardView.layer.cornerRadius = 8;
        _cardView.layer.masksToBounds = YES;
        _cardView.layer.borderColor = BMXCOLOR_HEX(0xFFDFDFDF).CGColor;
        _cardView.layer.borderWidth = 1;
        _cardView.backgroundColor = [UIColor clearColor];
//        _cardView.backgroundColor =

    }
    return _cardView;
}

- (void)setUpNavItem {
    [self setNavigationBarTitle:@"我的二维码" navLeftButtonIcon:@"blackback"];
}

@end
