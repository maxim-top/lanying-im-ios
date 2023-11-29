//
//  AppIDViewController.m
//  MaxIM
//
//  Created by lhr on 2023/9/5.
//  Copyright © 2023 hyt. All rights reserved.
//

#import "AppIDViewController.h"
#import "LoginViewController.h"
#import "ScanViewController.h"
#import <SafariServices/SFSafariViewController.h>
#import "AppIDListStorage.h"
#import "ActionSheetPicker.h"
#import "AppIDManager.h"
#import <floo-ios/floo_proxy.h>

#define ALPHANUM @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"

@interface AppIDViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *tfAppID;
@property (weak, nonatomic) IBOutlet UIButton *btGo;
@property (weak, nonatomic) IBOutlet UIImageView *btClear;
@property(nonatomic, strong) NSString *mAppID;
- (IBAction)onClear:(id)sender;
- (IBAction)onHelp:(id)sender;
- (IBAction)onGo:(id)sender;
- (IBAction)onAppIDList:(id)sender;
- (IBAction)onScan:(id)sender;
@end

@implementation AppIDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tfAppID.delegate = self;
    [_tfAppID addTarget:self action:@selector(appIdDidChange:) forControlEvents:UIControlEventEditingChanged];
    [_btGo setEnabled:NO];
    [_btClear setHidden:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appIdByScan:) name:@"ScanConsule" object:nil];
    _btGo.backgroundColor = [BMXCOLOR_HEX(0x1badef) colorWithAlphaComponent:1];
    [_btGo setTitleColor:[BMXCOLOR_HEX(0xffffff) colorWithAlphaComponent:1] forState:UIControlStateDisabled];
    [_btGo setTitleColor:BMXCOLOR_HEX(0xffffff) forState:UIControlStateNormal];
    _btGo.layer.masksToBounds = YES;
    _btGo.layer.cornerRadius = 12;


}

-(void)updateBtGo{
    [_btGo setEnabled:_mAppID.length > 0];
    _btGo.backgroundColor = _mAppID.length > 0 ?
        [BMXCOLOR_HEX(0x35dde8) colorWithAlphaComponent:1]:
        [BMXCOLOR_HEX(0x1badef) colorWithAlphaComponent:1];
}

- (void)appIdByScan:(NSNotification *)noti {
    NSDictionary *dic = noti.object;
    _mAppID = dic[@"appId"];
    dispatch_async(dispatch_get_main_queue(), ^{
        self->_tfAppID.text = self->_mAppID;
        [self updateBtGo];
        [self->_btClear setHidden:self->_mAppID.length == 0];
    });
}


- (void)appIdDidChange:(UITextField *)textField {
    _mAppID = textField.text;
    [self updateBtGo];
    [_btClear setHidden:_mAppID.length == 0];
}

- (IBAction)onScan:(id)sender {
    ScanViewController *vc = [[ScanViewController alloc] init];
    vc.modalPresentationStyle =  UIModalPresentationFullScreen;
    [self.navigationController pushViewController:vc animated: YES];
}

- (IBAction)onAppIDList:(id)sender {
    NSArray *appIDlist  = [NSArray arrayWithArray:[AppIDListStorage loadObject]];
    NSMutableArray *list = [appIDlist mutableCopy];
    if(![appIDlist containsObject:BMXAppID]){
        [list addObject:BMXAppID];
    }
    [list addObject:NSLocalizedString(@"clear_app_id_list", @"清空历史记录")];
    
    ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
        if (selectedIndex+1 == list.count){
            [AppIDListStorage clearObject];
        }else{
            self->_mAppID = (NSString *)selectedValue;
            self->_tfAppID.text = self->_mAppID;
            [self updateBtGo];
            [self->_btClear setHidden:false];
        }
    };

    ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker) {
    };

    [ActionSheetStringPicker showPickerWithTitle:NSLocalizedString(@"app_id_list", @"最近使用") rows:list initialSelection:0 doneBlock:done cancelBlock:cancel origin:self.view];
}

- (IBAction)onGo:(id)sender {
    _mAppID = _tfAppID.text;
    [AppIDManager changeAppid:_mAppID isSave:YES];
    [[BMXClient sharedClient] changeAppIdWithAppId:_mAppID completion:^(BMXError * _Nonnull error) {
        
    }];
    [[NetWorkingManager netWorkingManager] resetHeaderWithAppID:_mAppID];
    [self pushToSmsLogin];
}

- (IBAction)onHelp:(id)sender {
    [self showHelp];
}

- (IBAction)onClear:(id)sender {
    [_tfAppID setText:@""];
    _mAppID = @"";
    [self updateBtGo];
    [_btClear setHidden:true];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:ALPHANUM] invertedSet];
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    return [string isEqualToString:filtered];
}

- (void)pushToSmsLogin {
    UIViewController *vc = [[LoginViewController alloc] initWithViewType:LoginVCTypePasswordLogin];
    [self.navigationController pushViewController:vc animated: YES];
}

- (void)showWebViewWithUrl: (NSString*)target {
    @try{
        NSURL *url = [NSURL URLWithString:target];
        SFSafariViewController *safariViewController = [[SFSafariViewController alloc] initWithURL:url];
        safariViewController.delegate = self;
        [self presentViewController:safariViewController animated:YES completion:nil];
    }@catch (NSException *exception) {
        MAXLog(@"%@",exception.description);
    }
}

- (void)showHelp {
    [self showWebViewWithUrl:NSLocalizedString(@"what_is_app_id", @"https://docs.lanyingim.com/faq/what-is-app-id.html")];
}

@end
