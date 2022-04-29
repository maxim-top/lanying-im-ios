//
//  ----------------------------------------------------------------------
//   File    :  GroupPublicViewController.m
//   Author  : shaohui.yang shaohui@bmxlabs.com
//   Purpose :
//   Created : 2018/12/25 by shaohui.yang shaohui@bmxlabs.com
//
//  ----------------------------------------------------------------------
//
//                    Copyright (C) 2018-2019   MaxIM.Top
//
// You may obtain a copy of the licence at http://www.maxim.top/LICENCE-MAXIM.md
//
//  ----------------------------------------------------------------------
    

#import "GroupPublicViewController.h"
#import "AnounceCel.h"
#import "NSString+YYAdd.h"
#import <floo-ios/BMXGroupAnnounment.h>
#import <floo-ios/BMXClient.h>
#import "UIViewController+CustomNavigationBar.h"

@interface GroupPublicViewController ()


@property (nonatomic, strong) NSArray* dataSource;
//@property (nonatomic, strong) UITableView* tableView;

@property (nonatomic, strong) UITextField* titleField;
@property (nonatomic, strong) UITextView * textView;


@end

@implementation GroupPublicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    [self getAnnoument];
    [self setUpNavItem];
    [self initViews];
}

-(void) initViews {
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 15 + NavHeight, MAXScreenW-30, 15)];
    [self.view addSubview:titleLabel];
    titleLabel.text = NSLocalizedString(@"Tittle", @"标题");
    titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:12];
    titleLabel.textColor = [UIColor colorWithRed:155/255.0 green:155/255.0 blue:169/255.0 alpha:1/1.0];
    [self.view addSubview:self.titleField];
    
    
    UILabel* contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 65 + NavHeight, MAXScreenW-30, 15)];
    [self.view addSubview:contentLabel];
    contentLabel.text = NSLocalizedString(@"Content", @"内容");
    contentLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:12];
    contentLabel.textColor = [UIColor colorWithRed:155/255.0 green:155/255.0 blue:169/255.0 alpha:1/1.0];
    
    [self.view addSubview:self.textView];
//    [self.view addSubview:self.tableView];
    
}

-(UITextField*) titleField
{
    if(!_titleField) {
        _titleField = [[UITextField alloc] initWithFrame:CGRectMake(15, 35 + NavHeight, MAXScreenW-30, 25)];
        _titleField.layer.masksToBounds = YES;
        _titleField.layer.cornerRadius = 3.0f;
        _titleField.layer.borderWidth = 0.5;
        _titleField.layer.borderColor = [UIColor lh_colorWithHexString:@"EEEEEE"].CGColor;
    }
    return _titleField;
}

-(UITextView*) textView
{
    if(!_textView) {
        _textView = [[UITextView alloc] initWithFrame:CGRectMake(15, 85 + NavHeight, MAXScreenW-30, 45)];
        _textView.layer.masksToBounds = YES;
        _textView.layer.cornerRadius = 3.0f;
        _textView.layer.borderWidth = 0.5;
        _textView.layer.borderColor = [UIColor lh_colorWithHexString:@"EEEEEE"].CGColor;
    }
    return _textView;
}

- (void)getAnnoument {
    [[[BMXClient sharedClient] groupService] getAnnouncementListWithGroup:self.group forceRefresh:YES completion:^(NSArray *annoucmentArray, BMXError *error) {
        if (!error && annoucmentArray.count > 0) {
            BMXGroupAnnounment *announment = annoucmentArray.lastObject;
            _textView.text = announment.content;
            _titleField.text = announment.tittle;
        }
    }];
}

- (void)touchedRightBar {
    MAXLog(@"发布群公告...");
    [[[BMXClient sharedClient] groupService] editGroupAnnouncement:self.group title:_titleField.text content:_textView.text completion:^(BMXGroup *group, BMXError *error) {
        if (!error) {
            [HQCustomToast showDialog:NSLocalizedString(@"Publish_successfully", @"发布成功")];
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [HQCustomToast showDialog:[NSString stringWithFormat:@"%@", error.errorMessage]];
        }
    }];
}

- (void)setUpNavItem {
    [self setNavigationBarTitle:NSLocalizedString(@"Group_announcement", @"群公告") navLeftButtonIcon:@"blackback" navRightButtonTitle:NSLocalizedString(@"Save", @"保存")];
    [self.navRightButton addTarget:self action:@selector(touchedRightBar) forControlEvents:UIControlEventTouchUpInside];
}


@end
