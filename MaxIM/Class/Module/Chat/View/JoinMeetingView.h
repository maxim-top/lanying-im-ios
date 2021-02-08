//
//  JoinMeetingView.h
//  MaxIM
//
//  Created by 韩雨桐 on 2020/5/25.
//  Copyright © 2020 hyt. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JoinMeetingView : UIView

+ (instancetype)joinMeetingViewWithUserID:(NSString *)userID meetingID:(NSString *)meetingID;

@end

NS_ASSUME_NONNULL_END
