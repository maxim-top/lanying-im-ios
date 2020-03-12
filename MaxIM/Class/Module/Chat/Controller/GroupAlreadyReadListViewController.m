//
//  GroupAlreadyReadListViewController.m
//  MaxIM
//
//  Created by 韩雨桐 on 2019/8/22.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "GroupAlreadyReadListViewController.h"
#import "ImageTitleBasicTableViewCell.h"
#import <floo-ios/BMXClient.h>
#import <floo-ios/BMXRoster.h>
#import <floo-ios/BMXGroupMember.h>
#import "UIViewController+CustomNavigationBar.h"
#import <floo-ios/BMXMessageConfig.h>

@interface GroupAlreadyReadListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *leftTableView;
@property (nonatomic, strong) UITableView *rightTableView;
@property (nonatomic, strong) BMXMessageObject *message;
@property (nonatomic, strong) UISegmentedControl *segment;
@property (nonatomic, strong) UIView *selectView;
@property (nonatomic,assign) NSInteger tag;
@property (nonatomic, strong) BMXGroup *group;
@property (nonatomic, strong) NSArray *unReadRosterArray;
@property (nonatomic, strong) NSArray *alreadyRosterArray;
@property (nonatomic, strong) NSArray *alreadyRosterIdArray;



@end

@implementation GroupAlreadyReadListViewController

- (instancetype)initWithMessage:(BMXMessageObject *)messageObject group:(BMXGroup *)group {
    if (self = [super init]) {
        self.message = messageObject;
        self.group = group;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setUpNavItem];
    [self segment];
    [self selectView];
    [self leftTableView];
    [self getAlreadyRoster];
}

- (void)getAlreadyRoster {
    [[[BMXClient sharedClient] chatService] getGroupAckMessageUserIdListWithMessage:self.message completion:^(NSArray *groupMemberIdList, BMXError *error) {
        self.alreadyRosterIdArray = groupMemberIdList;
        [[[BMXClient sharedClient] rosterService] searchRostersByRosterIdList:groupMemberIdList forceRefresh:NO completion:^(NSArray<BMXRoster *> *rosterList, BMXError *error) {
            self.alreadyRosterArray = rosterList;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.leftTableView reloadData];
            });

        }];
    }];
}

- (void)selectViewAnimationWithTag:(NSInteger)tag {
    if (tag == 0) {
        [UIView animateWithDuration:0.3 animations:^{
            self.selectView.x = 0;
        }];
    } else {
        [UIView animateWithDuration:0.3 animations:^{
            self.selectView.x = MAXScreenW / 2.0;
        }];
    }
}

- (void)getUnreadRoster {
    MAXLog(@"拉取未读群成员");
    
    
    [[[BMXClient sharedClient] chatService] getGroupAckMessageUnreadUserIdListWithMessage:self.message completion:^(NSArray *groupMemberIdList, BMXError *error) {
        [[[BMXClient sharedClient] rosterService] searchRostersByRosterIdList:groupMemberIdList forceRefresh:NO completion:^(NSArray<BMXRoster *> *rosterList, BMXError *error) {
            [HQCustomToast hideWating];
            self.unReadRosterArray = rosterList;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.rightTableView reloadData];
            });
        }];
        
    }];
    
//    [HQCustomToast showWating];
//    [[[BMXClient sharedClient] groupService] getMembers:self.group forceRefresh:NO completion:^(NSArray<BMXGroupMember *> *groupList, BMXError *error) {
//        NSMutableArray *arrayM = [NSMutableArray array];
//        for (BMXGroupMember *member in groupList) {
//            NSString *memberUid = [NSString stringWithFormat:@"%ld", member.uid];
//            [arrayM addObject:memberUid];
//            if (self.message.groupAckCount > 0) {
//                for (NSString *uid in self.alreadyRosterIdArray) {
//                    if ([memberUid isEqualToString:uid]) {
//                    } else {
//                        [arrayM removeObject:uid];
//                    }
//                }
//            }
//        }
//
//        [[[BMXClient sharedClient] rosterService] searchRostersByRosterIdList:arrayM forceRefresh:NO completion:^(NSArray<BMXRoster *> *rosterList, BMXError *error) {
//            [HQCustomToast hideWating];
//            self.unReadRosterArray = rosterList;
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.rightTableView reloadData];
//            });
//        }];
//    }];
}

-(void)indexDidChangeForSegmentedControl:(UISegmentedControl *)sender {
    NSInteger selecIndex = sender.selectedSegmentIndex;
    switch(selecIndex){
        case 0:
            self.leftTableView.hidden = NO;
            self.rightTableView.hidden = YES;
            sender.selectedSegmentIndex=0;
            self.tag = 0;
            [self.leftTableView reloadData];
            [self selectViewAnimationWithTag:self.tag];
            break;
            
        case 1:
            self.leftTableView.hidden = YES;
            self.rightTableView.hidden = NO;
            sender.selectedSegmentIndex = 1;
            self.tag = 1;
            [self getUnreadRoster];
            [self.rightTableView reloadData];
            [self selectViewAnimationWithTag:self.tag];

            break;
            
        default:
            break;
    }
}

#pragma mark - TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.tag == 0) {
        return self.alreadyRosterArray.count;
    } else {
        return self.unReadRosterArray.count;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    ImageTitleBasicTableViewCell *cell = [ImageTitleBasicTableViewCell ImageTitleBasicTableViewCellWith:tableView];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    BMXRoster *roster;
    if (self.tag == 0) {
        roster = self.alreadyRosterArray[indexPath.row];
    } else {
        roster = self.unReadRosterArray[indexPath.row];
    }
    [cell refresh:roster];
    return cell;
}

- (UITableView *)leftTableView {
    if (!_leftTableView) {
        _leftTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NavHeight + 50, MAXScreenW, MAXScreenH - NavHeight - 50) style:UITableViewStylePlain];
        _leftTableView.delegate = self;
        _leftTableView.dataSource = self;
        [_leftTableView registerClass:[ImageTitleBasicTableViewCell class] forCellReuseIdentifier:@"ImageTitleBasicTableViewCell"];
        [self.view addSubview:_leftTableView];
    }
    return _leftTableView;
}

- (UITableView *)rightTableView {
    if (!_rightTableView) {
        _rightTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NavHeight + 50, MAXScreenW, MAXScreenH - NavHeight - 50) style:UITableViewStylePlain];
        _rightTableView.delegate = self;
        _rightTableView.dataSource = self;
        [_rightTableView registerClass:[ImageTitleBasicTableViewCell class] forCellReuseIdentifier:@"ImageTitleBasicTableViewCell"];
        [self.view addSubview:_rightTableView];
    }
    return _rightTableView;
}

- (NSArray *)alreadyRosterArray {
    if (!_alreadyRosterArray) {
        _alreadyRosterArray = [NSArray array];
    }
    return _alreadyRosterArray;
}

- (void)setUpNavItem {
    [self setNavigationBarTitle:@"消息接收人列表" navLeftButtonIcon:@"blackback"];
}

- (UISegmentedControl *)segment {
    if (!_segment) {
        _segment = [[UISegmentedControl alloc] initWithItems:@[@"已读列表", @"未读列表"]];
        _segment.frame = CGRectMake(0, NavHeight, self.view.width, 50);
        _segment.tintColor = [UIColor whiteColor];
        [_segment setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13], NSForegroundColorAttributeName:[UIColor blackColor]} forState:UIControlStateNormal];
        [_segment setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13], NSForegroundColorAttributeName:BMXCOLOR_HEX(0x0079F4)} forState:UIControlStateSelected];
        _segment.layer.borderColor = [UIColor whiteColor].CGColor;
        _segment.selectedSegmentIndex = 0;
        [_segment addTarget:self action:@selector(indexDidChangeForSegmentedControl:) forControlEvents:UIControlEventValueChanged];

        [self.view addSubview:_segment];
    }
    return _segment;
}

- (UIView *)selectView {
    if (!_selectView) {
        _selectView = [[UIView alloc] init];
        _selectView.frame = CGRectMake(0, NavHeight + 50 - 3, MAXScreenW / 2.0, 3);
        _selectView.backgroundColor = BMXCOLOR_HEX(0x0079F4);
        [self.view addSubview:_selectView];
    }
    return _selectView;
}

- (NSArray *)alreadyRosterIdArray {
    if (!_alreadyRosterIdArray) {
        _alreadyRosterIdArray = [NSArray array];
    }
    return  _alreadyRosterIdArray;
}

@end
