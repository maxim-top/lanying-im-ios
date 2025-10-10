//
//  SearchRosterProfileViewController.m
//  MaxIM
//
//  Created by 韩雨桐 on 2019/3/22.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "SearchRosterProfileViewController.h"
#import <floo-ios/floo_proxy.h>
#import "LHChatVC.h"
#import "UIViewController+CustomNavigationBar.h"
#import "MAXUtils.h"

@interface SearchRosterProfileViewController ()
@property (nonatomic, strong) BMXRosterItem *roster;


@end

@implementation SearchRosterProfileViewController


- (instancetype)initWithRoster:(BMXRosterItem *)roster {
    if (self = [super initWithRoster:roster]) {
        self.roster = roster;
    }
    return self;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavigationBarTitle:[MAXUtils getRosterDisplayName:self.roster] navLeftButtonIcon:@"blackback" navRightButtonTitle:nil];
    [[[BMXClient sharedClient] userService] getProfile:NO completion:^(BMXUserProfile *profile, BMXError *aError) {
        if (self.roster.rosterId == profile.userId) {
            
        } else {
            UIButton *joinBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            joinBtn.frame = CGRectMake(MAXScreenW - 30 - 30, NavHeight - 5 -30, 30, 30);
            [joinBtn addTarget:self action:@selector(joinBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            [joinBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [joinBtn setTitle:NSLocalizedString(@"Add", @"添加") forState:UIControlStateNormal];
            [joinBtn sizeToFit];
            [self.navigationBar addSubview:joinBtn];
        }
    }];
}

- (void)addRoster {
    BMXRosterItem *roster = self.roster;
    [MAXUtils addContact:self andRosterItem:roster];
}

- (void)joinBtnClick:(UIButton *)button {
    [self addRoster];
}

- (void)returnButtonClick {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (NSArray *)getSettingConfigDataArray {
    NSDictionary *configDic = [NSDictionary dictionaryWithDictionary:[self readLocalFileWithName:@"searchDetailProfiledetail"]];
    NSMutableArray *dataArray = [NSMutableArray array];
    for (NSDictionary *dic in configDic[@"cells"]) {
        [dataArray addObject:dic];
    }
    return dataArray;
}

- (NSDictionary *)readLocalFileWithName:(NSString *)name {
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"json"];
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    return [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
}


@end
