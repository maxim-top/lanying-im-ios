//
//  MenuView.m
//  MaxIM
//
//  Created by 韩雨桐 on 2019/10/12.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "MenuView.h"
#import "UIControl+Category.h"

NSUInteger kMenuViewTag = 1121;


@interface MenuView ()

@property (nonatomic, strong) UIView *backgroudView;
@property (nonatomic, strong) NSArray *buttonArray;

@end


@implementation MenuView

- (instancetype)initWithFrame:(CGRect)frame buttonArray:(NSArray *)array {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.tag = kMenuViewTag;
        self.buttonArray = array;
        [self addArrowImageView];
        [self addBackGroundView];
        [self addButton];
        [self p_addDismissTapGesture];
    }
    return self;
}

- (void)addArrowImageView {
    UIImage *image = [UIImage imageNamed:@"menuBubble_arrow"];
    
    UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(MAXScreenW - 15 - image.size.width,
                                                                                - 6 ,
                                                                                image.size.width,
                                                                                image.size.height)];
    arrowImageView.image = image;
    [self addSubview:arrowImageView];
}

- (void)addBackGroundView {
    UIImage *image = [UIImage imageNamed:@"menuBubble_arrow"];
    self.backgroudView = [[UIView alloc] initWithFrame:CGRectMake(MAXScreenW - 10 -  130 ,0 , 130, self.buttonArray.count * 44)];
    [self addSubview:self.backgroudView];
    self.backgroudView.backgroundColor = BMXCOLOR_HEX(0x414040);
    self.backgroudView.layer.cornerRadius = 3;
    [self.backgroudView layoutIfNeeded];

}

- (void)addButton {
    MAXLog(@"%lu", (unsigned long)self.buttonArray.count);
    for (int i = 0; i < self.buttonArray.count ; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.backgroudView addSubview:btn];
        [btn setTitle:self.buttonArray[i] forState:UIControlStateNormal];
        UIImage *image = [UIImage imageNamed:@"menuBubble_arrow"];
        btn.frame = CGRectMake(0, 44 * i, self.width, 44);
        btn.tag = 20000 + i;
        btn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        btn.titleEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
        [btn addTarget:self action:@selector(clickMeunButton:) forControlEvents:UIControlEventTouchUpInside];
        btn.orderTags = self.buttonArray[i];
    }
}

- (void)clickMeunButton:(UIButton *)button {
    [self p_remove];

    if (self.delegate && [self.delegate respondsToSelector:@selector(menuViewDidSelectbutton:)]) {
        [self.delegate menuViewDidSelectbutton:button];
    }
    
}

- (void)p_addDismissTapGesture {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(p_remove)];
    [self addGestureRecognizer:tap];
    
}

- (void)p_remove {
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    UIView *shareView = [MaxKeyWindow viewWithTag:kMenuViewTag];
    [shareView removeFromSuperview];
    shareView = nil;
    [self removeFromSuperview];
}


- (void)p_removeSubViews {
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
        for (UIView *subView in view.subviews) {
            [subView removeFromSuperview];
        }
    }
}

- (void)hide {
    [self p_remove];
}

- (NSArray *)buttonArray {
    if (!_buttonArray) {
        _buttonArray = [NSArray array];
    }
    return _buttonArray;
}


@end
