//
//  ICFileScanController.m
//  XZ_WeChat
//
//  Created by hyt on 16/7/21.
//  Copyright © 2016年 gxz All rights reserved.
//

#import "ICFileScanController.h"
#import <QuickLook/QuickLook.h>
#import <WebKit/WebKit.h>

@interface ICFileScanController ()<QLPreviewControllerDataSource,QLPreviewControllerDelegate,WKUIDelegate,UIDocumentInteractionControllerDelegate, WKNavigationDelegate>

@property (nonatomic, weak) WKWebView *webView;
@property (nonatomic, strong) QLPreviewController *previewController;
@property (nonatomic, strong) NSURL *fileURL;
@property (nonatomic, strong) UIDocumentInteractionController *documentInCtr;


@end

@implementation ICFileScanController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupNav];
    
    self.fileURL = [NSURL fileURLWithPath:self.filePath];
    NSString *type = [self.filePath pathExtension];
    [self setupVew:type];
    
}


- (void)setupNav
{
    self.title = _orgName;
}

- (void)setupVew:(NSString *)type
{
    if ([type isEqualToString:@"html"] || [type isEqualToString:@"htm"]) {
        
        
//        WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, NavHeight, self.view.width, self.view.height - kNavBarHeight)];
//        NSURL *url = [NSURL URLWithString:self.url];
//        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
//        [webView loadRequest:request];
//        [self.view addSubview:webView];
//
//
        
        WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.width,MAXScreenH)];
        //        webView.scalesPageToFit = YES;
        [self.view addSubview:webView];
        _webView           = webView;
        webView.navigationDelegate = self;
        webView.scrollView.backgroundColor = [UIColor whiteColor];
        [self webViewLoadData:type];
    }else if ([type isEqualToString:@"pdf"]||[type isEqualToString:@"doc"]||[type isEqualToString:@"docx"]||[type isEqualToString:@"xls"]||[type isEqualToString:@"xlsx"]||[type isEqualToString:@"ppt"]||[type isEqualToString:@"pptx"]||[type isEqualToString:@"txt"]){
        _previewController = [[QLPreviewController alloc] init];
        _previewController.dataSource = self;
        _previewController.delegate   = self;
        _previewController.view.frame = CGRectMake(0,0, self.view.width, MAXScreenH);
        _previewController.currentPreviewItemIndex = 0;
        [self.view addSubview:_previewController.view];
        [_previewController reloadData];
    }  else if ([type isEqualToString:@"png"]||[type isEqualToString:@"jpg"]||[type isEqualToString:@"jpeg"]||[type isEqualToString:@"gif"]||[type isEqualToString:@"bmp"]||[type isEqualToString:@"tiff"]||[type isEqualToString:@"svg"]) {
        UIImageView *imageV = [[UIImageView alloc] init];
        [self.view addSubview:imageV];
        imageV.frame = CGRectMake(100, 100, 300, 300);
        imageV.center = CGPointMake(self.view.width*0.5, self.view.height*0.5);
        UIImage *image = [UIImage imageWithContentsOfFile:self.filePath];
        imageV.image   = image;
    } else {
        [self makeOtherView];
    }
}



- (void)makeOtherView
{
    UIImageView *imageV = [[UIImageView alloc] init];
    imageV.frame        = CGRectMake(MAXScreenW*0.5-40, 45, 80, 80);
    imageV.image        = [UIImage imageNamed:@"iconfont-wenjian"];
    [self.view addSubview:imageV];
    UILabel *nameL      = [[UILabel alloc] initWithFrame:CGRectMake(MAXScreenW*0.5-150, imageV.bottom+32, 300, 40)];
    nameL.text          = [self.filePath lastPathComponent];
    nameL.font          = [UIFont systemFontOfSize:15.0];
    nameL.textColor     = [UIColor blackColor];
    nameL.numberOfLines = 0;
    nameL.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:nameL];
    [nameL sizeToFit];
    nameL.centerX = MAXScreenW*0.5;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(MAXScreenW*0.5-100, nameL.bottom+85, 200, 40)];
    [self.view addSubview:label];
    label.numberOfLines = 0;
    label.font = [UIFont systemFontOfSize:14.0];
    label.textColor = [UIColor blackColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = NSLocalizedString(@"file_not_support_local_browsing", @"该文件暂不支持本地浏览，请使用其他应用打开");
    [label sizeToFit];
    label.centerX = MAXScreenW * 0.5;
    UIButton *openBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    openBtn.frame     = CGRectMake(13, label.bottom + 40, MAXScreenW-26, 48);
    [self.view addSubview:openBtn];
    openBtn.layer.cornerRadius = 5;
    openBtn.layer.masksToBounds = YES;
    [openBtn setBackgroundImage:[UIImage imageNamed:@"beijign"] forState:UIControlStateNormal];
    [openBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [openBtn setTitle:NSLocalizedString(@"Opon_with_another_app", @"使用其他应用打开") forState:UIControlStateNormal];
    [openBtn addTarget:self action:@selector(otherApplicationOpen) forControlEvents:UIControlEventTouchUpInside];
}

- (void)webViewLoadData:(NSString *)type
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSURL *baseUrl = [NSURL fileURLWithPath:[paths objectAtIndex:0]];
    NSData *data = [[NSData alloc] initWithContentsOfFile:self.filePath];
    NSString *MIMEType = [NSString stringWithFormat:@"text/%@",type];
    [_webView loadData:data MIMEType:MIMEType characterEncodingName:@"UTF-8" baseURL:baseUrl];
}

- (void)otherApplicationOpen
{
    UIDocumentInteractionController *documentController =[UIDocumentInteractionController interactionControllerWithURL:self.fileURL];
    self.documentInCtr = documentController;  // 必须强引用起来
    [documentController presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];
    documentController.delegate = self;
}

#pragma mark -

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
{
    return self;
}


#pragma mark - QLDelegate
- (id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
    return self.fileURL;
}

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller
{
    return 1;
}

#pragma mark - webViewDelegate

-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    
   [webView evaluateJavaScript: @"var script = document.createElement('script');"
        "script.type = 'text/javascript';"
        "script.text = \"function ResizeImages() { "
        "var myimg,oldwidth;"
        "var maxwidth=350;"
        "for(i=0;i <document.images.length;i++){"
        "myimg = document.images[i];"
        "if(myimg.width > maxwidth){"
        "oldwidth = myimg.width;"
        "myimg.width = maxwidth;"
        "myimg.height = maxwidth * (myimg.height/oldwidth);"
        "}"
        "}"
        "}\";"
    "document.getElementsByTagName('head')[0].appendChild(script);" completionHandler:^(id _Nullable param, NSError * _Nullable error) {
        
    }];
    
//    [webView stringByEvaluatingJavaScriptFromString:
//     @"var script = document.createElement('script');"
//     "script.type = 'text/javascript';"
//     "script.text = \"function ResizeImages() { "
//     "var myimg,oldwidth;"
//     "var maxwidth=350;"
//     "for(i=0;i <document.images.length;i++){"
//     "myimg = document.images[i];"
//     "if(myimg.width > maxwidth){"
//     "oldwidth = myimg.width;"
//     "myimg.width = maxwidth;"
//     "myimg.height = maxwidth * (myimg.height/oldwidth);"
//     "}"
//     "}"
//     "}\";"
//     "document.getElementsByTagName('head')[0].appendChild(script);"];
//    [webView stringByEvaluatingJavaScriptFromString:@"ResizeImages();"];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}

@end
