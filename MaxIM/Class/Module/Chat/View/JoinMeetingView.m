//
//  JoinMeetingView.m
//  MaxIM
//
//  Created by 韩雨桐 on 2020/5/25.
//  Copyright © 2020 hyt. All rights reserved.
//

#import "JoinMeetingView.h"

#import <MobileRTC/MobileRTC.h>

#import <floo-ios/BMXClient.h>
#import "IMAcountInfoStorage.h"
#import "IMAcount.h"

@interface JoinMeetingView ()<MobileRTCMeetingServiceDelegate>

@property (nonatomic, strong) UIButton *button;

@property (nonatomic, strong) UILabel *tipLabel;

@property (nonatomic,copy) NSString *userID;

@property (nonatomic,copy) NSString *meetingID;

@end

@implementation JoinMeetingView


+ (instancetype)joinMeetingViewWithUserID:(NSString *)userID meetingID:(NSString *)meetingID {
    JoinMeetingView *view = [[JoinMeetingView alloc] initWithFrame:CGRectMake(0, NavHeight-5, MAXScreenW, 40)];
    view.userID = userID;
    view.meetingID = meetingID;
    view.backgroundColor = [UIColor colorWithRed:79/255.0 green:160/255.0 blue:255/255.0 alpha:0.5];
    return view;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self button];
        [self tipLabel];
        
    }
    return self;
}

- (void)clickButton:(UIButton *)button {
    
   IMAcount *account = [IMAcountInfoStorage loadObject];

                                 
    MobileRTCMeetingService *ms = [[MobileRTC sharedRTC] getMeetingService];
          ms.delegate = self;
          NSDictionary *paramDict = @{
                                      kMeetingParam_Username:account.usedId,
                                      kMeetingParam_MeetingNumber:[NSString stringWithFormat:@"%@", self.meetingID]
                                      };
    
          MobileRTCMeetError ret = [ms joinMeetingWithDictionary:paramDict];
    
    if (ret == MobileRTCMeetError_Success) {
        
        // 给商务发消息
        NSString *messageTest = [NSString stringWithFormat:NSLocalizedString(@"joined_chamber_id", @"%@ 加入会议室（id: %@）"), account.usedId, self.meetingID];
                
        BMXMessageObject *message = [[BMXMessageObject alloc] initWithBMXMessageText:messageTest
                                                                              fromId:[account.usedId integerValue]
                                                                                toId:6597373638528 type:BMXMessageTypeSingle
                                                                      conversationId:6597373638528];
        
        [[[BMXClient sharedClient] chatService] sendMessage:message];
    }
}
 
- (UIButton *)button {
    if (_button == nil) {
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.frame = CGRectMake(MAXScreenW - 80 - 10, 5, 80, 30);
        [_button setTitle:NSLocalizedString(@"Join_now", @"立即加入") forState:UIControlStateNormal];
        _button.backgroundColor = [UIColor colorWithRed:79/255.0 green:160/255.0 blue:255/255.0 alpha:0.75];
        _button.titleLabel.font = [UIFont systemFontOfSize:12];
        [_button addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
        _button.layer.cornerRadius = 3.0;//2.0是圆角的弧度，根据需求自己更改
        _button.layer.borderColor = [UIColor colorWithRed:79/255.0 green:160/255.0 blue:255/255.0 alpha:1].CGColor;//设置边框颜色
        _button.layer.borderWidth = 1.0f;//设置边框颜色
        [self addSubview:_button];
    }
    return _button;
}

- (UILabel *)tipLabel {
    if (_tipLabel == nil) {
        _tipLabel= [[UILabel alloc] initWithFrame:CGRectMake(10, 5, MAXScreenW - 50-20, 30)];
        _tipLabel.text = NSLocalizedString(@"Welcome_to_experience_the_video", @"欢迎体验视频支持服务");
        _tipLabel.font = [UIFont systemFontOfSize:14];

        [self addSubview:_tipLabel];
    }
    return _tipLabel;
}

@end
