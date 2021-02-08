//
//  CustomShareViewController.m
//  MaxIMShare
//
//  Created by 韩雨桐 on 2019/5/23.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "CustomShareViewController.h"



@interface CustomShareViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation CustomShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.dataArray = [NSArray array];
    [self configSubView];
}

- (void)configSubView {
    [self prepareUI];
}

- (void)prepareUI {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, 64)];
    [self.view addSubview:view];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 64, UIScreen.mainScreen.bounds.size.width, 1)];
    line.backgroundColor = [UIColor grayColor];
    [self.view addSubview:line];
    
    UIButton *leftButton  = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = CGRectMake(0, 30, 50, 30);
    [leftButton setTitle:@"关闭" forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(cancelBtnClickHandler:) forControlEvents:UIControlEventTouchUpInside];
    [leftButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:leftButton];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.view.frame), 30, 80, 30)];
    titleLabel.text = @"MaxIM";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:titleLabel];
    
    
    UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 65, 200, 300)];
    imgV.contentMode = UIViewContentModeScaleAspectFill;
    imgV.backgroundColor = [UIColor yellowColor];
    imgV.clipsToBounds = YES;
    [self.view addSubview:imgV];
    
    for (NSExtensionItem *items in self.extensionContext.inputItems) {
        for (NSItemProvider *provider in items.attachments ) {
            if ([provider hasItemConformingToTypeIdentifier:@"public.image"]) {
                [provider loadItemForTypeIdentifier:@"public.image" options:nil completionHandler:^(id<NSSecureCoding>  _Nullable item, NSError * _Null_unspecified error) {
                    if ([(NSObject *)item isKindOfClass:[NSURL class]])
                    {
                        //从相册中分享，此时图片已经在相册中，取到的是路径Url
                        NSURL *imageUrl = (NSURL *)item;
                    
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageUrl]];
                                                        imgV.image = image;
                                                        CGRect frame = imgV.frame;
                                                        frame.size = CGSizeMake(image.size.width / image.size.height * 300, 300);
                                                        frame.origin.x = (UIScreen.mainScreen.bounds.size.width  - frame.size.width) /2;
                                                        imgV.frame = frame;
                                                    });
                        
                    }
                    
                }];
            }
        }
    }

    
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(imgV.frame) + 10, UIScreen.mainScreen.bounds.size.width, 100)];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
}

- (void)cancelBtnClickHandler:(UIButton *)sender {
    [self.extensionContext cancelRequestWithError:[NSError errorWithDomain:@"CustomShareError" code:NSUserCancelledError userInfo:nil]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"sendSelectCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"sendSelectCell"];
    }
    
    NSString *title = self.dataArray[indexPath.row];
    cell.textLabel.text = title;
    if (indexPath.row == 0) {
        cell.imageView.image = [UIImage imageNamed:@"personal"];
    } else {
        cell.imageView.image = [UIImage imageNamed:@"group_default"];
    }
    
    CGSize itemSize = CGSizeMake(20, 20);
    UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    [cell.imageView.image drawInRect:imageRect];
    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    __block NSString *openImageUrl = @"";
    
    for (NSExtensionItem *items in self.extensionContext.inputItems) {
        for (NSItemProvider *provider in items.attachments ) {
            if ([provider hasItemConformingToTypeIdentifier:@"public.image"]) {
                [provider loadItemForTypeIdentifier:@"public.image" options:nil completionHandler:^(id<NSSecureCoding>  _Nullable item, NSError * _Null_unspecified error) {
                    if ([(NSObject *)item isKindOfClass:[NSURL class]])
                    {
                        //从相册中分享，此时图片已经在相册中，取到的是路径Url
                        NSURL *imageUrl = (NSURL *)item;
                        openImageUrl = imageUrl.absoluteString;
                        [self saveUrl:imageUrl item:items];
                        
                        //                            dispatch_async(dispatch_get_main_queue(), ^{
                        //                                //imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:urlStr]]];
                        //                            });
                        if (indexPath.row == 0) {
                            
                            UIResponder *responder = self;
                            while ((responder = [responder nextResponder]) != nil) {
                                if ([responder respondsToSelector:@selector(openURL:)] == YES) {
                                    [responder performSelector:@selector(openURL:) withObject:[NSURL URLWithString:[NSString stringWithFormat:@"MaxIMExtension://Roster"]]];
                                }
                            }
                            
                        } else {
                            
                            UIResponder *responder = self;
                            while ((responder = [responder nextResponder]) != nil) {
                                if ([responder respondsToSelector:@selector(openURL:)] == YES) {
                                    [responder performSelector:@selector(openURL:) withObject:[NSURL URLWithString:[NSString stringWithFormat:@"MaxIMExtension://Group"]]];
                                }
                            }
                            
                            
                        }
                    }
                    //                        else{
                    //                            //截屏后点击分享，此时图片还未入库，所以拿到的是Image
                    //                            UIImage *image = (UIImage *)item;
                    //                            dispatch_async(dispatch_get_main_queue(), ^{
                    //                                //imageView.image  = image;
                    //                            });
                    //                        }
                    
                }];
            }
        }
    }
}

- (void)saveUrl:(NSURL *)url item:(NSExtensionItem *)item{

    NSString *suitName = @"group.com.maximtop.MaxIM.ShareExtention";
    NSURL *groupURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:suitName];
    NSURL *fileURL = [groupURL URLByAppendingPathComponent:@"incomingShared"];
    NSData *imageData = [[NSData alloc]initWithContentsOfURL:url];
    NSDictionary *dict = @{@"image":imageData};
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:@[dict] requiringSecureCoding:YES error:nil];
    [data writeToURL:fileURL atomically:YES];
    
    [self.extensionContext completeRequestReturningItems:@[item] completionHandler:^(BOOL expired) {
    }];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (void)postBtnClickHandler:(UIButton *)sender {
//    if (!self.hasExistsUrl) {
//        [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
//        return;
//    }
//    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
//    activityIndicatorView.frame = CGRectMake((self.view.frame.size.width - activityIndicatorView.frame.size.width) / 2,
//                                             (self.view.frame.size.height - activityIndicatorView.frame.size.height) / 2,
//                                             activityIndicatorView.frame.size.width,
//                                             activityIndicatorView.frame.size.height);
//    activityIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
//    [self.view addSubview:activityIndicatorView];
//    //激活加载动画
//    [activityIndicatorView startAnimating];
//    NSString *suitName = @"group.com.xx.oo.Share";
//    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:suitName];
//    [userDefaults setValue:((NSURL *)self.item).absoluteString forKey:@"share-image"];
//    //用于标记是新的分享
//    [userDefaults setBool:YES forKey:@"has-new-share"];
//    NSDictionary *dict = @{@"text":self.contentView.text,@"image":self.imgDt};
//    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:@[dict]];
//    //写入文件
//    [data writeToURL:self.writeURL atomically:YES];
//    [userDefaults synchronize];
//    [self.extensionContext completeRequestReturningItems:@[self.extItem] completionHandler:^(BOOL expired) {
//        [activityIndicatorView stopAnimating];
//    }];
}

- (NSArray *)dataArray {
    return @[@"发送给好友", @"发送给群组"];
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
