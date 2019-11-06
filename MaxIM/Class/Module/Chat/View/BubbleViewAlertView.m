//
//  BubbleViewAlertView.m
//  MaxIM
//
//  Created by 韩雨桐 on 2019/3/28.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "BubbleViewAlertView.h"


CGFloat const kOperationButtonWidth = 50.0f;
CGFloat const kOperationButtonHeight = 30.0f;
CGFloat const kAlertRight = 5.0f;



@interface BubbleViewAlertView ()


@property (nonatomic, strong) NSArray *buttonArray;
@property (nonatomic, strong) UIButton *button;


@end

@implementation BubbleViewAlertView


+ (instancetype)bubbleViewAlertViewWithButtonArray:(NSArray *)array isSender:(BOOL)isSender{
    
    CGFloat width = array.count * 30 + (array.count - 1) * 1;
    CGFloat height = 50.f;

    CGFloat x;
    CGFloat y;
    
    if (isSender) {
        x = MAXScreenW - width - kAlertRight;
    } else {
        x = kAlertRight;
    }
    
    y = 0;
    
    BubbleViewAlertView *view = [[BubbleViewAlertView alloc] initWithFrame:CGRectMake(x, y, width, height)];
    view.backgroundColor = [UIColor blackColor];
    view.buttonArray = array;
    return view;
}

- (void)setupSubview {
    for (int i = 0; i < self.buttonArray.count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.titleLabel.text = [NSString stringWithFormat:@"%@",  self.buttonArray[i]];
        button.frame = CGRectMake(self.buttonArray.count * kOperationButtonWidth + self.buttonArray.count * 1, 0, kOperationButtonWidth, kOperationButtonHeight);
        button.tag = 1000 + self.buttonArray.count;
        [self addSubview:button];
    }
}
    
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupSubview];
        
    }
    return self;

}

- (NSArray *)buttonArray {
    if (_buttonArray == nil) {
        _buttonArray = [NSArray array];
    }
    return _buttonArray;
}

- (void)showAlertViewWithView:(UIView *)view {

    [view addSubview:self];
}
    

- (void)hiddenAlertView {
    
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
