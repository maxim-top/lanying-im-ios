//
//  GroupDetailListViewController.m
//  MaxIM
//
//  Created by hyt on 2018/11/21.
//  Copyright © 2018年 hyt. All rights reserved.
//

#import "GroupDetailListViewController.h"
#import "UIViewController+CustomNavigationBar.h"
@interface GroupDetailListViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView  *tableView;
@property (nonatomic, strong) NSArray *cellDataArray;
@property (nonatomic, strong) NSArray *sectionArray;

@end

@implementation GroupDetailListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setUpNavItem];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"rosterCell"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"optionCell"];

    self.sectionArray = @[NSLocalizedString(@"Group_owner_Admin", @"群主/管理员"), NSLocalizedString(@"Ordinary_member", @"普通成员"), NSLocalizedString(@"Set", @"设置"), NSLocalizedString(@"Extension_features", @"扩展功能")];
    self.cellDataArray = [self getGroupConfigDataArray];
}

#pragma mark - data
- (NSArray *)getGroupConfigDataArray {
    NSDictionary *configDic = [NSDictionary dictionaryWithDictionary:[self readLocalFileWithName:@""]];
    NSMutableArray *dataArray = [NSMutableArray array];
    for (NSDictionary *dic in configDic[@"cells"]) {
        [dataArray addObject:dic];
    }
    
    return dataArray;
}

// 读取本地JSON文件
- (NSDictionary *)readLocalFileWithName:(NSString *)name {
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"json"];
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    return [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
}

#pragma mark - TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return  1;
    } else if (section == 1) {
        return self.cellDataArray.count;
    } else if (section == 2) {
        return 1;
    }
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *titleStr = self.sectionArray[section];
    return  titleStr;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"rosterCell" forIndexPath:indexPath];
        cell.textLabel.text = NSLocalizedString(@"Pull_members", @"拉取成员");
        return cell;
    } else if  (indexPath.section == 1)  {
        NSDictionary *dic = self.cellDataArray[indexPath.row];
        
        UITableViewCell *cell  = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
        cell.textLabel.text = dic[@"type"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"optionCell" forIndexPath:indexPath];
        cell.textLabel.text = NSLocalizedString(@"Configure_extension_feature_json", @"配置扩展功能json");
        return cell;
    }
//    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //    NSString *key = self.keyArray[indexPath.section];
    //    NSArray *array = [self.groupDict objectForKey:key];
    //    NSDictionary *dict = array[indexPath.row];
    //    [[NSNotificationCenter defaultCenter] postNotificationName:@"ContanctCellClick" object:dict];
}

#pragma mark - Subview
- (void)setUpNavItem{
    [self setNavigationBarTitle:NSLocalizedString(@"Contact", @"联系人") navLeftButtonIcon:@"blackback" navRightButtonTitle:@"personal"];
    [self.navRightButton addTarget:self action:@selector(addFriend:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - lazy load
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self.view addSubview:_tableView];
    }
    return _tableView;
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
