//
//  SDKConfigViewController.m
//  MaxIM
//
//  Created by 韩雨桐 on 2020/4/9.
//  Copyright © 2020 hyt. All rights reserved.
//

#import "SDKConfigViewController.h"
#import "UIView+BMXframe.h"
#import <floo-ios/BMXClient.h>
#import "UIViewController+CustomNavigationBar.h"
#import "TitleSwitchTableViewCell.h"
#import "HostConfigManager.h"
#import "AppDelegate.h"
#import "IMAcountInfoStorage.h"
#import "IMAcount.h"

@interface SDKConfigViewController ()<UITableViewDelegate, UITableViewDataSource,TitleSwitchTableViewCellDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSoource;

@property (nonatomic, assign) BOOL isUserServer;
@property (nonatomic, copy) NSString *IMServer;
@property (nonatomic, copy) NSString *IMPort;
@property (nonatomic, copy) NSString *restServer;

@property (nonatomic, assign) bool isChanged;

@end

@implementation SDKConfigViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self setNavigationBarTitle:NSLocalizedString(@"Configure", @"配置") navLeftButtonIcon:@"blackback" navRightButtonTitle:NSLocalizedString(@"Save", @"保存")];
    [self removeNavLeftButtonDefaultEvent];
    [self.navRightButton addTarget:self action:@selector(clickNavRightButton) forControlEvents:UIControlEventTouchUpInside];
    [self.navLeftButton addTarget:self action:@selector(clickNavleftButton) forControlEvents:UIControlEventTouchUpInside];
    
    if ([[BMXClient sharedClient] sdkConfig].enableDNS) {
        [HostConfigManager sharedManager].IMServer = @"";
        [HostConfigManager sharedManager].IMPort = @"";
        [HostConfigManager sharedManager].restServer = @"";
    }
    [self refreshData];
}

- (void)refreshData {
    
//    self.isUserServer = [HostConfigManager sharedManager].isUserServer;
        
        self.IMServer = [HostConfigManager sharedManager].IMServer.length > 0 ? [HostConfigManager sharedManager].IMServer : NSLocalizedString(@"Default", @"默认");
        self.IMPort = [HostConfigManager sharedManager].IMPort.length > 0 ? [HostConfigManager sharedManager].IMPort :NSLocalizedString(@"Default", @"默认");
        self.restServer = [HostConfigManager sharedManager].restServer.length > 0 ? [HostConfigManager sharedManager].restServer : NSLocalizedString(@"Default", @"默认");
        self.isUserServer = ([HostConfigManager sharedManager].IMServer.length > 0 || [HostConfigManager sharedManager].IMPort.length > 0 || [HostConfigManager sharedManager].restServer.length > 0);

    
    [self.tableView reloadData];
}

- (void)clickNavleftButton {
    if (self.delegate && [self.delegate respondsToSelector:@selector(sdkconfigdidClickReturn)]) {
        [self.delegate sdkconfigdidClickReturn];
    }
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)clickNavRightButton {
    
    if (self.isUserServer == NO) {
        
        [HostConfigManager sharedManager].IMServer = @"";
        [HostConfigManager sharedManager].IMPort = @"";
        [HostConfigManager sharedManager].restServer = @"";
        [[BMXClient sharedClient] sdkConfig].enableDNS = YES;
        
    } else {
        
        BOOL hasChanged = NO;
        if (![self.IMServer isEqualToString:NSLocalizedString(@"Default", @"默认")] && ![self.restServer isEqualToString:NSLocalizedString(@"Default", @"默认")] && ![self.IMPort isEqualToString:NSLocalizedString(@"Default", @"默认")]) {
            if (self.IMServer.length > 0 || [self.IMPort intValue] > 0 || self.restServer.length > 0) {
                [HostConfigManager sharedManager].IMServer =  self.IMServer;
                [HostConfigManager sharedManager].restServer =  self.restServer;
                [HostConfigManager sharedManager].IMPort =  self.IMPort;
                hasChanged = YES;
                [[BMXClient sharedClient] sdkConfig].verifyCertificate = NO;
            }
        }
        if (hasChanged) {
            [HQCustomToast showDialog:NSLocalizedString(@"Save_successfully", @"保存成功")];
        }else {
            
            [HQCustomToast showDialog:NSLocalizedString(@"complete_the_3_pieces_of_info", @"请填写三项完整信息")];
            [HostConfigManager sharedManager].IMServer = @"";
            [HostConfigManager sharedManager].IMPort = @"";
            [HostConfigManager sharedManager].restServer = @"";
            self.isUserServer = NO;
            [[BMXClient sharedClient] sdkConfig].enableDNS = YES;
            
        }
    }
    [[HostConfigManager sharedManager] updataConfig];
    [self refreshData];
}

- (void)showAlertWithTitle:(NSString *)title
                   Content:(NSString *)content {
    
    if (![title isEqualToString:@"AppID"] && !self.isUserServer) {
        
        [HQCustomToast showDialog:NSLocalizedString(@"Custom_services_not_launched_yet", @"尚未启动自定义服务")];
        return;
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"Modify_at", @"修改%@"),title] preferredStyle:UIAlertControllerStyleAlert];
    
     [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", @"确定") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
         UITextField *textField = alertController.textFields.firstObject;
         NSString *newValue = textField.text;
         if (newValue.length == 0 ) {
             [HQCustomToast showDialog:NSLocalizedString(@"Input_cannot_be_empty", @"输入不能为空")];
             return;
         }
         [self changeValue:newValue Type:title];
      
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"取消") style:UIAlertActionStyleDefault handler:nil]];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
      textField.text = content;
    }];
    
    [self presentViewController:alertController animated:true completion:nil];
}


- (void)changeValue:(NSString *)value Type:(NSString *)type {
    
    if ([type isEqualToString:@"AppID"]) {
        [self reloadLocalAppID:value];
    }else if ([type isEqualToString:@"IM Server"]) {
        self.IMServer = value;
    }else if ([type isEqualToString:@"IM Port"]) {
        int port = [value intValue];
        if (port > 0) {
            self.IMPort = value;
        }else {
            [HQCustomToast showDialog:NSLocalizedString(@"Incorrect_format", @"格式不正确")];
        }
    }else if ([type isEqualToString:@"Rest Server"]) {
        self.restServer = value;
    }
    [self.tableView reloadData];
    
}


- (void)reloadLocalAppID:(NSString *)appid {
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate reloadAppID:appid];

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger index = indexPath.section * 1 + indexPath.row;
    NSDictionary *dict = self.dataSoource[index];
    NSString *type = dict[@"type"];
    NSString *control = dict[@"control"];
    NSString *content = @"";
    
    TitleSwitchTableViewCell *cell = [TitleSwitchTableViewCell cellWithTableView:tableView];
    cell.delegate = self;
    if ([type isEqualToString:@"AppID"]) {
        content = [[BMXClient sharedClient] sdkConfig].appID;
    }else if ([type isEqualToString:@"IM Server"]) {
        content = self.IMServer;
    }else if ([type isEqualToString:@"IM Port"]) {
        content = self.IMPort;
    }else if ([type isEqualToString:@"Rest Server"]) {
        content = self.restServer;
    }
             
     if ([control isEqualToString:@"0"]) {
         cell.contentLabel.text = content;
         [cell.mswitch setHidden:YES];
     } else {
         [cell.mswitch setHidden:NO];
         cell.contentLabel.text = nil;
         [cell.mswitch setOn:self.isUserServer];
     }

    cell.titleLabel.text = type;
           
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger index = indexPath.section * 1 + indexPath.row;
    NSDictionary *dict = self.dataSoource[index];
    NSString *type = dict[@"type"];
    NSString *content = dict[@"control"];
    if ([content isEqualToString: @"1"]) {
        
        return;
    }
    
    [self showAlertWithTitle:type Content:@""];
    
}

- (void)cellDidchangeSwitchStatus:(UISwitch *)mswtich
                             cell:(TitleSwitchTableViewCell *)cell {
    
    if (!mswtich.isOn && (self.IMServer.length > 0 || [self.IMPort intValue] > 0 || self.restServer.length > 0)) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"sure_to_turn_off_the_custom_services", @"您确认要关闭自定义服务吗") preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"取消") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [mswtich setOn:YES];
            self.isUserServer = YES;
        }]];
           [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", @"确定") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
               self.isUserServer = NO;
               [self clickNavRightButton];
           }]];
           [self presentViewController:alertController animated:YES completion:nil];
        
        
    }else {
        
        self.isUserServer = mswtich.isOn;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    return  self.dataSoource.count - 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2;
}

- (UITableView *)tableView {
    if (_tableView == nil) {
        CGFloat x = 0;
        CGFloat y = NavHeight;
        CGFloat w = MAXScreenW;
        CGFloat h = MAXScreenH;
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(x, y, w, h) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self.view addSubview:self.tableView];
    }
    return _tableView;
}

- (NSArray *)dataSoource {
    if (!_dataSoource) {
        NSDictionary *configDic = [NSDictionary dictionaryWithDictionary:[self readLocalFileWithName:@"appsetting"]];
        MAXLog(@"%@", configDic);
        NSMutableArray *dataArray = [NSMutableArray array];
        for (NSDictionary *dic in configDic[@"cells"]) {
            [dataArray addObject:dic];
        }
        MAXLog(@"%@", dataArray);
        _dataSoource =  dataArray;
    }
    return _dataSoource;
}


- (NSDictionary *)readLocalFileWithName:(NSString *)name {
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"json"];
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    return [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
}

@end
