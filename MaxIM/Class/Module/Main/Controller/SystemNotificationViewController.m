//
//  SystemNotificationViewController.m
//  MaxIM
//
//  Created by 韩雨桐 on 2019/10/23.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "SystemNotificationViewController.h"
#import "UIViewController+CustomNavigationBar.h"
#import "SystemNotificationTableViewCell.h"
#import "BMXClient.h"
#import "BMXMessageObject.h"

@interface SystemNotificationViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableview;
@property (nonatomic, strong) NSArray *messageArray;

@end

@implementation SystemNotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self p_setNavBar];
    [self tableview];

    [self loadMessages];
}

- (void)p_setNavBar {
    [self setNavigationBarTitle:@"系统通知" navLeftButtonIcon:@"blackback"];
}

- (void)loadMessages {
    [[[BMXClient sharedClient] chatService] retrieveHistoryBMXconversation:self.conversation msgId:0 size:10 completion:^(NSArray *messageListms, BMXError *error) {
        MAXLog(@"%lu", (unsigned long)messageListms.count);
        if (messageListms.count > 0) {
            self.messageArray = messageListms;
            [self.tableview reloadData];
        } else {
            
        }
    }];

}

- (NSString *)compareCurrentTime:(NSTimeInterval)currentDate
                    comepareDate:(NSTimeInterval)comepareDate{
    
    NSTimeInterval  timeInterval = currentDate - comepareDate;
    if (timeInterval < 0) {
        timeInterval = -timeInterval;
    }
    long temp = 0;
    NSString *result;
    if (timeInterval < 60) {
        result = [NSString stringWithFormat:@"刚刚"];
    }else if((temp = timeInterval/60) < 60){
        result = [NSString stringWithFormat:@"%ld分钟前",temp];
    }else if((temp = temp/60) < 24){
        
        NSDate *messageDate = [NSDate dateWithTimeIntervalSince1970:comepareDate];
        NSDateFormatter * df = [[NSDateFormatter alloc]init];
        [df setDateFormat:@"hh:mm aa"];
        [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:8*3600]];
        result = [df stringFromDate:messageDate];;
    }else {
        NSDate *messageDate = [NSDate dateWithTimeIntervalSince1970:comepareDate];
        NSDateFormatter * df = [[NSDateFormatter alloc]init];
        [df setDateFormat:@"MM-dd hh:mm"];
        [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:8*3600]];
        result = [df stringFromDate:messageDate];;
    }
    return  result;
}

#pragma mark - UITableView
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    BMXMessageObject *message = self.messageArray[indexPath.row];
    SystemNotificationTableViewCell *cell = [SystemNotificationTableViewCell cellWithTableview:tableView];
    cell.titleLabel.text = @"【系统消息】";
    cell.subtitleLabel.text = message.content;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.avatarImageView.image = [UIImage imageNamed:@"systemAvater"];
    if (message.serverTimestamp > 0) {
        cell.timeLabel.hidden = NO;
        cell.timeLabel.text = [self compareCurrentTime:[[NSDate date] timeIntervalSince1970] comepareDate:message.serverTimestamp * 0.001];;
    } else {
        cell.timeLabel.hidden = YES;
    }
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 68.f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messageArray.count > 0 ? self.messageArray.count : 0;
}

- (NSArray *)messageArray {
    if (!_messageArray) {
        _messageArray = [NSArray array];
    }
    return _messageArray;
}

- (UITableView *)tableview {
    if (!_tableview) {
        _tableview = [[UITableView alloc] initWithFrame:CGRectMake(0,
                                                                   NavHeight,
                                                                   MAXScreenW,
                                                                   MAXScreenH - NavHeight)];
        _tableview.delegate = self;
        _tableview.dataSource = self;
        [self.view addSubview:_tableview];
    }
    return _tableview;
}



@end
