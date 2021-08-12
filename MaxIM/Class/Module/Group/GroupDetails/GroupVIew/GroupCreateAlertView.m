//
//  ----------------------------------------------------------------------
//   File    :  GroupCreateAlertView.m
//   Author  : shaohui.yang shaohui@bmxlabs.com
//   Purpose :
//   Created : 2018/12/27 by shaohui.yang shaohui@bmxlabs.com
//
//  ----------------------------------------------------------------------
//
//                    Copyright (C) 2018-2019   MaxIM.Top
//
// You may obtain a copy of the licence at http://www.maxim.top/LICENCE-MAXIM.md
//
//  ----------------------------------------------------------------------
    

#import "GroupCreateAlertView.h"
#import "UIView+BMXframe.h"

@interface GroupCreateAlertView()<UITextFieldDelegate>

@property (nonatomic, copy) void (^okHandler)(NSString* title, NSString* description, NSString* message, BOOL isChatroom);
@property (nonatomic, copy) void (^cancelHandler)();

@property (nonatomic, strong) UITextField* titleField;
@property (nonatomic, strong) UITextView* descriptionField;
@property (nonatomic, strong) UISwitch* isChatroomField;
@property (nonatomic, strong) UITextField* messageField;
@property (nonatomic, strong) UIView *warnLine;


@end

@implementation GroupCreateAlertView

-(instancetype) initWithFrame:(CGRect)frame Text:(NSString *)text OK:(void (^)(NSString *, NSString *, NSString *, BOOL))ok Cancel:(void (^)())cancel
{
    self = [super initWithFrame:frame];
    self.okHandler = ok;
    self.cancelHandler = cancel;
    [self initView];
    return self;
}

-(void) initView
{
    self.sframe.frame = CGRectMake(25, 0, MAXScreenW-50, 400);
    self.sframe.layer.masksToBounds = YES;
    self.sframe.layer.cornerRadius = 5.0f;
    
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, MAXScreenW-80, 30)];
    titleLabel.text = @"请填写群信息";
    titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:17];
    titleLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1/1.0];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.sframe addSubview:titleLabel];
    
    UILabel* titleLeft = [[UILabel alloc] initWithFrame:CGRectMake(15, 65, 55, 40)];
    titleLeft.text = @"群名称*";
    titleLeft.font = [UIFont fontWithName:@".AppleSystemUIFont" size:14];
    titleLeft.textColor = [UIColor colorWithRed:82/255.0 green:82/255.0 blue:82/255.0 alpha:1/1.0];
    [self.sframe addSubview: titleLeft];
    [self.sframe addSubview:self.titleField];
    
    self.warnLine = [[UIView alloc] initWithFrame:CGRectMake(15, 105, MAXScreenW-80, 0.5)];
    self.warnLine.backgroundColor = [UIColor colorWithRed:223/255.0 green:223/255.0 blue:223/255.0 alpha:1/1.0];
    [self.sframe addSubview:self.warnLine];
    
    UILabel* messageLeft = [[UILabel alloc] initWithFrame:CGRectMake(15, 115, 55, 40)];
    messageLeft.text = @"消息";
    messageLeft.font = [UIFont fontWithName:@".AppleSystemUIFont" size:14];
    messageLeft.textColor = [UIColor colorWithRed:82/255.0 green:82/255.0 blue:82/255.0 alpha:1/1.0];
    [self.sframe addSubview: messageLeft];
    [self.sframe addSubview:self.messageField];
    
    UIView* line2 = [[UIView alloc] initWithFrame:CGRectMake(15, 155, MAXScreenW-80, 0.5)];
    line2.backgroundColor = [UIColor colorWithRed:223/255.0 green:223/255.0 blue:223/255.0 alpha:1/1.0];
    [self.sframe addSubview:line2];
    
    UILabel* textTitle = [[UILabel alloc] initWithFrame:CGRectMake(15, 155, MAXScreenW-80, 25)];
    textTitle.text = @"群描述";
    textTitle.font = [UIFont fontWithName:@".AppleSystemUIFont" size:12];
    textTitle.textColor = [UIColor colorWithRed:82/255.0 green:82/255.0 blue:82/255.0 alpha:1/1.0];
    [self.sframe addSubview:textTitle];
    [self.sframe addSubview:self.descriptionField];
    
    UILabel* textIsChatroom = [[UILabel alloc] initWithFrame:CGRectMake(15, 225, MAXScreenW-80, 25)];
    textIsChatroom.text = @"是否创建聊天室";
    textIsChatroom.font = [UIFont fontWithName:@".AppleSystemUIFont" size:12];
    textIsChatroom.textColor = [UIColor colorWithRed:82/255.0 green:82/255.0 blue:82/255.0 alpha:1/1.0];
    [self.sframe addSubview:textIsChatroom];

    [self.sframe addSubview:self.isChatroomField];
    

    UIView* line3 = [[UIView alloc] initWithFrame:CGRectMake(0, 265, MAXScreenW-50, 0.5)];
    line3.backgroundColor = [UIColor colorWithRed:223/255.0 green:223/255.0 blue:223/255.0 alpha:1/1.0];
    [self.sframe addSubview:line3];

    
    UIButton* okBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    //        [_leaveBtn setTitle:@"删除并退出" forState:UIControlStateNormal];
    
    [okBtn setFrame:CGRectMake(MAXScreenW/2 - 29, 265, MAXScreenW/2-29, 40)];
    [okBtn setTintColor:[UIColor whiteColor]];
    [okBtn setTitle:@"确定" forState:UIControlStateNormal];
//    [okBtn setBackgroundColor:[UIColor lh_colorWithHexString:@"#EA6A57"]];
    [okBtn setTintColor: [UIColor colorWithRed:235/255.0 green:145/255.0 blue:25/255.0 alpha:1/1.0]];
    [okBtn addTarget:self action:@selector(touchedOk) forControlEvents:UIControlEventTouchUpInside];
    [self.sframe addSubview:okBtn];
    
    UIView* line4 = [[UIView alloc] initWithFrame:CGRectMake(MAXScreenW/2 - 30, 265, 0.5, 40)];
    line4.backgroundColor = [UIColor colorWithRed:223/255.0 green:223/255.0 blue:223/255.0 alpha:1/1.0];
    [self.sframe addSubview:line4];
    
    UIButton* cancelBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    //        [_leaveBtn setTitle:@"删除并退出" forState:UIControlStateNormal];
    [cancelBtn setFrame:CGRectMake(0, 265, MAXScreenW/2-30, 40)];
    [cancelBtn setTintColor:[UIColor whiteColor]];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTintColor: [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1/1.0]];
//    [cancelBtn setBackgroundColor:[UIColor lh_colorWithHexString:@"#EA6A57"]];
    [cancelBtn addTarget:self action:@selector(touchedCancel) forControlEvents:UIControlEventTouchUpInside];
    [self.sframe addSubview:cancelBtn];
    [self setSframeHeight:305];
}

-(void) touchedOk
{
    if (self.okHandler != nil) {
        NSString* title = self.titleField.text;
        if(title == nil || [title isEqualToString:@""]) {
            self.warnLine.backgroundColor = [UIColor redColor];
            return;
        }
        NSString* description = self.descriptionField.text;
        NSString* message = self.messageField.text;
        BOOL isChatroom = self.isChatroomField.on;
        if(self.okHandler) {
            self.okHandler(title, description, message, isChatroom);
        }
    }
    [self hide];
}

-(void) touchedCancel
{
    if(self.cancelHandler != nil) {
        self.cancelHandler();
    }
    [self hide];
}



-(UITextField*) titleField
{
    if(!_titleField) {
        _titleField = [[UITextField alloc] initWithFrame:CGRectMake(70, 65, MAXScreenW-120 - 55, 40)];
        _titleField.font =  [UIFont fontWithName:@".AppleSystemUIFont" size:12];
        _titleField.placeholder = @"请输入群名称";
    }
    return _titleField;
}

-(UITextField*) messageField
{
    if(!_messageField) {
        _messageField = [[UITextField alloc] initWithFrame:CGRectMake(70, 115, MAXScreenW-120 - 55, 40)];
        _messageField.font =  [UIFont fontWithName:@".AppleSystemUIFont" size:12];
        _messageField.placeholder = @"请输入群邀请信息";
    }
    return _messageField;
}

-(UITextView*) descriptionField
{
    if(!_descriptionField) {
        _descriptionField = [[UITextView alloc] initWithFrame:CGRectMake(10, 180, MAXScreenW-70, 40)];
        _descriptionField.layer.masksToBounds = YES;
        _descriptionField.layer.cornerRadius = 3.0f;
        _descriptionField.layer.borderWidth = 0.5;
        _descriptionField.font =  [UIFont fontWithName:@".AppleSystemUIFont" size:12];
        _descriptionField.layer.borderColor = [UIColor lh_colorWithHex:0xdfdfdf].CGColor;
    }
    return _descriptionField;
}

-(UISwitch*) isChatroomField
{
    if(!_isChatroomField) {
        _isChatroomField = [[UISwitch alloc] initWithFrame:CGRectMake(185, 225, MAXScreenW-80, 25)];
    }
    return _isChatroomField;
}


#pragma mark == override
-(void) show
{
    self.mask.alpha = 0.0;
    self.sframe.bmx_bottom = 0;
    self.sframe.hidden = YES;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(aniShowFrame)];
    self.mask.alpha = 0.3;
    [UIView commitAnimations];
}

-(void) aniShowFrame
{
    self.sframe.hidden = NO;
    CGFloat h = MAXScreenH/2 - self.sframe.bmx_height/2;
    self.sframe.bmx_bottom = 0;
    [UIView animateWithDuration:0.6 delay:0 usingSpringWithDamping:0.4 initialSpringVelocity:10 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        self.sframe.bmx_top = h;
    } completion:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self endEditing:YES];
}

@end
