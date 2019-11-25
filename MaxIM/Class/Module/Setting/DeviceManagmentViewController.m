//
//  ----------------------------------------------------------------------
//   File    :  DeviceManagmentViewController.m
//   Author  : HYT yutong@bmxlabs.com
//   Purpose :
//   Created : 2019/2/1 by HYT yutong@bmxlabs.com
//
//  ----------------------------------------------------------------------
//
//                    Copyright (C) 2018-2019   MaxIM.Top
//
// You may obtain a copy of the licence at http://www.maxim.top/LICENCE-MAXIM.md
//
//  ----------------------------------------------------------------------
    

#import "DeviceManagmentViewController.h"
#import "DeviceTableViewCell.h"
#import <floo-ios/BMXClient.h>
#import <floo-ios/BMXDevice.h>
#import "IMAcountInfoStorage.h"
#import "IMAcount.h"
#import "UIViewController+CustomNavigationBar.h"

@interface DeviceManagmentViewController ()<UITableViewDelegate, UITableViewDataSource, DeviceTableViewCellDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *deviceListArray;
@property (nonatomic, strong) IMAcount *account;

@end

@implementation DeviceManagmentViewController

- (void)viewDidLoad {
    self.view.backgroundColor = [UIColor whiteColor];
    [super viewDidLoad];
    [self setUpNavItem];
    [self getDeviceList];
    
    self.account = [IMAcountInfoStorage loadObject];
    
}

- (void)getDeviceList {
    [[[BMXClient sharedClient] userService] getDeviceListCompletion:^(BMXError *error, NSArray *deviceList) {
        if (!error) {
            self.deviceListArray  = [NSArray arrayWithArray:deviceList];
            [self.tableView reloadData];
        }
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100.f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.deviceListArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (void)deviceTableViewCelldidClickButtonWithDevice:(BMXDevice *)device {
    [[[BMXClient sharedClient] userService] deleteDeviceByDeviceSN:device.deviceSN completion:^(BMXError *error) {
        if (!error) {
            [HQCustomToast showDialog:@"删除成功"];
            [self getDeviceList];
        }
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DeviceTableViewCell *cell = [DeviceTableViewCell cellWithTableView:tableView];
    cell.delegate = self;
    BMXDevice *device = self.deviceListArray[indexPath.row];
    cell.device = device;
    
    
    
    if (device.isCurrentDevice == YES) {
        [cell hiddenDeleteButton:YES];
    } else {
        [cell hiddenDeleteButton:NO];
    }


    NSString *decStr = @"";
    if (device.platform == 0) {
        decStr = @"iOS";
    } else if (device.platform == 1) {
        decStr = @"android";
    } else if (device.platform == 2) {
        decStr = @"windows";
    } else if (device.platform == 3) {
        decStr = @"mac";
    } else if (device.platform == 4) {
        decStr = @"linux";
    } else if (device.platform == 5) {
        decStr = @"web";
    }
    
    cell.titleLabel.text = [NSString stringWithFormat:@"设备序列号：%d", device.deviceSN];
    cell.contentLabel.text = device.userAgent;
    return cell;
}

- (void)setUpNavItem{
    [self setNavigationBarTitle:@"设备列表" navLeftButtonIcon:@"blackback"];
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

@end
