//
//  BMXSearchView.m
//  MaxIM
//
//  Created by hyt on 2018/11/18.
//  Copyright © 2018年 hyt. All rights reserved.
//

#import "BMXSearchView.h"
#import "UIView+BMXframe.h"

@interface BMXSearchView ()


@end

@implementation BMXSearchView

+ (instancetype)searchView {
    CGFloat navh = kNavBarHeight;
    if (MAXIsFullScreen) {
        navh  = kNavBarHeight + 24;
    }
    BMXSearchView *view = [[BMXSearchView alloc] initWithFrame:CGRectMake(0, NavHeight , MAXScreenW, 56)];

    return view;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        [self setupSubView];
    }
    return self;
}

- (void)setupSubView {
    [self searchTF];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat searchTFLeft = 15;
    CGFloat searchTTop = 10;
    
    _searchTF.bmx_centerY = self.bmx_centerY;
    _searchTF.bmx_left = searchTFLeft;
    _searchTF.bmx_top = searchTTop;
    _searchTF.bmx_height = self.bmx_height - searchTTop * 2.0;
    _searchTF.bmx_width = self.bmx_width - searchTFLeft * 2.0;
}

- (UITextField *)searchTF {
    if (!_searchTF) {
        _searchTF = [[UITextField alloc] init];
        _searchTF.backgroundColor =  [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:0.1];

        _searchTF.layer.cornerRadius = 4;
        _searchTF.layer.masksToBounds = YES;
        UIImage *image = [UIImage imageNamed:@"search"];
        UIView *view1 = [[UIView alloc]initWithFrame:CGRectMake(-10, 0, 25, image.size.height)];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 0, image.size.width, image.size.height)];
        imageView.image = image;
        [view1 addSubview:imageView];
        _searchTF.leftView = view1;

        
        _searchTF.leftViewMode = UITextFieldViewModeAlways;
        [_searchTF.leftView sizeToFit];
        [_searchTF setValue:[NSNumber numberWithInt:10] forKey:@"paddingLeft"];
        NSString *holderText = @"  输入要查找的好友用户名";
        _searchTF.placeholder = holderText;
        [_searchTF setValue:BMXCOLOR_HEX(0x666666) forKeyPath:@"_placeholderLabel.textColor"];
        [_searchTF setClearButtonMode:UITextFieldViewModeWhileEditing];
        [self addSubview:_searchTF];
    }
    return _searchTF;
}


@end
