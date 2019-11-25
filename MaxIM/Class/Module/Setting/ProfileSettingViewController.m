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

@interface ProfileSettingViewController ()<UITableViewDataSource, UITableViewDelegate>


@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) BMXUserProfile *profile;

@end

@implementation ProfileSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setUpNavItem];
    self.dataArray = [self getSettingConfigDataArray];
    [self getprofile];
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
            [self.tableView reloadData];
        } else {
        }
    }];
}

// 设置手机号
- (void)modifyPhone:(NSString *)phone {
    [HQCustomToast showWating];
    [[[BMXClient sharedClient] userService] setMobilePhone:phone completion:^(BMXError *error) {
        [HQCustomToast hideWating];
        if (!error) {
            [HQCustomToast showDialog:@"设置成功"];
            MAXLog(@"%@", error);
            [self getprofile];
        }
    }];
}

// 修改昵称
- (void)modifyNickname:(NSString *)nickname {
    [HQCustomToast showWating];
    [[[BMXClient sharedClient] userService] setNickname:nickname completion:^(BMXError *error) {
        [HQCustomToast hideWating];
        if (!error) {
            [HQCustomToast showDialog:@"设置成功"];
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
            [HQCustomToast showDialog:@"设置成功"];
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
            [HQCustomToast showDialog:@"设置成功"];
            MAXLog(@"%@", error);
            [self getprofile];
        }
    }];
}

//设置加好友
- (void)setAddFriendAuth:(BMXAddFriendAuthMode)mode {
    [[[BMXClient sharedClient] userService] setAddFriendAuthMode:mode completion:^(BMXError *error) {
        if (!error) {
            [HQCustomToast showDialog:@"设置成功"];
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
            [HQCustomToast showDialog:@"设置成功"];
            [self getprofile];
        }
    }];
}

- (NSDictionary *)readLocalFileWithName:(NSString *)name {
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"json"];
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    return [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
}

#pragma mark - data
- (NSArray *)getSettingConfigDataArray {
    NSDictionary *configDic = [NSDictionary dictionaryWithDictionary:[self readLocalFileWithName:@"profilesetting"]];
    MAXLog(@"%@", configDic);
    NSMutableArray *dataArray = [NSMutableArray array];
    for (NSDictionary *dic in configDic[@"cells"]) {
        [dataArray addObject:dic];
    }
    MAXLog(@"%@", dataArray);
    return dataArray;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count > 0 ? self.dataArray.count : 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ProfileTableViewCell *cell =[ProfileTableViewCell cellWithTableView:tableView];
    NSDictionary *dic = self.dataArray[indexPath.row];
    
    if ([dic[@"type"] isEqualToString:@"头像"]) {
        [cell.avatarimageView setHidden:NO];
        if ([[NSFileManager defaultManager] fileExistsAtPath:self.profile.avatarThumbnailPath]) {
            UIImage *avarat = [UIImage imageWithContentsOfFile:self.profile.avatarThumbnailPath];
            [cell.avatarimageView setImage:avarat];
        } else {
            [cell.avatarimageView setImage:[UIImage imageNamed:@"profileavatar"]];
        }
    } else {
        [cell.avatarimageView setHidden:YES];
    }

    
    if ([dic[@"type"] isEqualToString:@"id"]) {
        cell.contentLabel.text = [NSString stringWithFormat:@"%lld", self.profile.userId];
    } else if ([dic[@"type"] isEqualToString:@"昵称"]) {
        cell.contentLabel.text = [NSString stringWithFormat:@"%@", self.profile.nickName];
    } else if ([dic[@"type"] isEqualToString:@"设置手机号"]) {
        cell.contentLabel.text = [NSString stringWithFormat:@"%@", self.profile.mobilePhone];
    } else if ([dic[@"type"] isEqualToString:@"设置公开信息"]) {
        cell.contentLabel.text = [NSString stringWithFormat:@"%@", self.profile.publicInfoJson];
    } else if ([dic[@"type"] isEqualToString:@"设置私密信息"]) {
        cell.contentLabel.text = [NSString stringWithFormat:@"%@", self.profile.privateInfoJson];
    } else if ([dic[@"type"] isEqualToString:@"好友验证类型"]) {
        switch (self.profile.addFriendAuthMode) {
            case BMXAddFriendAuthModeOpen:
                cell.contentLabel.text = [NSString stringWithFormat:@"公开"];
                break;
            case BMXAddFriendAuthModeNeedApproval:
                cell.contentLabel.text = [NSString stringWithFormat:@"需要同意"];
                break;
            case BMXAddFriendAuthModeAnswerQuestion:
                cell.contentLabel.text = [NSString stringWithFormat:@"需要回答问题"];
                break;
            case BMXAddFriendAuthModeRejectAll:
                cell.contentLabel.text = [NSString stringWithFormat:@"拒绝所有人"];
                break;
            default:
                break;
        }
    } else if ([dic[@"type"] isEqualToString:@"好友验证问题"]) {
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

    if ([dic[@"type"] isEqualToString:@"头像"]) {
        [self choiseImage];
    }  else if ([dic[@"type"] isEqualToString:@"昵称"]) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"修改昵称"
                                                                       message:@""
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             //响应事件
                                                             //得到文本信息
                                                             for(UITextField *text in alert.textFields){
                                                                 MAXLog(@"text = %@", text.text);
                                                                 [self modifyNickname:text.text];
                                                             }
                                                         }];
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction * action) {
                                                                 //响应事件
                                                                 MAXLog(@"action = %@", alert.textFields);
                                                             }];
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"请输入昵称";
        }];
        
        [alert addAction:okAction];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        
    } else if ([dic[@"type"] isEqualToString:@"设置手机号"]) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"修改手机号"
                                                                       message:@""
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             //响应事件
                                                             //得到文本信息
                                                             for(UITextField *text in alert.textFields){
                                                                 MAXLog(@"text = %@", text.text);
                                                                 [self modifyPhone:text.text];
                                                             }
                                                         }];
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction * action) {
                                                                 //响应事件
                                                                 MAXLog(@"action = %@", alert.textFields);
                                                             }];
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"请输入手机号";
        }];
        
        [alert addAction:okAction];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
    } else if ([dic[@"type"] isEqualToString:@"设置公开信息"]) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"设置公开信息"
                                                                       message:@""
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             //响应事件
                                                             //得到文本信息
                                                             for(UITextField *text in alert.textFields){
                                                                 MAXLog(@"text = %@", text.text);
                                                                 [self setpublicInfo:text.text];
                                                             }
                                                         }];
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction * action) {
                                                                 //响应事件
                                                                 MAXLog(@"action = %@", alert.textFields);
                                                             }];
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"请输入公开信息";
        }];
        
        [alert addAction:okAction];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
        
    } else if ([dic[@"type"] isEqualToString:@"设置私密信息"]) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"设置私密信息"
                                                                       message:@""
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             //响应事件
                                                             //得到文本信息
                                                             for(UITextField *text in alert.textFields){
                                                                 MAXLog(@"text = %@", text.text);
                                                                 [self setPrivateInfo:text.text];
                                                                 
                                                             }
                                                         }];
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction * action) {
                                                                 //响应事件
                                                                 MAXLog(@"action = %@", alert.textFields);
                                                             }];
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"请输入私密信息";
        }];
        
        [alert addAction:okAction];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
    } else if ([dic[@"type"] isEqualToString:@"好友验证类型"]) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"请选择好友验证类型" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
       
        UIAlertAction* action1 = [UIAlertAction actionWithTitle:@"公开" style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * action) {
                                                            //响应事件
                                                            [self setAddFriendAuth:BMXAddFriendAuthModeOpen];
                                                            
                                                        
                                                        }];
        UIAlertAction* action2 = [UIAlertAction actionWithTitle:@"需要同意" style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 //响应事件
                                                                 [self setAddFriendAuth:BMXAddFriendAuthModeNeedApproval];

                                                             }];
        UIAlertAction* action3 = [UIAlertAction actionWithTitle:@"需要回答问题" style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 //响应事件
                                                                 [self setAddFriendAuth:BMXAddFriendAuthModeAnswerQuestion];

                                                             }];
        UIAlertAction* action4 = [UIAlertAction actionWithTitle:@"拒绝所有人" style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) {
                                                               //响应事件
                                                               [self setAddFriendAuth:BMXAddFriendAuthModeRejectAll];

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
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
        
    }else if ([dic[@"type"] isEqualToString:@"好友验证问题"]) {
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"好友验证问题"
                                                                       message:@""
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault
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
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction * action) {
                                                                 //响应事件
                                                                 MAXLog(@"action = %@", alert.textFields);
                                                             }];
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            if ([self.profile.authQuestion.mQuestion length]) {
                textField.text = self.profile.authQuestion.mQuestion;
            } else {
                textField.placeholder = @"请输入问题";
            }
            
            textField.tag = 1000;
        }];
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            
            if ([self.profile.authQuestion.mAnswer length]) {
                textField.text = self.profile.authQuestion.mAnswer;
            } else {
                textField.placeholder = @"请输入答案";
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
                [HQCustomToast showDialog:@"上传成功"];
            }
        }];
    }];
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}

- (void)setUpNavItem{
    [self setNavigationBarTitle:@"个人资料" navLeftButtonIcon:@"blackback"];
}


@end
