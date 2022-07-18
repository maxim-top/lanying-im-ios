//
//  ----------------------------------------------------------------------
//   File    :  ProfileSettingViewController.m
//   Author  : HYT yutong@bmxlabs.com
//   Purpose :
//   Created : 2018/12/28 by HYT yutong@bmxlabs.com
//
//  ----------------------------------------------------------------------
//
//                    Copyright (C) 2018-2019   MaxIM.Top
//
// You may obtain a copy of the licence at http://www.maxim.top/LICENCE-MAXIM.md
//
//  ----------------------------------------------------------------------
    

#import "ProfileSettingViewController.h"
#import "ProfileTableViewCell.h"
#import <floo-ios/BMXClient.h>
#import <floo-ios/BMXUserProfile.h>
#import <TZImagePickerController.h>
#import <floo-ios/BMXAuthQuestion.h>
#import "UIViewController+CustomNavigationBar.h"

#import "BindPhoneViewController.h"
#import "ChangeMobileAlert.h"
#import "VerifyPhoneViewController.h"
#import "VerifyPasswordViewController.h"
#import "UIView+BMXframe.h"
#import "WechatIsBindApi.h"
#import "AppWechatUnbindApi.h"
#import "LogViewController.h"

@interface ProfileSettingViewController ()<UITableViewDataSource, UITableViewDelegate, ChangeMobileAlertDelegate>


@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) BMXUserProfile *profile;
@property (nonatomic, strong) ChangeMobileAlert *alert;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIImageView *headerImageView;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UIImageView *editImageView;
@property (nonatomic,assign) BOOL isbindWechat;


@end

@implementation ProfileSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setUpNavItem];
    self.dataArray = [self getSettingConfigDataArray];
    [self getprofile];
    [self checkWechatBind];
    [self setupHeaderView];
    
    
}

- (void)checkWechatBind {
    WechatIsBindApi *api = [[WechatIsBindApi alloc] init];
    [api startWithSuccessBlock:^(ApiResult * _Nullable result) {
        if (result.isOK) {
            
            NSString  *isbind=[NSString stringWithFormat:@"%@", result.resultData];
            self.isbindWechat = [isbind integerValue] > 0 ? YES :NO;
            
        } else {
            self.isbindWechat = NO;
        }
        
        [self.tableView reloadData];
    } failureBlock:^(NSError * _Nullable error) {
        
    }];
}

#pragma mark - manager
- (void)getprofile {
    [[[BMXClient sharedClient] userService] getProfileForceRefresh:YES completion:^(BMXUserProfile *profile, BMXError *aError) {
        if (!aError) {
            
            self.profile = profile;
            if (self.profile.addFriendAuthMode != BMXAddFriendAuthModeAnswerQuestion) {
                self.dataArray = [self getSettingConfigDataArray];
                NSMutableArray *dataArrayM  = [NSMutableArray arrayWithArray:self.dataArray];
                [dataArrayM removeLastObject];
                self.dataArray = [NSArray arrayWithArray:dataArrayM];
            } else {
                self.dataArray = [self getSettingConfigDataArray];
            }
            

                if ([[NSFileManager defaultManager] fileExistsAtPath:self.profile.avatarThumbnailPath]) {
                    UIImage *avarat = [UIImage imageWithContentsOfFile:self.profile.avatarThumbnailPath];
                    self.avatarImageView.image = avarat;
//                    [cell.avatarimageView setImage:avarat];
                }

            
            
            [self.tableView reloadData];
        } else {
        }
    }];
}

- (void)alertDidSelectCaptchaButton:(ChangeMobileAlert *)alert {
    
    if (alert.tag == 1000) {
        [self changeMobileAlertDidSelectCaptchaButton];
    }else {
        [self changePasswordAlertDidSelectCaptchaButton];
    }
}
- (void)alertDidSelectPasswordButton:(ChangeMobileAlert *)alert {
    
    if (alert.tag == 1000) {
        [self changeMobileAlertDidSelectPasswordButton];
    }else {
        [self changePasswordAlertDidSelectPasswordButton];
    }
}

- (void)changeMobileAlertDidSelectCaptchaButton {
    [self.alert hide];
    VerifyPhoneViewController *vc = [[VerifyPhoneViewController alloc] initWithEditType:EditTypePhone];
    vc.profile = self.profile;
    [self.navigationController pushViewController:vc animated:YES];
    
    MAXLog(@"验证码方式");
}

- (void)changeMobileAlertDidSelectPasswordButton {
    MAXLog(@"密码方式");
    [self.alert hide];
    VerifyPasswordViewController *vc = [[VerifyPasswordViewController alloc] initWithEditType:EditTypePhone];
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)changePasswordAlertDidSelectCaptchaButton {
    [self.alert hide];
    VerifyPhoneViewController *vc = [[VerifyPhoneViewController alloc] initWithEditType:EditTypePassword];
    vc.profile = self.profile;
    [self.navigationController pushViewController:vc animated:YES];
    
    MAXLog(@"验证码方式");
}

- (void)changePasswordAlertDidSelectPasswordButton {
    MAXLog(@"密码方式");
    [self.alert hide];
    VerifyPasswordViewController *vc = [[VerifyPasswordViewController alloc] initWithEditType:EditTypePassword];
    [self.navigationController pushViewController:vc animated:YES];
}


// 修改昵称
- (void)modifyNickname:(NSString *)nickname {
    [HQCustomToast showWating];
    [[[BMXClient sharedClient] userService] setNickname:nickname completion:^(BMXError *error) {
        [HQCustomToast hideWating];
        if (!error) {
            [HQCustomToast showDialog:NSLocalizedString(@"Set_successfully", @"设置成功")];
            MAXLog(@"%@", error);
            [self getprofile];
        }
    }];
}

// 设置公开信息
- (void)setpublicInfo:(NSString *)info {
    [HQCustomToast showWating];
    [[[BMXClient sharedClient] userService] setPublicInfo:info completion:^(BMXError *error) {
        [HQCustomToast hideWating];
        if (!error) {
            [HQCustomToast showDialog:NSLocalizedString(@"Set_successfully", @"设置成功")];
            MAXLog(@"%@", error);
            [self getprofile];
        }
    }];
}

- (void)setPrivateInfo:(NSString *)info {
    [HQCustomToast showWating];
    [[[BMXClient sharedClient] userService] setPrivateInfo:info completion:^(BMXError *error) {
        [HQCustomToast hideWating];
        if (!error) {
            [HQCustomToast showDialog:NSLocalizedString(@"Set_successfully", @"设置成功")];
            MAXLog(@"%@", error);
            [self getprofile];
        }
    }];
}

//设置加好友
- (void)setAddFriendAuth:(BMXAddFriendAuthMode)mode {
    [[[BMXClient sharedClient] userService] setAddFriendAuthMode:mode completion:^(BMXError *error) {
        if (!error) {
            [HQCustomToast showDialog:NSLocalizedString(@"Set_successfully", @"设置成功")];
            [self getprofile];
        }
    }];
}

- (void)setQuestion:(NSString *)question answer:(NSString *)answer {
    BMXAuthQuestion *qustionModel = [[BMXAuthQuestion alloc] init];
    qustionModel.mQuestion = question;
    qustionModel.mAnswer = answer;
    
    [[[BMXClient sharedClient] userService] setAuthQuestion:qustionModel completion:^(BMXError *error) {
        if (!error) {
            [HQCustomToast showDialog:NSLocalizedString(@"Set_successfully", @"设置成功")];
            [self getprofile];
        }
    }];
}

- (NSDictionary *)readLocalFileWithName:(NSString *)name {
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"json"];
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    return [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
}

- (void)gotoBindPhone {
    BindPhoneViewController *bindPhone = [[BindPhoneViewController alloc] init];
    [self.navigationController pushViewController:bindPhone animated:YES];
}

- (void)showSetMobileAlert {
    
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Modify_phone_number", @"修改手机号")
                                                                           message:@""
                                                                    preferredStyle:UIAlertControllerStyleAlert];
    
            UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", @"确定") style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 //响应事件
                                                                 //得到文本信息
                                                                 for(UITextField *text in alert.textFields){
                                                                     MAXLog(@"text = %@", text.text);
    //                                                                 [self modifyPhone:text.text];
                                                                 }
                                                             }];
            UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"取消") style:UIAlertActionStyleCancel
                                                                 handler:^(UIAlertAction * action) {
                                                                     //响应事件
                                                                     MAXLog(@"action = %@", alert.textFields);
                                                                 }];
            [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                textField.placeholder = NSLocalizedString(@"enter_phone_number", @"请输入手机号");
            }];
    
            [alert addAction:okAction];
            [alert addAction:cancelAction];
            [self presentViewController:alert animated:YES completion:nil];
    
}

- (void)setupHeaderView {
    UIImage *image = [UIImage imageNamed:@"Backgroud"];
    
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MAXScreenW, image.size.height)];
    self.headerView.backgroundColor = [UIColor whiteColor]; //BMXCOLOR_HEX(0xf8f8f8);
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(choiseImage)];
    [self.headerView addGestureRecognizer:tap];
    
    self.headerImageView = [[UIImageView alloc] initWithImage:image];
    self.headerImageView.frame = CGRectMake(0, 0, MAXScreenW, image.size.height);
    self.headerImageView.tag = 101;
    self.headerImageView.backgroundColor = [UIColor whiteColor];
    self.headerImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.headerImageView.clipsToBounds = YES;
    [self.headerView addSubview:self.headerImageView];
    
    [self avatarImageView];
    [self editImageView];
}

- (UIImageView *)avatarImageView {
    if (!_avatarImageView) {
        
        _avatarImageView = [[UIImageView alloc] init];
        [self.headerView addSubview:_avatarImageView];
        UIImage *image = [UIImage imageNamed:@"Backgroud"];
        _avatarImageView.frame = CGRectMake(MAXScreenW/2.0 - 100 /2.0, image.size.height /2.0 - 100 / 2.0, 100, 100);
        _avatarImageView.clipsToBounds = YES;
        _avatarImageView.layer.cornerRadius = 50;
        _avatarImageView.image = [UIImage imageNamed:@"mine_avater_placoholder"];
        
    }
    return _avatarImageView;
}

- (UIImageView *)editImageView {
    if (!_editImageView) {
        _editImageView = [[UIImageView alloc] init];
        [self.headerView addSubview:_editImageView];
        _editImageView.image = [UIImage imageNamed:@"mine_photo"];
        
        //        CGSize arrowImageViewSize = CGSizeMake(_editImageView.image.size.width, _editImageView.image.size.height);
        CGSize arrowImageViewSize = CGSizeMake(30, 30); // 临时
        _editImageView.bmx_size =  arrowImageViewSize;
        _editImageView.bmx_right = self.avatarImageView.bmx_right + 5;
        _editImageView.bmx_bottom = self.avatarImageView.bmx_bottom  ;
//        _editImageView.bmx_top = 20;
    }
    return _editImageView;
}

#pragma mark - data
- (NSArray *)getSettingConfigDataArray {
    NSDictionary *configDic = [NSDictionary dictionaryWithDictionary:[self readLocalFileWithName:@"profilesetting"]];
    NSMutableArray *dataArray = [NSMutableArray array];
    for (NSDictionary *dic in configDic[@"cells"]) {
        [dataArray addObject:dic];
    }
    return dataArray;
}

- (void)clickunbindWechat {
    
    AppWechatUnbindApi *api = [[AppWechatUnbindApi alloc] init];
    [api startWithSuccessBlock:^(ApiResult * _Nullable result) {
        if (result.isOK) {
            [HQCustomToast showDialog:NSLocalizedString(@"Unbind_successfully", @"解绑成功")];
        }
        
        [self checkWechatBind];
    } failureBlock:^(NSError * _Nullable error) {
        
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count > 0 ? self.dataArray.count : 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 69.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ProfileTableViewCell *cell =[ProfileTableViewCell cellWithTableView:tableView];
    NSDictionary *dic = self.dataArray[indexPath.row];
    
    if ([dic[@"type"] isEqualToString:@"ID"]) {
        cell.contentLabel.text = [NSString stringWithFormat:@"%lld", self.profile.userId];
    } else if ([dic[@"type"] isEqualToString:NSLocalizedString(@"Nickname", @"昵称")]) {
        NSString *aString = [self.profile.nickName length] ? self.profile.nickName : NSLocalizedString(@"set_nickname", @"请设置昵称");
        cell.contentLabel.text = aString;
    } else if ([dic[@"type"] isEqualToString:NSLocalizedString(@"Phone_number", @"手机号")]) {
        NSString *aString = [self.profile.mobilePhone length] ? self.profile.mobilePhone : NSLocalizedString(@"Go_to_bind", @"去绑定");
        cell.contentLabel.text = aString;
    }else if ([dic[@"type"] isEqualToString:NSLocalizedString(@"Modify_password", @"修改密码")]) {
        NSString *aString = @"";
        cell.contentLabel.text = aString;
    } else if ([dic[@"type"] isEqualToString:NSLocalizedString(@"WeChat", @"微信")]) {
        NSString *aString = self.isbindWechat ? NSLocalizedString(@"Unbind", @"解绑") : NSLocalizedString(@"Unbound", @"未绑定");
        cell.contentLabel.text = aString;
    } else if ([dic[@"type"] isEqualToString:NSLocalizedString(@"Public_info", @"公开信息")]) {
        cell.contentLabel.text = [NSString stringWithFormat:@"%@", self.profile.publicInfoJson];
    } else if ([dic[@"type"] isEqualToString:NSLocalizedString(@"Private_profile", @"私密信息")]) {
        cell.contentLabel.text = [NSString stringWithFormat:@"%@", self.profile.privateInfoJson];
    } else if ([dic[@"type"] isEqualToString:NSLocalizedString(@"Friend_verification", @"好友验证")]) {
        switch (self.profile.addFriendAuthMode) {
            case BMXAddFriendAuthModeOpen:
                cell.contentLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Public", @"公开")];
                break;
            case BMXAddFriendAuthModeNeedApproval:
                cell.contentLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Consent_required", @"需要同意")];
                break;
            case BMXAddFriendAuthModeAnswerQuestion:
                cell.contentLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Require_to_answer_questions", @"需要回答问题")];
                break;
            case BMXAddFriendAuthModeRejectAll:
                cell.contentLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Reject_all", @"拒绝所有人")];
                break;
            default:
                break;
        }
    } else if ([dic[@"type"] isEqualToString:NSLocalizedString(@"Friend_verification_question", @"好友验证问题")]) {
        cell.contentLabel.text = self.profile.authQuestion.mQuestion ? [NSString stringWithFormat:@"%@", self.profile.authQuestion.mQuestion] : @"";
        
    }
    
    if ([dic[@"control"] isEqualToString:@"alert"]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
        
    cell.titleLabel.text = dic[@"type"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = self.dataArray[indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if ([dic[@"type"] isEqualToString:NSLocalizedString(@"Avatar", @"头像")]) {
        [self choiseImage];
    } else if ([dic[@"type"] isEqualToString:@"ID"]) {
        
        LogViewController *logvc = [[LogViewController alloc] init];
        [self.navigationController pushViewController:logvc animated:YES];
    } else if ([dic[@"type"] isEqualToString:NSLocalizedString(@"Nickname", @"昵称")]) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Modify_nickname", @"修改昵称")
                                                                       message:@""
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", @"确定") style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             //响应事件
                                                             //得到文本信息
                                                             for(UITextField *text in alert.textFields){
                                                                 MAXLog(@"text = %@", text.text);
                                                                 [self modifyNickname:text.text];
                                                             }
                                                         }];
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"取消") style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction * action) {
                                                                 //响应事件
                                                                 MAXLog(@"action = %@", alert.textFields);
                                                             }];
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = NSLocalizedString(@"enter_nickname", @"请输入昵称");
        }];
        
        [alert addAction:okAction];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        
    } else if ([dic[@"type"] isEqualToString:NSLocalizedString(@"Phone_number", @"手机号")]) {
        if ([self.profile.mobilePhone length]) {
            self.alert = [ChangeMobileAlert alertWithTitle:NSLocalizedString(@"Change_the_bound_phone_number", @"更改绑定手机号") Phone:self.profile.mobilePhone];
            self.alert.tag = 1000;
            self.alert.delegate = self;
            [self.alert show];
        } else {
            [self gotoBindPhone];
        }

    }else if ([dic[@"type"] isEqualToString:NSLocalizedString(@"Modify_password", @"修改密码")]) {
        if ([self.profile.mobilePhone length]) {
            self.alert = [ChangeMobileAlert alertWithTitle:NSLocalizedString(@"Change_password", @"更改密码") Phone:self.profile.mobilePhone];
            self.alert.tag = 1001;
            self.alert.delegate = self;
            [self.alert show];
        } else {
            [self gotoBindPhone];
        }
    } else if ([dic[@"type"] isEqualToString:NSLocalizedString(@"WeChat", @"微信")]) {
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Remind", @"提醒")
                                                                       message:NSLocalizedString(@"Confirm_to_unbind_the_WeChat_account", @"确定解绑微信？")
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", @"确定") style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             //响应事件
                                                             //得到文本信息
                                                             
                                                             [self clickunbindWechat];
                                                             
                                                         }];
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"取消") style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction * action) {
                                                                 //响应事件
                                                                 MAXLog(@"action = %@", alert.textFields);
                                                             }];
        
        [alert addAction:okAction];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];

        
    } else if ([dic[@"type"] isEqualToString:NSLocalizedString(@"Public_info", @"公开信息")]) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Set_public_profile", @"设置公开信息")
                                                                       message:NSLocalizedString(@"public_info_message", @"好友可见的信息，可用于实现个性签名之类的功能")
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", @"确定") style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             //响应事件
                                                             //得到文本信息
                                                             for(UITextField *text in alert.textFields){
                                                                 MAXLog(@"text = %@", text.text);
                                                                 [self setpublicInfo:text.text];
                                                             }
                                                         }];
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"取消") style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction * action) {
                                                                 //响应事件
                                                                 MAXLog(@"action = %@", alert.textFields);
                                                             }];
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = NSLocalizedString(@"enter_public_profile", @"请输入公开信息");
        }];
        
        [alert addAction:okAction];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
        
    } else if ([dic[@"type"] isEqualToString:NSLocalizedString(@"Private_profile", @"私密信息")]) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Set_private_profile", @"设置私密信息")
                                                                       message:NSLocalizedString(@"private_info_message", @"好友不可见的信息，可用于实现收藏夹之类的功能")
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", @"确定") style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             //响应事件
                                                             //得到文本信息
                                                             for(UITextField *text in alert.textFields){
                                                                 MAXLog(@"text = %@", text.text);
                                                                 [self setPrivateInfo:text.text];
                                                                 
                                                             }
                                                         }];
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"取消") style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction * action) {
                                                                 //响应事件
                                                                 MAXLog(@"action = %@", alert.textFields);
                                                             }];
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = NSLocalizedString(@"enter_private_profile", @"请输入私密信息");
        }];
        
        [alert addAction:okAction];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
    } else if ([dic[@"type"] isEqualToString:NSLocalizedString(@"Friend_verification", @"好友验证类型")]) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"select_your_Friend_verification_type", @"请选择好友验证类型") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
       
        UIAlertAction* action1 = [UIAlertAction actionWithTitle:NSLocalizedString(@"Public", @"公开") style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * action) {
                                                            //响应事件
                                                            [self setAddFriendAuth:BMXAddFriendAuthModeOpen];
                                                            
                                                        
                                                        }];
        UIAlertAction* action2 = [UIAlertAction actionWithTitle:NSLocalizedString(@"Consent_required", @"需要同意") style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 //响应事件
                                                                 [self setAddFriendAuth:BMXAddFriendAuthModeNeedApproval];

                                                             }];
        UIAlertAction* action3 = [UIAlertAction actionWithTitle:NSLocalizedString(@"Require_to_answer_questions", @"需要回答问题") style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 //响应事件
                                                                 [self setAddFriendAuth:BMXAddFriendAuthModeAnswerQuestion];

                                                             }];
        UIAlertAction* action4 = [UIAlertAction actionWithTitle:NSLocalizedString(@"Reject_all", @"拒绝所有人") style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) {
                                                               //响应事件
                                                               [self setAddFriendAuth:BMXAddFriendAuthModeRejectAll];

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
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
        
    }else if ([dic[@"type"] isEqualToString:NSLocalizedString(@"Friend_verification_question", @"好友验证问题")]) {
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Friend_verification_question", @"好友验证问题")
                                                                       message:@""
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", @"确定") style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             //响应事件
                                                             //得到文本信息
                                                             NSString *question = @"";
                                                             NSString *answer = @"";
                                                             for(UITextField *text in alert.textFields){
                                                                 if (text.tag == 1000) {
                                                                     question = text.text;
                                                                 }
                                                                 if (text.tag == 1001) {
                                                                     answer = text.text;
                                                                 }
                                                                 
                                                             }
                                                             
                                                             [self setQuestion:question answer:answer];
                                                             
                                                             
                                                         }];
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"取消") style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction * action) {
                                                                 //响应事件
                                                                 MAXLog(@"action = %@", alert.textFields);
                                                             }];
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            if ([self.profile.authQuestion.mQuestion length]) {
                textField.text = self.profile.authQuestion.mQuestion;
            } else {
                textField.placeholder = NSLocalizedString(@"enter_question", @"请输入问题");
            }
            
            textField.tag = 1000;
        }];
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            
            if ([self.profile.authQuestion.mAnswer length]) {
                textField.text = self.profile.authQuestion.mAnswer;
            } else {
                textField.placeholder = NSLocalizedString(@"enter_answer", @"请输入答案");
            }
            textField.tag = 1001;
        }];
        
        [alert addAction:okAction];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NavHeight, MAXScreenW, MAXScreenH - NavHeight - kTabBarHeight) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.tableHeaderView = self.headerView;
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

- (void)choiseImage {
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:self];
    imagePickerVc.cropRect = CGRectMake(0, (MAXScreenH - MAXScreenW) / 2 , MAXScreenW, MAXScreenW);
    imagePickerVc.allowCrop = YES;
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        UIImage *image = [photos firstObject];
        NSData *imageData = UIImagePNGRepresentation(image);
        [[[BMXClient sharedClient] userService] uploadAvatarWithData:imageData progress:^(int progress, BMXError *error) {
            MAXLog(@"%d == %@",progress, error);
            if (!error && progress == 100) {
                [HQCustomToast showDialog:NSLocalizedString(@"Upload_successfully", @"上传成功")];
            }
        }];
    }];
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}

- (void)setUpNavItem{
    [self setNavigationBarTitle:NSLocalizedString(@"Personal_profile", @"个人资料") navLeftButtonIcon:@"blackback"];
}


@end
