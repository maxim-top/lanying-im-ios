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
#import <floo-ios/floo_proxy.h>

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
    [[[BMXClient sharedClient] userService] getDeviceListWithCompletion:^(BMXDeviceList *deviceList, BMXError *error) {
        if (!error) {
            unsigned long sz = deviceList.size;
            NSMutableArray *arr = [[NSMutableArray alloc] init];
            for (int i=0; i<sz; i++) {
                [arr addObject:[deviceList get:i]];
            }
            self.deviceListArray  = arr;
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

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 添加一个删除按钮
    
    UITableViewRowAction *deleteRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:NSLocalizedString(@"Delete", @"删除")handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        BMXDevice *device = self.deviceListArray[indexPath.row];
        [[[BMXClient sharedClient] userService] deleteDeviceWithDeviceSn:device.deviceSN completion:^(BMXError *error) {
            if (!error) {
                [HQCustomToast showDialog:NSLocalizedString(@"Delete_successfully", @"删除成功")];
                [self getDeviceList];
            }
        }];

        MAXLog(@"点击了删除");
    }];
    
    return @[deleteRowAction];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (void)deviceTableViewCelldidClickButtonWithDevice:(BMXDevice *)device {
    [[[BMXClient sharedClient] userService] deleteDeviceWithDeviceSn:device.deviceSN completion:^(BMXError *error) {
        if (!error) {
            [HQCustomToast showDialog:NSLocalizedString(@"Delete_successfully", @"删除成功")];
            [self getDeviceList];
        }
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DeviceTableViewCell *cell = [DeviceTableViewCell cellWithTableView:tableView];
    cell.delegate = self;
    BMXDevice *device = self.deviceListArray[indexPath.row];
    cell.device = device;
    
    
    //Remove delete buttons, move to right swipe menu.
    [cell hiddenDeleteButton:YES];

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
    
    cell.titleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Device_serial_numberN", @"设备序列号：%d"), device.deviceSN];
    cell.contentLabel.text = device.userAgent;
    return cell;
}

- (void)setUpNavItem{
    [self setNavigationBarTitle:NSLocalizedString(@"Device_list", @"设备列表") navLeftButtonIcon:@"blackback"];
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NavHeight, MAXScreenW, MAXScreenH - NavHeight - kTabBarHeight) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

@end
