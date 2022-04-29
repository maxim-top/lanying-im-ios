//
//  ImageAlertView.m
//  MaxIM
//
//  Created by 韩雨桐 on 2019/5/25.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "ImageAlertView.h"

@interface ImageAlertView ()

@property (nonatomic, strong) UIImageView *avatarImg;
@property (nonatomic, strong) UILabel *nicknameLabel;
@property (nonatomic, strong) UIImageView *contentImg;

@end

@implementation ImageAlertView


- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setAvarat:(UIImage *)avarat
         nickName:(NSString *)nickName
       contentImg:(UIImage *)contentImg {
    
    self.avatarImg.image = avarat;
    self.nicknameLabel.text = nickName;
    self.contentImg.image = contentImg;
    
    CGFloat maxWidth = MAXScreenW - 120;
    CGFloat maxHeight = MAXScreenH / 2 - CGRectGetMinY(self.contentImg.frame) - 60;
    CGRect frame = self.contentImg.frame;
    CGSize size = contentImg.size;
    if (size.width >= size.height) {
        CGFloat height = contentImg.size.height / contentImg.size.width * maxWidth;
        if (height > maxHeight) {
            CGFloat rate =  maxHeight / height;
            height = maxHeight;
            frame.size.width = maxWidth * rate;
        }else {
            
            frame.size.width = maxWidth;
        }
        frame.size.height = height;
    }else {
        CGFloat width = size.width / size.height * maxHeight;
        if (width > maxWidth) {
            CGFloat rate = maxWidth / width;
            frame.size.height = maxHeight * rate;
        }else {
            frame.size.height = maxHeight;
        }
        frame.size.width = width;
    }
    frame.origin.x = ((MAXScreenW - 80) - frame.size.width ) / 2;
    self.contentImg.frame = frame;
    
}

- (void)setupUI {
    
    UIView *backView = [[UIView alloc] initWithFrame:self.bounds];
    backView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    [self addSubview:backView];
    
    CGFloat width = MAXScreenW - 80;
    
    UIView *whiteView = [[UIView alloc] initWithFrame:CGRectMake(40, MAXScreenH / 4, width, MAXScreenH / 2)];
    whiteView.backgroundColor = [UIColor whiteColor];
    [self addSubview:whiteView];
    
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, width - 40, 30)];
    titleLabel.text = NSLocalizedString(@"Sendto", @"发送给:");
    [whiteView addSubview:titleLabel];
    
    
    self.avatarImg = [[UIImageView alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(titleLabel.frame), 30, 30)];
    [whiteView addSubview:self.avatarImg];
    
    self.nicknameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.avatarImg.frame) + 10, CGRectGetMaxY(titleLabel.frame),width - 80,30)];
    [whiteView addSubview:self.nicknameLabel];
    
    self.contentImg = [[UIImageView alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(self.avatarImg.frame) + 20,width - 40 , (width -40) / 2)];
    self.contentImg.contentMode = UIViewContentModeScaleToFill;
    [whiteView addSubview:self.contentImg];
    
    UIButton *cancel = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancel addTarget:self action:@selector(removeFromSuperview) forControlEvents:UIControlEventTouchUpInside];
    [cancel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cancel setTitle:NSLocalizedString(@"Cancel", @"取消") forState:UIControlStateNormal];
    cancel.frame = CGRectMake(0, MAXScreenH / 2 - 40, width / 2, 40);
    [whiteView addSubview:cancel];
    
    
    UIButton *send = [UIButton buttonWithType:UIButtonTypeCustom];
    [send addTarget:self action:@selector(sendBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [send setTitle:NSLocalizedString(@"Send", @"发送") forState:UIControlStateNormal];
    [send setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    send.frame = CGRectMake(width / 2, MAXScreenH / 2 - 40, width / 2, 40);
    [whiteView addSubview:send];

}

- (void)sendBtnClick {
    
    if (self.btnClickBlock) {
        self.btnClickBlock();
    }
    [self removeFromSuperview];
    
}


@end
