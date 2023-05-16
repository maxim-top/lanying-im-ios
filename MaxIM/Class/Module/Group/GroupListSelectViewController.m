
//
//  GroupListSelectViewController.m
//  MaxIM
//
//  Created by 韩雨桐 on 2019/5/25.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "GroupListSelectViewController.h"
#import "ImageTitleBasicTableViewCell.h"
#import "LHChatVC.h"

#import "GroupCreateViewController.h"
#import "GroupInviteViewController.h"
#import "GroupApplyViewController.h"
#import "ImageAlertView.h"
#import <floo-ios/floo_proxy.h>

#import "IMAcountInfoStorage.h"
#import "IMAcount.h"

#import "UIViewController+CustomNavigationBar.h"

@interface GroupListSelectViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableview;

@property (nonatomic, strong) NSArray *groupArray;

@end

@implementation GroupListSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self getGroupList];
    [self setUpNavItem];
    [self tableView];
}

#pragma mark - Group Manager
// 获取群list
- (void)getGroupList {
    [HQCustomToast showWating];
    [[[BMXClient sharedClient] groupService] get:NO completion:^(BMXGroupList *groupList, BMXError *error) {
        MAXLog(@"%ld", groupList.size);
        [HQCustomToast hideWating];

        if (!error) {

            NSMutableArray *groupNormalArray = [NSMutableArray array];
            unsigned long sz = groupList.size;
            for (int i=0; i<sz; i++) {
                BMXGroup *group = [groupList get:i];
                if (group.groupStatus != BMXGroup_GroupStatus_Destroyed && group.roleType == BMXGroup_MemberRoleType_GroupMember) {
                    [groupNormalArray addObject:group];
                } else {
                    MAXLog(@"%lld", group.groupId);
                }
            }
            self.groupArray = groupNormalArray;
            [self.tableView reloadData];
        }
    }];
}

// 销毁群
- (void)destroyGroupWithGroup:(BMXGroup *)group {
    [[[BMXClient sharedClient] groupService] destroyWithGroup:group completion:^(BMXError *error) {
        if (!error) {
            MAXLog(@"销毁群");
            [self onGrouplistChange];
            [self.tableView reloadData];
        }
    }];
}

#pragma mark - TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return  self.groupArray.count ? self.rosterArray.count : 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ImageTitleBasicTableViewCell *cell = [ImageTitleBasicTableViewCell ImageTitleBasicTableViewCellWith:tableView];

    MAXLog(@"%lu", (unsigned long)self.groupArray.count);
        BMXGroup *group = self.groupArray[indexPath.row];
        [cell refreshByGroup:group];
        MAXLog(@"%@", group);
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    BMXGroup *group = self.rosterArray[indexPath.row];
    [self showImageAlertWithRoster:group];
}

- (UIImage *)getImage {
    NSString *suitName = @"group.com.maximtop.MaxIM.ShareExtention";
    
    NSURL *groupURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:suitName];
    NSURL *fileURL = [groupURL URLByAppendingPathComponent:@"incomingShared"];
    NSData *dictData = [[NSData alloc ]initWithContentsOfURL:fileURL];
    NSMutableArray *dicts = [NSKeyedUnarchiver unarchiveObjectWithData:dictData];
    //读取文件
    for (NSDictionary *dict in dicts) {
        UIImage * image = [[UIImage alloc]initWithData:dict[@"image"]];
        return image;
    }
    
    return nil;
}

- (BMXMessage *)configMessage:(id)attachment fromId:(long long) fromId toId:(long long) toId {
    BMXMessage *messageObject;
    
    messageObject = [BMXMessage createMessageWithFrom:fromId to:toId type:BMXMessage_MessageType_Group conversationId:toId attachment:attachment];
    return messageObject;
}

- (void)showImageAlertWithRoster:(BMXGroup *)group {
    ImageAlertView *alertView = [[ImageAlertView alloc] initWithFrame:CGRectMake(0, 0, MAXScreenW, MAXScreenH)];
    
    UIImage *avarart = [UIImage imageWithContentsOfFile:group.avatarThumbnailPath];
    UIImage *contentImg = [self getImage];
    if (!avarart) {
        avarart = [UIImage imageNamed:@"contact_placeholder"];
    }
    [alertView setAvarat:avarart nickName:group.name contentImg:contentImg];
    
    
    alertView.btnClickBlock = ^{
        
        UIImage *image = contentImg;
        NSData *imageData = UIImageJPEGRepresentation(image,1.0f);
        NSData *thumImageData =  UIImageJPEGRepresentation(image,1.0f);
        BMXMessageAttachmentSize *sz = [[BMXMessageAttachmentSize alloc] initWithWidth:image.size.width height:image.size.height];
        BMXImageAttachment *imageAttachment = [[BMXImageAttachment alloc] initWithData:imageData thumbnailData:thumImageData imageSize:sz displayName:@"" conversationId:group.groupId];
        IMAcount *account = [IMAcountInfoStorage loadObject];
        BMXMessage *messageObject = [self configMessage:imageAttachment fromId:[account.usedId longLongValue] toId:group.groupId];
        if (messageObject) {
            [[[BMXClient sharedClient] chatService] sendMessageWithMsg: messageObject];
            [self.navigationController popViewControllerAnimated:YES];
        }
    };
    
    [self.view addSubview:alertView];
    
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableView *)tableView {
    if (!_tableview) {
        _tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, NavHeight, MAXScreenW, MAXScreenH - NavHeight - TabBarHeight) style:UITableViewStylePlain];
        _tableview.delegate = self;
        _tableview.dataSource = self;
        [_tableview registerClass:[ImageTitleBasicTableViewCell class] forCellReuseIdentifier:@"ImageTitleBasicTableViewCell"];
        [self.view addSubview:_tableview];
    }
    return _tableview;
}

- (NSArray *)rosterArray {
    if (!_groupArray) {
        _groupArray = [NSArray array];
    }
    return _groupArray;
}

- (void)setUpNavItem{
    self.navigationController.navigationBar.barTintColor = BMXColorNavBar;
    self.navigationItem.title = NSLocalizedString(@"Group", @"群组");
}

- (NSArray *)groupArray {
    if (_groupArray == nil) {
        _groupArray = [NSArray array];
    }
    return _groupArray;
}

#pragma mark == delegate of create group
- (void) setNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onGrouplistChange) name:@"KGroupListModified" object:nil];
}

-(void) onGrouplistChange
{
    [self getGroupList];
}

@end
