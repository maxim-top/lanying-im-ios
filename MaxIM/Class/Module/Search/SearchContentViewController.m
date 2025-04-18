//
//  ----------------------------------------------------------------------
//   File    :  SearchContentViewController.m
//   Author  : HYT yutong@bmxlabs.com
//   Purpose :
//   Created : 2019/1/10 by HYT yutong@bmxlabs.com
//
//  ----------------------------------------------------------------------
//
//                    Copyright (C) 2018-2019   MaxIM.Top
//
// You may obtain a copy of the licence at http://www.maxim.top/LICENCE-MAXIM.md
//
//  ----------------------------------------------------------------------
    

#import "SearchContentViewController.h"
#import "BMXSearchView.h"
#import "ContactTableView.h"
#import "RecentConversaionTableViewCell.h"
#import "LHChatVC.h"
#import "IMAcount.h"
#import "IMAcountInfoStorage.h"
#import "UIView+BMXframe.h"
#import "UIViewController+CustomNavigationBar.h"
#import <floo-ios/floo_proxy.h>


@interface SearchContentViewController () <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) BMXSearchView *searchView;
@property (nonatomic, strong) ContactTableView *tableview;
@property (nonatomic, strong) NSMutableArray *resultArray;
@property (nonatomic, strong) NSMutableArray *messageArray;
@property (nonatomic, strong) NSArray *categoryArray;
@property (nonatomic,assign) BMXMessage_ContentType searchContentType;
@property (nonatomic,assign) BOOL showContentTypeView;
@property (nonatomic, strong) BMXConversation *conversation;


@end

@implementation SearchContentViewController

- (instancetype)initWithSearchContentType:(BMXMessage_ContentType)contentType conversation:(BMXConversation *)conversation {
    if (self = [super init]) {
        self.searchContentType = contentType;
        if (contentType == BMXMessage_ContentType_Text) {
            self.showContentTypeView = YES;
        } else {
            self.showContentTypeView = NO;
        }
        self.conversation = conversation;
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setUpNavItem];
    [self setupSearchView];
    if (self.showContentTypeView == YES) {
        [self setupCategoryView];
    }
    [self.searchView.searchTF becomeFirstResponder];
}

- (void)setupSearchView {
    self.searchView = [BMXSearchView searchView];
    self.searchView.searchTF.placeholder = NSLocalizedString(@"enter_the_chat_log_content_to_search", @" 请输入要搜索的聊天记录内容");
    self.searchView.searchTF.delegate = self;
    self.searchView.searchTF.returnKeyType = UIReturnKeySearch;
    
    [self.view addSubview:self.searchView];
}

- (void)setUpNavItem {
    [self setNavigationBarTitle:NSLocalizedString(@"Search", @"搜索") navLeftButtonIcon:@"blackback"];
}

- (void)setupCategoryView {
    UIView *categoryView = [[UIView alloc] initWithFrame:CGRectMake(0, self.searchView.bmx_bottom + 5, MAXScreenW, 200)];
    [self.view addSubview:categoryView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 100, 30)];
    label.text = NSLocalizedString(@"Search_by_type", @"根据类型搜索：");
    label.font = [UIFont systemFontOfSize:13];
    [categoryView addSubview:label];
    
    for (int i = 0; i < self.categoryArray.count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(20 + 100 + 5 + 62 * i, 0, 60, 30);
        [button setTitle:self.categoryArray[i] forState:UIControlStateNormal];
        button.tag = 20001 + i;
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        button.backgroundColor = BMXColorNavBar;
        [button addTarget:self action:@selector(searchTypeClick:) forControlEvents:UIControlEventTouchUpInside];
        button.layer.cornerRadius = 6;
        button.layer.masksToBounds = YES;
        [categoryView addSubview:button];
    }
}

- (void)searchTypeClick:(UIButton *)button {
    BMXMessage_ContentType type = (int)button.tag - 20000;
    [self.conversation searchMessagesByTypeWithType:type refTime:0 size:100 completion:^(BMXMessageList *result, BMXError *aError) {
        if (result.size > 0) {
            [self dataHandleMessages:result];
        } else {
            [HQCustomToast showDialog:NSLocalizedString(@"No_result_found_for_now", @"暂无查询结果")];
        }
    }];
}

- (NSArray *)categoryArray {
    return @[NSLocalizedString(@"Image", @"图片"), NSLocalizedString(@"Voice", @"语音"), NSLocalizedString(@"File", @"文件"), NSLocalizedString(@"Location", @"位置")];
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField {

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    MAXLog(@"%@", textField.text);
    [self.searchView.searchTF endEditing:YES];
    if ([textField.text length]) {
        [self searchContentWith:textField.text];
    }
    return YES;
}


- (void)searchContentWith:(NSString *)keywords {
    if (self.isConversation == YES) {
        if (self.searchContentType == BMXMessage_ContentType_Text) {
            [self.conversation searchMessagesByKeyWordsWithKeywords :keywords refTime:0 size:100 arg5:BMXConversation_Direction_Up completion:^(BMXMessageList *result, BMXError *aError) {
                [self dataHandleMessages:result];
            }];
        }
    } else {
        [[[BMXClient sharedClient] chatService] searchMessagesByKeyWordsWithKeywords:keywords refTime:0 size:100 arg5:BMXConversation_Direction_Up completion:^(BMXMessageListList *result, BMXError *aError) {
            [self dataHandleConversation:result];
        }];
   
    }
}

- (void)dataHandleConversation:(BMXMessageListList *)conversations {
    
    NSMutableArray *tempProfileArray = [NSMutableArray array];
    self.messageArray = [NSMutableArray array];
    
    dispatch_queue_t queue = dispatch_queue_create("getSearchResult",DISPATCH_QUEUE_SERIAL);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    unsigned long szConv = conversations.size;
    for (int i=0; i<szConv; i++) {
        BMXMessageList *messageList = [conversations get:i];
        unsigned long sz = messageList.size;
        for (int j=0; j<sz; j++) {
            BMXMessage *messageObjc = [messageList get:j];
            [self.messageArray addObject:messageObjc];
            dispatch_async(queue, ^{
                if (messageObjc.type == BMXMessage_MessageType_Single) {
                    IMAcount *im =  [IMAcountInfoStorage loadObject];
                    
                    NSString *fromIdstr = [NSString stringWithFormat:@"%lld", messageObjc.fromId];
                    long long rosterId = [fromIdstr isEqualToString:im.usedId] ? messageObjc.toId : messageObjc.fromId;
                    
                    [[[BMXClient sharedClient] rosterService] searchWithRosterId:rosterId forceRefresh:NO completion:^(BMXRosterItem *roster, BMXError *error) {
                        dispatch_semaphore_signal(semaphore);
                        if (roster) {
                            
                            [tempProfileArray addObject:roster];
                        }
                    }];
                     dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                }else {
                    [[[BMXClient sharedClient] groupService] fetchGroupByIdWithGroupId:messageObjc.conversationId forceRefresh:NO completion:^(BMXGroup *group, BMXError *error) {
                        dispatch_semaphore_signal(semaphore);
                        [tempProfileArray addObject:group];
                    }];
                     dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                }
            });
        }
    }
    
    dispatch_async(queue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            self.resultArray = [NSMutableArray arrayWithArray:[tempProfileArray copy]];
            [self.tableview reloadData];
        });
    });
    
    
}

- (void)dataHandleMessages:(BMXMessageList *)messages {
    NSMutableArray *tempProfileArray = [NSMutableArray array];
    self.messageArray = [NSMutableArray array];
    
    dispatch_queue_t queue = dispatch_queue_create("getSearchResult",DISPATCH_QUEUE_SERIAL);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    unsigned long sz = messages.size;
    for (int i=0; i<sz; i++) {
        BMXMessage *messageObjc = [messages get:i];
        [self.messageArray addObject:messageObjc];
        dispatch_async(queue, ^{
            if (messageObjc.type == BMXMessage_MessageType_Single) {
                IMAcount *im =  [IMAcountInfoStorage loadObject];
                NSString *fromIdStr = [NSString stringWithFormat:@"%lld", messageObjc.fromId];
                long long rosterId = [fromIdStr isEqualToString:im.usedId] ? messageObjc.toId : messageObjc.fromId;
                
                [[[BMXClient sharedClient] rosterService] searchWithRosterId:rosterId forceRefresh:NO completion:^(BMXRosterItem *roster, BMXError *error) {
                    dispatch_semaphore_signal(semaphore);
                    if (roster) {
                        
                        [tempProfileArray addObject:roster];
                    }
                }];
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            }else {
                
                [[[BMXClient sharedClient] groupService] fetchGroupByIdWithGroupId:messageObjc.conversationId forceRefresh:NO completion:^(BMXGroup *group, BMXError *error) {
                    dispatch_semaphore_signal(semaphore);
                    [tempProfileArray addObject:group];
                }];
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            }
        });
    }
    dispatch_async(queue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            self.resultArray = [NSMutableArray arrayWithArray:[tempProfileArray copy]];
            [self.tableview reloadData];
        });
    });
    
}

- (ContactTableView *)tableview {
    if (!_tableview) {
        CGFloat x = 0;
        CGFloat y = CGRectGetMaxY(self.searchView.frame);
        CGFloat w = MAXScreenW;
        CGFloat h = MAXScreenH - y - (isIphoneX_XS ? 22 : 0);
        
        _tableview = [[ContactTableView alloc] initWithFrame:CGRectMake(x, y, w, h) style:UITableViewStylePlain];
        _tableview.delegate = self;
        _tableview.dataSource = self;
        [self.view addSubview:_tableview];
    }
    return _tableview;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 68.f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.resultArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    RecentConversaionTableViewCell *cell = [RecentConversaionTableViewCell cellWithTableview:tableView];
    
    if ([NSStringFromClass([self.resultArray[indexPath.row] class]) isEqualToString:@"BMXRosterItem"]) {
        
        BMXRosterItem *roster = self.resultArray[indexPath.row];
        cell.titleLabel.text = [roster.nickname length] ? roster.nickname : roster.username;
        cell.avatarImageView.image = [UIImage imageNamed:@"contact_placeholder"];
        
        UIImage *image = [UIImage imageWithContentsOfFile:roster.avatarThumbnailPath];
        if (!image) {
            
            [[[BMXClient sharedClient] rosterService] downloadAvatarWithItem:roster thumbnail:YES callback:^(int progress) {
                
            }  completion:^(BMXError *error) {
                if (!error) {
                    UIImage *image = [UIImage imageWithContentsOfFile:roster.avatarThumbnailPath];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        cell.avatarImageView.image = image;
                    });
                }
            }];
        }else {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.avatarImageView.image = image;
            });
        }
        
    } else {
        
        BMXGroup *group = self.resultArray[indexPath.row];
        cell.titleLabel.text = group.name != nil ? group.name : NSLocalizedString(@"No_name_for_now", @"暂无名字");
        cell.avatarImageView.image = [UIImage imageNamed:@"group_placeHo"];
    }
    
    BMXMessage *message = self.messageArray[indexPath.row];
    cell.subtitleLabel.text = message.content;
    cell.dotLabel.hidden = YES;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    LHChatVC *chatVC;
    if ([NSStringFromClass([self.resultArray[indexPath.row] class]) isEqualToString:@"BMXRosterItem"]) {
        BMXRosterItem *roster = self.resultArray[indexPath.row];
        chatVC = [[LHChatVC alloc] initWithRoster:roster messageType:BMXMessage_MessageType_Single];
    } else {
        BMXGroup *group = self.resultArray[indexPath.row];
        chatVC = [[LHChatVC alloc] initWithGroupChat:(BMXGroup *)group messageType:BMXMessage_MessageType_Group];
    }
    [chatVC setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:chatVC animated:YES];
}

@end
