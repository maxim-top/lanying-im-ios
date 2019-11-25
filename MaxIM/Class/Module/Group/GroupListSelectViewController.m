
//
//  GroupListSelectViewController.m
//  MaxIM
//
//  Created by 韩雨桐 on 2019/5/25.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "GroupListSelectViewController.h"
#import "ImageTitleBasicTableViewCell.h"
#import <floo-ios/BMXClient.h>
#import "LHChatVC.h"

#import "GroupCreateViewController.h"
#import "GroupInviteViewController.h"
#import "GroupApplyViewController.h"
#import "ImageAlertView.h"
#import <floo-ios/BMXImageAttachment.h>

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
    [[[BMXClient sharedClient] groupService] getGroupListForceRefresh:NO completion:^(NSArray *groupList, BMXError *error) {
        MAXLog(@"%ld", groupList.count);
        [HQCustomToast hideWating];
        
        if (!error) {
            
            NSMutableArray *groupNormalArray = [NSMutableArray array];
            for (BMXGroup *group in groupList) {
                
                if (group.groupStatus != BMXGroupDestroyed && group.isMember == YES) {
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
    [[[BMXClient sharedClient] groupService] destroyGroup:group completion:^(BMXError *error) {
        if (!error) {
            MAXLog(@"销毁群");
            [self onGrouplistChange];
            [self.tableView reloadData];
        }
    }];
}

#pragma mark - TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return  self.groupArray.count ? self.rosterArray.count : 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ImageTitleBasicTableViewCell *cell = [ImageTitleBasicTableViewCell ImageTitleBasicTableViewCellWith:tableView];

        MAXLog(@"%ld", self.groupArray.count);
        BMXGroup *group = self.groupArray[indexPath.row];
        [cell refreshByGroup:group];
        MAXLog(@"%@", group);
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    BMXRoster *roster = self.rosterArray[indexPath.row];
    [self showImageAlertWithRoster:roster];
}

- (UIImage *)getImage {
    NSString *suitName = @"group.top.maxim.MaxIM.MaxIMShare";
    
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
        BMXImageAttachment *imageAttachment = [[BMXImageAttachment alloc] initWithData:imageData thumbnailData:thumImageData imageSize:image.size conversationId:[NSString stringWithFormat:@"%lld",group.groupId]];
        imageAttachment.pictureSize = CGSizeMake(image.size.width, image.size.height);
        IMAcount *account = [IMAcountInfoStorage loadObject];
        BMXMessageObject *messageObject = [[BMXMessageObject alloc] initWithBMXMessageAttachment:imageAttachment fromId:[account.usedId longLongValue] toId:group.groupId type:BMXMessageTypeGroup conversationId:group.groupId];
        messageObject.contentType = BMXContentTypeImage;
        if (messageObject) {
            [[[BMXClient sharedClient] chatService] sendMessage:messageObject completion:^(BMXMessageObject *message, BMXError *error) {
            }];
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
    self.navigationItem.title = @"群组";
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
