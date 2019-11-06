//
//  UIControl+Category.m
//  MaxIM
//
//  Created by 韩雨桐 on 2019/10/15.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "UIControl+Category.h"
#import "objc/runtime.h"

static const void * OrderTagsBy = &OrderTagsBy;


@implementation UIControl (Category)

@dynamic orderTags;


- (void)setOrderTags:(NSString *)orderTags {
    objc_setAssociatedObject(self, OrderTagsBy, orderTags, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)orderTags {
return objc_getAssociatedObject(self, OrderTagsBy);
}

@end
