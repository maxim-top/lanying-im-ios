//
//  ContactTableView.m
//  MaxIM
//
//  Created by hyt on 2018/11/19.
//  Copyright © 2018年 hyt. All rights reserved.
//

#import "ContactTableView.h"
#import "ContactTableViewCell.h"
#import <floo-ios/floo_proxy.h>

@interface ContactTableView ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation ContactTableView

//给定宽高
+ (instancetype)contactTableView {
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat w = MAXScreenW;
    CGFloat h = MAXScreenH - MaxNavHeight;
    
    ContactTableView *tableView = [[ContactTableView alloc] initWithFrame:CGRectMake(x, y, w, h) style:UITableViewStylePlain];
    return tableView;
}

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    if (self = [super initWithFrame:frame style:style]) {
        self.delegate = self;
        self.dataSource = self;
        
        self.dataArray = [NSMutableArray array];
        
        [self registerClass:[ContactTableViewCell class] forCellReuseIdentifier:@"ContactTableViewCell"];
    }
    return self;
}

- (void)refresh:(NSArray<BMXRosterItem *> *)array {
    self.dataArray = [NSMutableArray arrayWithArray:array];
    [self reloadData];
}

#pragma mark - TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BMXRosterItem *roster = self.dataArray[indexPath.row];
    ContactTableViewCell *cell = [ContactTableViewCell contactTableViewCellWith:tableView];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell refresh:roster];
    return cell;
}


@end
