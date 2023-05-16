//
//  MAXBlackListViewController.m
//  MaxIM
//
//  Created by 韩雨桐 on 2018/12/17.
//  Copyright © 2018 hyt. All rights reserved.
//

#import "MAXBlackListViewController.h"
#import "ImageTitleBasicTableViewCell.h"
#import <floo-ios/floo_proxy.h>
#import "MAXUtils.h"
#import "UIViewController+CustomNavigationBar.h"
#import "MaxEmptyTipView.h"

@interface MAXBlackListViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableview;
@property (nonatomic, strong) NSArray *rosterIdArray;
@property (nonatomic, strong) NSArray *rosterArray;
@property (nonatomic, strong) MaxEmptyTipView *tipView;

@end

@implementation MAXBlackListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setUpNavItem];
    [self tableview];
    [self getBlackList];
}

- (void)setUpNavItem{
    [self setNavigationBarTitle: NSLocalizedString(@"Blacklist", @"黑名单") navLeftButtonIcon:@"blackback"];
}

- (void)addBlack:(UIButton *)button {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:NSLocalizedString(@"Add_to_blacklist", @"加入黑名单")
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"取消")
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Add", @"添加")
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull action) {
        UITextField *userNameTextField = alertController.textFields.firstObject;
        [self addToBlackList:userNameTextField.text];
        
    }]];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = NSLocalizedString(@"enter_the_userid_of_the_other_party", @"请输入对方的userid");
    }];
    
    [self presentViewController:alertController animated:true completion:nil];
}

#pragma mark - Manager
- (void)addToBlackList:(NSString *)userId {
    [[[BMXClient sharedClient] rosterService] blockWithRosterId:[userId longLongValue] completion:^(BMXError *error) {
        if (!error) {
            [self getBlackList];
        }
    }];
}

- (void)getBlackList {
    if (self.tipView) {
        [self.tipView removeFromSuperview];
    }

    [[[BMXClient sharedClient] rosterService] getBlockList:YES completion:^(ListOfLongLong *blockList, BMXError *error) {
        if (!error && blockList.size > 0 ) {
            [self searchRostersByidArray:blockList];
            MAXLog(@"%ld", blockList.size);
        } else {
            MAXLog(@"暂无黑名单");
            self.rosterIdArray = [NSArray array];
            self.rosterArray = [NSArray array];
            [self.tableview reloadData];
            [self.view insertSubview:self.tipView aboveSubview:self.tableview];
        }
    }];
}

// 批量搜索用户
- (void)searchRostersByidArray:(ListOfLongLong *)list {
    [MAXUtils getRostersByidArray:list completion:^(NSArray *arr) {
        self.rosterArray = arr;
        [self.tableview reloadData];
    }];
}

- (void)removeRoster:(NSInteger)rosterId {
    [[[BMXClient sharedClient] rosterService] unblockWithRosterId:rosterId
                                                         completion:^(BMXError *error) {
        if (!error) {
            [self getBlackList];
            MAXLog(@"%@", error);
        }
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BMXRosterItem *roster = self.rosterArray[indexPath.row];
    ImageTitleBasicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ImageTitleBasicTableViewCell"];
    [cell refresh:roster];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.rosterArray.count > 0 ? self.rosterArray.count : 0;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        BMXRosterItem *roster = self.rosterArray[indexPath.row];

        [self removeRoster:roster.rosterId];
        
            MAXLog(@"删除动作");
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return NSLocalizedString(@"Delete", @"删除");
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableView *)tableview {
    if (!_tableview) {
        _tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, NavHeight, MAXScreenW, MAXScreenH - NavHeight - kTabBarHeight) style:UITableViewStylePlain];
        [_tableview registerClass:[ImageTitleBasicTableViewCell class] forCellReuseIdentifier:@"ImageTitleBasicTableViewCell"];
        _tableview.delegate = self;
        _tableview.dataSource = self;
        _tableview.allowsMultipleSelection = NO;
        _tableview.allowsSelectionDuringEditing = NO;
        _tableview.allowsMultipleSelectionDuringEditing = NO;

        [self.view addSubview:_tableview];
    }
    return _tableview;
}

- (MaxEmptyTipView *)tipView {
    if (!_tipView) {
        
        CGFloat navh = kNavBarHeight;
        if (MAXIsFullScreen) {
            navh  = kNavBarHeight + 24;
        }
        _tipView = [[MaxEmptyTipView alloc] initWithFrame:CGRectMake(0, navh + 1 , MAXScreenW, MAXScreenH - navh - 37) type:MaxEmptyTipTypeBlocklist];
    }
    return _tipView;
}


@end
