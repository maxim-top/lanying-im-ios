


//
//  RosterListViewController.m
//  MaxIMShare
//
//  Created by 韩雨桐 on 2019/5/24.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "RosterListViewController.h"
#import <floo-ios/floo_proxy.h>

#import "ImageTitleBasicTableViewCell.h"
#import "IMAcountInfoStorage.h"
#import "IMAcount.h"
#import "ImageAlertView.h"
#import "MAXUtils.h"


@interface RosterListViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *rosterArray;

@property (nonatomic, copy) NSString *imageUrl;

@end

@implementation RosterListViewController


- (instancetype)initWithImageUrl:(NSString *)url {
    
    self = [self init];
    if (self) {
        
        _imageUrl = url;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self tableView];
    [self getAllRoster];
    [self.tableView reloadData];
}

// 获取好友列表
- (void)getAllRoster {
    [MAXUtils getAllRosterWithCompletion:^(NSArray *arr) {
        self.rosterArray = arr;
        [self.tableView reloadData];
    }];
}

- (void)showImageAlertWithRoster:(BMXRosterItem *)roster {
    ImageAlertView *alertView = [[ImageAlertView alloc] initWithFrame:CGRectMake(0, 0, MAXScreenW, MAXScreenH)];
    UIImage *avarart = [UIImage imageWithContentsOfFile:roster.avatarThumbnailPath];
    UIImage *contentImg = [self getImage];
    if (!avarart) {
        avarart = [UIImage imageNamed:@"contact_placeholder"];
    }
    [alertView setAvarat:avarart nickName:roster.username contentImg:contentImg];


    alertView.btnClickBlock = ^{

            UIImage *image = contentImg;
            NSData *imageData = UIImageJPEGRepresentation(image,1.0f);
            NSData *thumImageData =  UIImageJPEGRepresentation(image,1.0f);
            IMAcount *account = [IMAcountInfoStorage loadObject];
            BMXMessageAttachmentSize *sz = [[BMXMessageAttachmentSize alloc] initWithWidth:image.size.width height:image.size.height];
            BMXImageAttachment *imageAttachment = [[BMXImageAttachment alloc] initWithData:imageData thumbnailData:thumImageData imageSize:sz displayName:@"" conversationId: roster.rosterId];
            BMXMessage *msg;
            msg = [BMXMessage createMessageWithFrom:[account.usedId longLongValue] to:roster.rosterId type: BMXMessage_MessageType_Single conversationId:roster.rosterId attachment:imageAttachment];
            if (msg) {
                [[[BMXClient sharedClient] chatService] sendMessageWithMsg: msg completion:^(BMXError *aError) {
                }];
                [self.navigationController popViewControllerAnimated:YES];
            }
    };
    
    
    [self.view addSubview:alertView];
    
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

#pragma mark - TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.rosterArray.count ? self.rosterArray.count : 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ImageTitleBasicTableViewCell *cell = [ImageTitleBasicTableViewCell ImageTitleBasicTableViewCellWith:tableView];
    BMXRosterItem *roster = self.rosterArray[indexPath.row];
    [cell refresh:roster];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
     BMXRosterItem *roster = self.rosterArray[indexPath.row];
    [self showImageAlertWithRoster:roster];
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NavHeight, MAXScreenW, MAXScreenH - NavHeight - TabBarHeight) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[ImageTitleBasicTableViewCell class] forCellReuseIdentifier:@"ImageTitleBasicTableViewCell"];
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

- (NSArray *)rosterArray {
    if (!_rosterArray) {
        _rosterArray = [NSArray array];
    }
    return _rosterArray;
}


@end
