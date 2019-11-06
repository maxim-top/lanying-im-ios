//
//  BaseTableViewController.m
//  MaxIM
//
//  Created by hyt on 2018/11/22.
//  Copyright © 2018年 hyt. All rights reserved.
//

#import "BaseTableViewController.h"

@interface BaseTableViewController ()<UITableViewDelegate, UITableViewDataSource>

@end

@implementation BaseTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupTableView];
    // Do any additional setup after loading the view.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = self.celldataArray[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    cell.textLabel.text = dic[@"type"];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.celldataArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionDataArray.count ? self.sectionDataArray.count : 1;
}

- (void)setupTableView {
    self.tablview = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tablview.delegate = self;
    self.tablview.dataSource = self;
    [self.view addSubview:self.tablview];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
