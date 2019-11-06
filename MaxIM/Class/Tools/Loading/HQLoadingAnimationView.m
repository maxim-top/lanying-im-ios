//  ************************************************************************
//
//  HQLoadingAnimationView.m
//  MaxIMDemo
//
//  Created by hyt on 2017/7/29.
//  ----------------------------------------------------------------------
//
//                    Copyright (C) 2018-2019   MaxIM.Top
//
// You may obtain a copy of the licence at http://www.maxim.top/LICENCE-MAXIM.md
//
//  ----------------------------------------------------------------------

#import "HQLoadingAnimationView.h"
#import "HQLoadingAnimation.h"

static const CGFloat kLoadingDefaultSize = 30.0f;

@interface HQLoadingAnimationView()

@property (nonatomic, strong) UIColor *tintColor;
@property (nonatomic) CGFloat size;

@property (nonatomic, readonly) BOOL animating;

@end

@implementation HQLoadingAnimationView

#pragma mark -  Constructors
- (id)initWithTintColor:(UIColor *)tintColor {
    return [self initWithTintColor:tintColor size:kLoadingDefaultSize];
}

- (id)initWithTintColor:(UIColor *)tintColor size:(CGFloat)size {
    self = [super init];
    if (self) {
        _size = size;
        _tintColor = tintColor;
    }
    return self;
}

#pragma mark - Methods
- (void)setupAnimation {
    self.layer.sublayers = nil;
    HQLoadingAnimation *animation = [[HQLoadingAnimation alloc] init];
    [animation setupAnimationInLayer:self.layer
                            withSize:CGSizeMake(_size, _size)
                           tintColor:_tintColor];
    self.layer.speed = 0.0f;
}

- (void)startAnimating {
    if (!self.layer.sublayers) {
        [self setupAnimation];
    }
    self.layer.speed = 1.0f;
    _animating = YES;
}

- (void)stopAnimating {
    self.layer.speed = 0.0f;
    _animating = NO;
}

#pragma mark - Setters
- (void)setSize:(CGFloat)size {
    if (_size != size) {
        _size = size;
        [self setupAnimation];
    }
}

- (void)setTintColor:(UIColor *)tintColor {
    if (![_tintColor isEqual:tintColor]) {
        _tintColor = tintColor;
        for (CALayer *sublayer in self.layer.sublayers) {
            sublayer.backgroundColor = tintColor.CGColor;
        }
    }
}

@end
