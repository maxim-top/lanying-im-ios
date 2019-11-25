//
//  LHMessageModel.h
//  LHChatUI
//
//  Created by hyt on 2016/12/26.
//  Copyright © 2016年 hyt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <floo-ios/BMXMessageObject.h>

/*!
 @enum
 @brief 聊天类型
 @constant MessageBodyType_Text 文本类型
 @constant MessageBodyType_Image 图片类型
 @constant MessageBodyType_Video 视频类型
 @constant MessageBodyType_Location 位置类型
 @constant MessageBodyType_Voice 语音类型
 @constant MessageBodyType_File 文件类型
 @constant MessageBodyType_Command 命令类型
 */
typedef enum {
    MessageBodyType_Text = 1,
    MessageBodyType_Image,
    MessageBodyType_Video,
    MessageBodyType_Location,
    MessageBodyType_Voice,
    MessageBodyType_File,
    MessageBodyType_Command
}MessageBodyType;


typedef enum {
    MessageDeliveryState_Pending = 0, //待发送
    MessageDeliveryState_Delivering, //正在发送
    MessageDeliveryState_Delivered, //已发送, 成功
    MessageDeliveryState_Failure //已发送, 失败
}MessageDeliveryState;

@interface LHMessageModel : NSObject

/** 是否是发送者 */
@property (nonatomic, assign) BOOL isSender;
///** 是否已读 */
//@property (nonatomic) BOOL isRead;
/** 是否是群聊 */
@property (nonatomic) BOOL isChatGroup;

@property (nonatomic, assign) MessageBodyType type;
@property (nonatomic, assign) MessageDeliveryState status;
@property (nonatomic, strong) NSString *date;
@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *nickName;

/** text */
@property (nonatomic, strong) NSString *content;

/** image */
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, copy) NSString *imageRemoteURL;

/**
  语音消息路径
 */
@property (nonatomic, copy) NSString *vociePath;
/**
 video消息路径
 */
@property (nonatomic, copy) NSString *videoPath;



// 消息实体
@property (nonatomic, strong) BMXMessageObject *messageObjc;

@property (nonatomic, strong) NSIndexPath *indexPath;

@end
