//
//  DropdownListView.m
//  MaxIM
//
//  Created by 韩雨桐 on 2020/1/3.
//  Copyright © 2020 hyt. All rights reserved.
//

#import "DropdownListView.h"

@interface DropdownListView ()<UITableViewDelegate, UITableViewDataSource>

@end

@implementation DropdownListView


+ (instancetype)dropdownListViewWithframe:(CGRect)frame {
//     CGFloat x = 0;
//     CGFloat y = 0;
//     CGFloat w = MAXScreenW;
//     CGFloat h = MAXScreenH - MaxNavHeight;
     
    DropdownListView *tableView = [[DropdownListView alloc] initWithFrame:frame style:UITableViewStylePlain];
     return tableView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 49;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    return cell;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
