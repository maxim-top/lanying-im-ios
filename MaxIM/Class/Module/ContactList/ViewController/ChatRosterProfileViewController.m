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
#import <floo-ios/BMXRoster.h>
#import <floo-ios/BMXClient.h>
#import "UIViewController+CustomNavigationBar.h"

@interface ChatRosterProfileViewController ()<UITableViewDelegate, UITableViewDataSource, TitleSwitchTableViewCellDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *footView;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIButton *beginChatButton;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *userIDLabel;
@property (nonatomic, strong) NSArray *cellDataArray;
@property (nonatomic, strong) BMXRoster *currentRoster;

@end

@implementation ChatRosterProfileViewController

- (instancetype)initWithRoster:(BMXRoster *)roster {
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
    
    if ([self.currentRoster.userName length]) {
        self.nameLabel.text = [NSString stringWithFormat:@"%@", [self.currentRoster.nickName length] ? self.currentRoster.nickName : self.currentRoster.userName];
        [self.nameLabel sizeToFit];
    }
    
    self.userIDLabel.text = [NSString stringWithFormat:@"ID:%lld", self.currentRoster.rosterId];
    [self.userIDLabel sizeToFit];
    
    self.cellDataArray = [self getSettingConfigDataArray];
    [self.tableView reloadData];
    
    [self getRosterInfo];
}

- (void)setalis:(NSString *)name {
    [[[BMXClient sharedClient] rosterService] updateItemAliasByRoster:self.currentRoster aliasJson:name completion:^(BMXRoster *roster, BMXError *error) {
        if (!error) {
            [HQCustomToast showDialog:NSLocalizedString(@"Set_successfully", @"设置成功")];
            [[[BMXClient sharedClient] rosterService] searchByRosterId:self.currentRoster.rosterId forceRefresh:YES completion:^(BMXRoster *roster, BMXError *error) {
                if (!error) {
                    self.currentRoster = roster;
                    [self.tableView reloadData];
                }
            }];
        }
    }];
}

- (void)getRosterInfo {
    [[[BMXClient sharedClient] rosterService] searchByRosterId:self.currentRoster.rosterId forceRefresh:YES completion:^(BMXRoster *roster, BMXError *error) {
        if (!error) {
            self.currentRoster = roster;
            [self.tableView reloadData];
        }
    }];
}

- (NSArray *)getSettingConfigDataArray {
    NSDictionary *configDic = [NSDictionary dictionaryWithDictionary:[self readLocalFileWithName:@"chatdetailproiledetail"]];
    MAXLog(@"%@", configDic);
    NSMutableArray *dataArray = [NSMutableArray array];
    for (NSDictionary *dic in configDic[@"cells"]) {
        [dataArray addObject:dic];
    }
    MAXLog(@"%@", dataArray);
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
        cell.contentLabel.text = [NSString stringWithFormat:@"%@", self.currentRoster.json_PublicInfo];
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else if ([dic[@"type"] isEqualToString:NSLocalizedString(@"Username", @"用户名")]) {
        cell.contentLabel.text = [NSString stringWithFormat:@"%@", self.currentRoster.userName];
    } else if ([dic[@"type"] isEqualToString:NSLocalizedString(@"Set_extension_info", @"设置扩展信息")]) {
        cell.contentLabel.text = [NSString stringWithFormat:@"%@", self.currentRoster.json_ext];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator; //显示最右边的箭头
    }  else  if ([dic[@"type"] isEqualToString:NSLocalizedString(@"Set_alias", @"设置别名")]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator; //显示最右边的箭头
        cell.contentLabel.text = [NSString stringWithFormat:@"%@", self.currentRoster.json_alias];

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
        [[[BMXClient sharedClient] rosterService] muteNotificationByRoster:self.currentRoster muteNotificationStatus:state completion:^(BMXRoster *roster, BMXError *error) {
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
                                                                 [self setalis:text.text];
                                                                 
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
    }
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NavHeight, MAXScreenW, MAXScreenH - NavHeight - TabBarHeight) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        [self setupHeaderView];
        _tableView.tableHeaderView = self.headerView;
        
        _tableView.tableHeaderView.bmx_height = 120.f;
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

- (void)setUpNavItem{
    [self setNavigationBarTitle:self.currentRoster.userName navLeftButtonIcon:@"blackback"];
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
    [self userIDLabel];
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

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        [self.headerView addSubview:_nameLabel];
        _nameLabel.text = @"Nick";
        _nameLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:20];
        _nameLabel.textColor = [UIColor blackColor];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        [_nameLabel sizeToFit];
        
        CGFloat nameLabelRight = 15;
        _nameLabel.size = CGSizeMake(80, 30);
        _nameLabel.bmx_top = self.avatarImageView.bmx_top + 3;
        _nameLabel.bmx_left = self.avatarImageView.bmx_right + nameLabelRight;
    }
    return _nameLabel;
}

- (UILabel *)userIDLabel {
    if (!_userIDLabel) {
        _userIDLabel = [[UILabel alloc] init];
        [self.headerView addSubview:_userIDLabel];
        _userIDLabel.text = @"Nick";
        _userIDLabel.font = [UIFont systemFontOfSize:16];
        _userIDLabel.textColor = [UIColor blackColor];
        _userIDLabel.textAlignment = NSTextAlignmentLeft;
        [_userIDLabel sizeToFit];
        
        CGFloat nameLabelRight = 15;
        _userIDLabel.size = CGSizeMake(80, 30);
        _userIDLabel.bmx_top = self.nameLabel.bmx_bottom + 5;
        _userIDLabel.bmx_left = self.avatarImageView.bmx_right + nameLabelRight;
    }
    return _userIDLabel;
}




@end
