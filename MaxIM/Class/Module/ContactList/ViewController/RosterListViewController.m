


//
//  RosterListViewController.m
//  MaxIMShare
//
//  Created by 韩雨桐 on 2019/5/24.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "RosterListViewController.h"
#import <floo-ios/BMXClient.h>
#import "ImageTitleBasicTableViewCell.h"
#import "IMAcountInfoStorage.h"
#import "IMAcount.h"
#import <floo-ios/BMXRoster.h>
#import <floo-ios/BMXImageAttachment.h>
#import "ImageAlertView.h"


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
    [[[BMXClient sharedClient] rosterService] getRosterListforceRefresh:NO completion:^(NSArray *rostIdList, BMXError *error) {
        if (!error) {
            NSLog(@"%lu", (unsigned long)rostIdList.count);
            [self searchRostersByidArray:[NSArray arrayWithArray:rostIdList]];
        }
    }];
}

// 批量搜索用户
- (void)searchRostersByidArray:(NSArray *)idArray {
    [[[BMXClient sharedClient] rosterService] searchRostersByRosterIdList:idArray forceRefresh:NO completion:^(NSArray<BMXRoster *> *rosterList, BMXError *error) {
        
        if (!error) {
            NSLog(@"%lu", (unsigned long)rosterList.count);
            self.rosterArray = [NSArray arrayWithArray:rosterList];
            [self.tableView reloadData];
        } else {
            
        }
    }];
}

- (void)showImageAlertWithRoster:(BMXRoster *)roster {
    ImageAlertView *alertView = [[ImageAlertView alloc] initWithFrame:CGRectMake(0, 0, MAXScreenW, MAXScreenH)];
    
    UIImage *avarart = [UIImage imageWithContentsOfFile:roster.avatarThumbnailPath];
    UIImage *contentImg = [self getImage];
    if (!avarart) {
        avarart = [UIImage imageNamed:@"contact_placeholder"];
    }
    [alertView setAvarat:avarart nickName:roster.userName contentImg:contentImg];
    
    
    alertView.btnClickBlock = ^{
        
            UIImage *image = contentImg;
            NSData *imageData = UIImageJPEGRepresentation(image,1.0f);
            NSData *thumImageData =  UIImageJPEGRepresentation(image,1.0f);
            BMXImageAttachment *imageAttachment = [[BMXImageAttachment alloc] initWithData:imageData thumbnailData:thumImageData imageSize:image.size conversationId:[NSString stringWithFormat:@"%lld",roster.rosterId]];
            imageAttachment.pictureSize = CGSizeMake(image.size.width, image.size.height);
            IMAcount *account = [IMAcountInfoStorage loadObject];
        BMXMessageObject *messageObject = [[BMXMessageObject alloc] initWithBMXMessageAttachment:imageAttachment fromId:[account.usedId longLongValue] toId:roster.rosterId type:BMXMessageTypeSingle conversationId:roster.rosterId];
            messageObject.contentType = BMXContentTypeImage;
        if (messageObject) {
            [[[BMXClient sharedClient] chatService] sendMessage:messageObject completion:^(BMXMessageObject *message, BMXError *error) {
            }];
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    };
    
    
    [self.view addSubview:alertView];
    
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
    BMXRoster *roster = self.rosterArray[indexPath.row];
    [cell refresh:roster];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
     BMXRoster *roster = self.rosterArray[indexPath.row];
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
