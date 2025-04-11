//  ----------------------------------------------------------------------
//   File    :  ChatRosterProfileViewController.m
//   Author  : HYT yutong@bmxlabs.com
//   Purpose :
//   Created : 2019/1/3 by HYT yutong@bmxlabs.com
//
//  ----------------------------------------------------------------------
//
//                    Copyright (C) 2018-2019   MaxIM.Top
//
// You may obtain a copy of the licence at http://www.maxim.top/LICENCE-MAXIM.md
//
//  ----------------------------------------------------------------------
    

#import "ChatRosterProfileViewController.h"
#import "TitleSwitchTableViewCell.h"
#import "UIView+BMXframe.h"

#import <floo-ios/floo_proxy.h>
#import "UIViewController+CustomNavigationBar.h"
#import "LHChatVC.h"
#import "CallViewController.h"
#import "IMAcount.h"
#import "IMAcountInfoStorage.h"
#import "CopyableLabel.h"

static const float FOOTER_BUTTON_HEIGHT = 50.0f;
static const float FOOTER_BUTTON_PADDING = 10.0f;

@interface ChatRosterProfileViewController ()<UITableViewDelegate, UITableViewDataSource, TitleSwitchTableViewCellDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIButton *beginChatButton;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) CopyableLabel *nameLabel;
@property (nonatomic, strong) UILabel *userIDLabelCap;
@property (nonatomic, strong) CopyableLabel *userIDLabel;
@property (nonatomic, strong) NSArray *cellDataArray;
@property (nonatomic, strong) BMXRosterItem *currentRoster;
@property (nonatomic, strong) IMAcount *account;
@property (nonatomic, strong) UIButton *startChatButton;
@property (nonatomic, strong) UIButton *videoCallButton;
@property (nonatomic, strong) UIButton *voiceCallButton;

@end

@implementation ChatRosterProfileViewController

- (instancetype)initWithRoster:(BMXRosterItem *)roster {
    if (self = [super init]) {
        self.currentRoster  = roster;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setUpNavItem];
    [self tableView];
    
    self.avatarImageView.image = [UIImage imageNamed:@"profileavatar"];
    if ([self.currentRoster.avatarThumbnailPath length]) {
        UIImage *image = [UIImage imageWithContentsOfFile:self.currentRoster.avatarThumbnailPath];
        self.avatarImageView.image = image ? image : [UIImage imageNamed:@"profileavatar"];
    }
    
    if ([self.currentRoster.username length]) {
        self.nameLabel.text = [NSString stringWithFormat:@"%@", [self.currentRoster.nickname length] ? self.currentRoster.nickname : self.currentRoster.username];
        [self.nameLabel sizeToFit];

    }
    
    self.userIDLabel.text = [NSString stringWithFormat:@"%lld", self.currentRoster.rosterId];
    [self.userIDLabelCap sizeToFit];
    [self.userIDLabel sizeToFit];
    
    self.cellDataArray = [self getSettingConfigDataArray];
    [self.tableView reloadData];
    
    [self getRosterInfo:NO];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self getRosterInfo:YES];
    });
    self.account = [IMAcountInfoStorage loadObject];
}

- (void)setalias:(NSString *)name {
    [[[BMXClient sharedClient] rosterService] setItemAlias:self.currentRoster alias:name completion:^(BMXError *error) {
        if (!error) {
            [HQCustomToast showDialog:NSLocalizedString(@"Set_successfully", @"设置成功")];
            BMXRosterItem * item = [[BMXRosterItem alloc] init];
            BMXErrorCode error = [[[BMXClient sharedClient] rosterService] searchWithRosterId:self.currentRoster.rosterId forceRefresh:YES item:item];
            if (!error) {
                self.currentRoster = item;
                [self.tableView reloadData];
            }
        }
    }];
}

- (void)setExtension:(NSString *)ext {
    [[[BMXClient sharedClient] rosterService] setItemExtension:self.currentRoster extension:ext completion:^(BMXError *error) {
        [[[BMXClient sharedClient] rosterService] searchWithRosterId:self.currentRoster.rosterId forceRefresh:YES completion:^(BMXRosterItem *roster, BMXError *error) {
            if (!error) {
                self.currentRoster = roster;
                [self.tableView reloadData];
            }
        }];
    }];
}

- (void)getRosterInfo:(BOOL)forceUpdate {
    [[[BMXClient sharedClient] rosterService] searchWithRosterId:self.currentRoster.rosterId forceRefresh:forceUpdate completion:^(BMXRosterItem *item, BMXError *error) {
        if (!error) {
            self.currentRoster = item;
            [self.tableView reloadData];
        }
    }];
}

- (NSArray *)getSettingConfigDataArray {
    NSDictionary *configDic = [NSDictionary dictionaryWithDictionary:[self readLocalFileWithName:@"chatdetailproiledetail"]];
    NSMutableArray *dataArray = [NSMutableArray array];
    for (NSDictionary *dic in configDic[@"cells"]) {
        [dataArray addObject:dic];
    }
    return dataArray;
}

- (NSDictionary *)readLocalFileWithName:(NSString *)name {
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"json"];
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    return [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = self.cellDataArray[indexPath.row];
    TitleSwitchTableViewCell *cell = [TitleSwitchTableViewCell cellWithTableView:tableView];
    cell.delegate = self;
    cell.titleLabel.text = dic[@"type"];
    [cell.mswitch setHidden:YES];
//    if ([dic[@"type"] isEqualToString:@"ID"]) {
//        cell.contentLabel.text = [NSString stringWithFormat:@"%lld", self.currentRoster.rosterId];
//    } else
    if ([dic[@"type"] isEqualToString:NSLocalizedString(@"Common_info", @"公有信息")]) {
        cell.contentLabel.text = [NSString stringWithFormat:@"%@", self.currentRoster.publicInfo];
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else if ([dic[@"type"] isEqualToString:NSLocalizedString(@"Username", @"用户名")]) {
        cell.contentLabel.text = [NSString stringWithFormat:@"%@", self.currentRoster.username];
    } else if ([dic[@"type"] isEqualToString:NSLocalizedString(@"Set_extension_info", @"设置扩展信息")]) {
        cell.contentLabel.text = [NSString stringWithFormat:@"%@", self.currentRoster.ext];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator; //显示最右边的箭头
    }  else  if ([dic[@"type"] isEqualToString:NSLocalizedString(@"Set_alias", @"设置别名")]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator; //显示最右边的箭头
        cell.contentLabel.text = [NSString stringWithFormat:@"%@", self.currentRoster.alias];

    }  else if ([dic[@"type"] isEqualToString:NSLocalizedString(@"Do-Not-Disturb", @"消息免打扰")]) {
        cell.contentLabel.text = @"";
        if ([dic[@"control"] isEqualToString:@"0"]) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            [cell.mswitch setHidden:YES];
        } else {
            [cell.mswitch setHidden:NO];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        [cell.mswitch setOn:self.currentRoster.isMuteNotification];
    }
    return cell;
}

- (void)cellDidchangeSwitchStatus:(UISwitch *)mswtich cell:(TitleSwitchTableViewCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSDictionary *dic = self.cellDataArray[indexPath.row];
    NSString *str = dic[@"type"];
    BOOL state = mswtich.on ? YES : NO;
    if ([str isEqualToString:NSLocalizedString(@"Do-Not-Disturb", @"消息免打扰")]) {
    [[[BMXClient sharedClient] rosterService] setItemMuteNotification:self.currentRoster status:state completion:^(BMXError *error) {
            if (!error) {
                MAXLog(@"设置成功");
                [HQCustomToast showDialog:NSLocalizedString(@"Set_successfully", @"设置成功")];
            } else {
                MAXLog(@"设置失败");
            }
        }];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cellDataArray.count > 0 ? self.cellDataArray.count : 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = self.cellDataArray[indexPath.row];
    if ([dic[@"type"] isEqualToString:NSLocalizedString(@"Set_alias", @"设置别名")]) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Set_alias", @"设置别名")
                                                                       message:@""
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", @"确定") style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             //响应事件
                                                             //得到文本信息
                                                             for(UITextField *text in alert.textFields){
                                                                 MAXLog(@"text = %@", text.text);
                                                                 [self setalias:text.text];
                                                                 
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
    } else if ([dic[@"type"] isEqualToString:NSLocalizedString(@"Set_extension_info", @"设置扩展信息")]) {
        NSString *message = [NSString stringWithFormat:@"%@\n\n\n\n\n",NSLocalizedString(@"ext_info_message", @"好友的扩展信息，可用于实现打标签之类的功能")];
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Set_extension_info", @"设置扩展信息")
                                                                       message:message
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", @"确定") style:UIAlertActionStyleDefault
            handler:^(UIAlertAction * action) {
                [self setExtension:((UITextView *)alert.view.subviews[1]).text];
            }];
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"取消") style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction * action) {
                                                                 //响应事件
                                                                 MAXLog(@"action = %@", alert.textFields);
                                                             }];
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = NSLocalizedString(@"Input_extension_info", @"请输入扩展信息");
        }];
        alert.textFields.firstObject.borderStyle = UITextBorderStyleNone;
        
        UITextView *textView = [[UITextView alloc] initWithFrame:CGRectZero];
        textView.translatesAutoresizingMaskIntoConstraints = NO;
        textView.layer.borderWidth = 1.0;
        textView.layer.borderColor = [UIColor lh_colorWithHexString:@"DDDDDD"].CGColor;
        textView.font = [UIFont systemFontOfSize:15];
        
        NSLayoutConstraint *leadConstraint = [NSLayoutConstraint constraintWithItem:alert.view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:textView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:-14.0];
        NSLayoutConstraint *trailConstraint = [NSLayoutConstraint constraintWithItem:alert.view attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:textView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:14.0];
        NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:alert.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:textView attribute:NSLayoutAttributeTop multiplier:1.0 constant:-95.0];
        NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:alert.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:textView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:55.0];
        [alert.view addSubview:textView];
        textView.text = self.currentRoster.ext;
        
        [NSLayoutConstraint activateConstraints:@[leadConstraint, trailConstraint, topConstraint, bottomConstraint]];

        [alert addAction:okAction];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)videoCall {
    CallViewController *videoCallViewController =
        [[CallViewController alloc] initForRoom:[self.account.usedId longLongValue]
                                                 callId:0
                                                   myId:[self.account.usedId longLongValue]
                                                 peerId:self.currentRoster.rosterId
                                              messageId:0
                                                    pin:@""
                                               isCaller:YES
                                               hasVideo:YES
                                          currentRoster:_currentRoster];
    videoCallViewController.modalTransitionStyle =  UIModalTransitionStyleCrossDissolve;
    videoCallViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:videoCallViewController
                       animated:NO
                     completion:nil];
}

- (void)voiceCall {
    CallViewController *videoCallViewController =
        [[CallViewController alloc] initForRoom:[self.account.usedId longLongValue]
                                                 callId:0
                                                   myId:[self.account.usedId longLongValue]
                                                 peerId:self.currentRoster.rosterId
                                              messageId:0
                                                    pin:@""
                                               isCaller:YES
                                               hasVideo:NO
                                          currentRoster:_currentRoster];
    videoCallViewController.modalTransitionStyle =  UIModalTransitionStyleCrossDissolve;
    videoCallViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:videoCallViewController
                       animated:NO
                     completion:nil];
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NavHeight, MAXScreenW, MAXScreenH - NavHeight - TabBarHeight) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        [self setupHeaderView];
        _tableView.tableHeaderView = self.headerView;
        _tableView.tableHeaderView.bmx_height = 120.f;
        [self setupFooterView];
        _tableView.tableFooterView = self.footerView;
        int numFooterButtons = self.currentRoster.relation == BMXRosterItem_RosterRelation_Friend ? 3 : 2;
        _tableView.tableFooterView.bmx_height = FOOTER_BUTTON_HEIGHT*numFooterButtons + FOOTER_BUTTON_PADDING*(numFooterButtons+1);

        [self.view addSubview:_tableView];
    }
    return _tableView;
}

- (void)setUpNavItem{
    if (self.currentRoster.relation != BMXRosterItem_RosterRelation_Friend) {
        [self setNavigationBarTitle:self.currentRoster.username navLeftButtonIcon:@"blackback" navRightButtonIcon:@"contact_add"];
        [self.navRightButton addTarget:self action:@selector(onAddContact) forControlEvents:UIControlEventTouchUpInside];
    }else{
        [self setNavigationBarTitle:self.currentRoster.username navLeftButtonIcon:@"blackback"];
    }
}

-(void)onAddContact {
    BMXRosterItem *roster = self.currentRoster;
    NSString *authQuestion = roster.addFriendAuthMode==BMXRosterItem_AddFriendAuthMode_AnswerQuestion? roster.authQuestion:@"";
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:authQuestion.length>0 ? NSLocalizedString(@"Friend_verification_question", @"好友验证问题") : NSLocalizedString(@"Leave_a_message", @"留言")
                                                                   message:authQuestion
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", @"确定") style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
                                                         //响应事件
                                                         //得到文本信息
                                                         for(UITextField *text in alert.textFields){
                                                             MAXLog(@"text = %@", text.text);
                                                             if (authQuestion.length>0){
                                                                 [self addRosterId:roster.rosterId authAnswer:[text.text length] ? text.text : @""];
                                                             }else{
                                                                 [self addRosterId:roster.rosterId reason:[text.text length] ? text.text : @""];
                                                             }
                                                         }
                                                     }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"取消") style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {
                                                             //响应事件
                                                             MAXLog(@"action = %@", alert.textFields);
                                                         }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = authQuestion.length>0 ? NSLocalizedString(@"enter_answer", @"请输入答案") : NSLocalizedString(@"enter_message_for_group_application", @"请输入申请的留言信息");
    }];
    
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];

}

// 添加好友
- (void)addRosterId:(long long)rosterId reason:(NSString *)reason {
    [[[BMXClient sharedClient] rosterService] applyWithRosterId:rosterId message:reason completion:^(BMXError *error) {
        MAXLog(@"%lld", rosterId);
        if (!error) {
            [HQCustomToast showDialog:NSLocalizedString(@"Request_sent", @"已发出请求")];
            [self.navigationController popToRootViewControllerAnimated:YES];
            
        } else if (error.errorCode == BMXErrorCode_CurrentUserIsInRoster){
            [self.navigationController  popToRootViewControllerAnimated:NO];
            
            UITabBarController *bar =  (UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
            UINavigationController *currentNav =  (UINavigationController *)bar.selectedViewController;
            
            LHChatVC *vc = [[LHChatVC alloc] initWithRoster:self.currentRoster messageType:BMXMessage_MessageType_Single];
            vc.hidesBottomBarWhenPushed = YES;
            [currentNav pushViewController:vc animated:YES];
        } else {
            [HQCustomToast showDialog:[error description]];
        }
    }];
}

// 添加好友
- (void)addRosterId:(long long)rosterId authAnswer:(NSString *)authAnswer {
    [[[BMXClient sharedClient] rosterService] applyWithRosterId:rosterId message:@"" authAnswer:authAnswer completion:^(BMXError *error) {
        MAXLog(@"%lld", rosterId);
        if (!error) {
            [HQCustomToast showDialog:NSLocalizedString(@"Friend_request_sent", @"已发送添加好友申请")];
            [self.navigationController popViewControllerAnimated:YES];

        } else {
            [HQCustomToast showDialog:[error description]];
        }
    }];
}

- (NSArray *)cellDataArray {
    if (!_cellDataArray) {
        _cellDataArray = [NSArray array];
    }
    return _cellDataArray;
}

- (void)setupHeaderView {
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MAXScreenW, 120.f)];
    self.headerView.backgroundColor = [UIColor whiteColor];
    
    [self avatarImageView];
    [self nameLabel];
    [self userIDLabelCap];
    [self userIDLabel];
}

- (void)setupFooterView {
    if (self.currentRoster.relation == BMXRosterItem_RosterRelation_Friend) {
        self.footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MAXScreenW, 120.f)];
        self.footerView.backgroundColor = [UIColor lh_colorWithHex:0xf8f8f8];
        [self startChatButton];
        [self videoCallButton];
        [self voiceCallButton];
    }
}

- (void)startChat{
    LHChatVC *chatVC = [[LHChatVC alloc] initWithRoster:self.currentRoster messageType:BMXMessage_MessageType_Single];
    [chatVC setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:chatVC animated:YES];
}

- (UIButton *)startChatButton {
    if (!_startChatButton) {
        _startChatButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_startChatButton addTarget:self action:@selector(startChat) forControlEvents:UIControlEventTouchUpInside];
        [self.footerView addSubview:_startChatButton];
        [_startChatButton setTitle:NSLocalizedString(@"start_chat", @"开始聊天") forState:UIControlStateNormal];
        [_startChatButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_startChatButton setBackgroundColor:[UIColor whiteColor]];
        _startChatButton.titleLabel.font =  [UIFont fontWithName:@"PingFangSC-Regular" size:17];
        _startChatButton.bmx_size = CGSizeMake(MAXScreenW, self.currentRoster.relation == BMXRosterItem_RosterRelation_Friend ? FOOTER_BUTTON_HEIGHT: 1);
        _startChatButton.bmx_centerX = MAXScreenW / 2.0;
        _startChatButton.bmx_centerY = self.currentRoster.relation == BMXRosterItem_RosterRelation_Friend ? FOOTER_BUTTON_HEIGHT / 2.0 + FOOTER_BUTTON_PADDING : FOOTER_BUTTON_HEIGHT / 2.0 * -1;
    }
    return _startChatButton;
}

- (UIButton *)videoCallButton {
    if (!_videoCallButton) {
        _videoCallButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_videoCallButton addTarget:self action:@selector(videoCall) forControlEvents:UIControlEventTouchUpInside];
        [self.footerView addSubview:_videoCallButton];
        [_videoCallButton setTitle:NSLocalizedString(@"Video_call", @"视频通话") forState:UIControlStateNormal];
        [_videoCallButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_videoCallButton setBackgroundColor:[UIColor whiteColor]];
        _videoCallButton.titleLabel.font =  [UIFont fontWithName:@"PingFangSC-Regular" size:17];
        _videoCallButton.bmx_size = CGSizeMake(MAXScreenW, FOOTER_BUTTON_HEIGHT);
        _videoCallButton.bmx_centerX = MAXScreenW / 2.0;
        _videoCallButton.bmx_centerY = _startChatButton.bmx_centerY + FOOTER_BUTTON_HEIGHT + FOOTER_BUTTON_PADDING;
    }
    return _videoCallButton;
}

- (UIButton *)voiceCallButton {
    if (!_voiceCallButton) {
        _voiceCallButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_voiceCallButton addTarget:self action:@selector(voiceCall) forControlEvents:UIControlEventTouchUpInside];
        [self.footerView addSubview:_voiceCallButton];
        [_voiceCallButton setTitle:NSLocalizedString(@"Voice_call", @"语音通话") forState:UIControlStateNormal];
        [_voiceCallButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_voiceCallButton setBackgroundColor:[UIColor whiteColor]];
        _voiceCallButton.titleLabel.font =  [UIFont fontWithName:@"PingFangSC-Regular" size:17];
        _voiceCallButton.bmx_size = CGSizeMake(MAXScreenW, FOOTER_BUTTON_HEIGHT);
        _voiceCallButton.bmx_centerX = MAXScreenW / 2.0;
        _voiceCallButton.bmx_centerY = _videoCallButton.bmx_centerY + FOOTER_BUTTON_HEIGHT + FOOTER_BUTTON_PADDING;
    }
    return _voiceCallButton;
}

#pragma mark - lazy load

- (UIImageView *)avatarImageView {
    if (!_avatarImageView) {
        
        _avatarImageView = [[UIImageView alloc] init];
        [self.headerView addSubview:_avatarImageView];
        
        CGFloat avatarImageViewLeft = 15;
        CGSize avatarImageViewSize = CGSizeMake(71, 71);
        _avatarImageView.bmx_size = avatarImageViewSize;
        _avatarImageView.bmx_centerY = self.headerView.bmx_centerY;
        _avatarImageView.bmx_left = avatarImageViewLeft;
        
    }
    return _avatarImageView;
}

- (CopyableLabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[CopyableLabel alloc] init];
        [self.headerView addSubview:_nameLabel];
        _nameLabel.text = @"Nick";
        _nameLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:20];
        _nameLabel.textColor = [UIColor blackColor];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        
        CGFloat nameLabelRight = 15;

        _nameLabel.bmx_left = self.avatarImageView.bmx_right + nameLabelRight;
        _nameLabel.size = CGSizeMake(MAXScreenW - nameLabelRight * 2 - _nameLabel.bmx_left, 30);
        _nameLabel.bmx_top = self.avatarImageView.bmx_top + 3;
    }
    return _nameLabel;
}

- (UILabel *)userIDLabelCap {
    if (!_userIDLabelCap) {
        _userIDLabelCap = [[UILabel alloc] init];
        [self.headerView addSubview:_userIDLabelCap];
        _userIDLabelCap.text = @"ID:";
        _userIDLabelCap.font = [UIFont systemFontOfSize:16];
        _userIDLabelCap.textColor = [UIColor blackColor];
        _userIDLabelCap.textAlignment = NSTextAlignmentLeft;
        [_userIDLabelCap sizeToFit];
        
        CGFloat nameLabelRight = 15;
        _userIDLabelCap.size = CGSizeMake(25, 30);
        _userIDLabelCap.bmx_top = self.nameLabel.bmx_bottom + 5;
        _userIDLabelCap.bmx_left = self.avatarImageView.bmx_right + nameLabelRight;
    }
    return _userIDLabelCap;
}

- (CopyableLabel *)userIDLabel {
    if (!_userIDLabel) {
        _userIDLabel = [[CopyableLabel alloc] init];
        [self.headerView addSubview:_userIDLabel];
        _userIDLabel.text = @"Nick";
        _userIDLabel.font = [UIFont systemFontOfSize:16];
        _userIDLabel.textColor = [UIColor blackColor];
        _userIDLabel.textAlignment = NSTextAlignmentLeft;
        [_userIDLabel sizeToFit];
        
        _userIDLabel.size = CGSizeMake(50, 30);
        _userIDLabel.bmx_top = self.userIDLabelCap.bmx_top;
        _userIDLabel.bmx_left = self.userIDLabelCap.bmx_right + 1;
    }
    return _userIDLabel;
}




@end
