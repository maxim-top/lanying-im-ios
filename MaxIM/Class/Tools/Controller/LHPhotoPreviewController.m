//
//  LHPhotoPreviewController.m
//  LHChatUI
//
//  Created by hyt on 2016/12/28.
//  Copyright © 2016年 hyt. All rights reserved.
//

#import "LHPhotoPreviewController.h"
#import "LHPhotoPreviewCell.h"
#import "XSBrowserAnimateDelegate.h"
#import "UIActionSheet+Blocks.h"
#import "LHMessageModel.h"
#import <Photos/Photos.h>
#import <floo-ios/floo_proxy.h>


@interface LHPhotoPreviewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate, UIActionSheetDelegate, BMXChatServiceProtocol> {
    UICollectionView *_collectionView;
}


@property (nonatomic, strong) BMXMessage *messageObject;

@end

@implementation LHPhotoPreviewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configCollectionView];
    self.view.clipsToBounds = YES;
    [[[BMXClient sharedClient] chatService] addDelegate:self];

}

- (void)messageAttachmentStatusDidChanged:(BMXMessage *)message error:(BMXError *)error percent:(int)percent {
    
//    MAXLog(@"走了吗");
    if (!error && percent == 101) {
        self.messageObject = message;
        _models = @[self.messageObject];
        [_collectionView reloadData];
    } else if (error) {
        self.messageObject = message;
        _models = @[self.messageObject];
        [_collectionView reloadData];
    }
}

- (void)setModels:(NSArray *)models {
    LHMessageModel *messagemodel = models.firstObject;
    BMXImageAttachment *attachment = [BMXImageAttachment dynamicCastWithAttachment:messagemodel.messageObjc.attachment];
    if (attachment.path == nil ||  [@"" isEqualToString:attachment.path] || ![[NSFileManager defaultManager] fileExistsAtPath:attachment.path]) {
        [[[BMXClient sharedClient] chatService] downloadAttachmentWithMsg:messagemodel.messageObjc completion:^(BMXError *aError) {
            self.messageObject = messagemodel.messageObjc;
            _models = @[self.messageObject];
            [_collectionView reloadData];
        }];
    } else {
        self.messageObject = messagemodel.messageObjc;
        _models = @[self.messageObject];
        [_collectionView reloadData];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_currentIndex) [_collectionView setContentOffset:CGPointMake((self.view.width + 20) * _currentIndex, 0) animated:NO];
}

- (void)configCollectionView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(self.view.width + 20, self.view.height);
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(-10, 0, self.view.width + 20, self.view.height) collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor blackColor];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.pagingEnabled = YES;
    _collectionView.scrollsToTop = NO;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.contentOffset = CGPointMake(0, 0);
    _collectionView.contentSize = CGSizeMake(self.models.count * (self.view.width + 20), 0);
    [self.view addSubview:_collectionView];
    [_collectionView registerClass:[LHPhotoPreviewCell class] forCellWithReuseIdentifier:@"LHPhotoPreviewCell"];
}

#pragma mark - piv
- (void)showReminderWithContent:(NSString *)content {
    UIView *reminderView = [[UIView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.view.frame)-250*0.5)/2, (CGRectGetHeight(self.view.frame)-220*0.5)*0.5, 250*0.5, 220*0.5)];
    reminderView.layer.cornerRadius = 8;
    reminderView.layer.masksToBounds = YES;
    reminderView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.85f];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectZero];
    label.font = [UIFont systemFontOfSize:12.0f];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = content;
    label.numberOfLines = 0;
    label.textColor = [UIColor whiteColor];
    [reminderView addSubview:label];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSString alloc] initWithFormat:@"%@/%@",recourcesPath,@"icon_success_hite"]]];
    [reminderView addSubview:imageView];
    imageView.frame = CGRectMake((CGRectGetWidth(reminderView.frame)-69*0.5)*0.5, (CGRectGetHeight(reminderView.frame)-69*0.5)*0.5-20, 69*0.5, 69*0.5);
    
    label.frame = CGRectMake(0, CGRectGetMaxY(imageView.frame)+5, CGRectGetWidth(reminderView.frame), 45);
    
    [self.view addSubview:reminderView];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.50f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [reminderView removeFromSuperview];
    });
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offSetWidth = scrollView.contentOffset.x;
    offSetWidth = offSetWidth +  ((self.view.width + 20) * 0.5);
    
    NSInteger currentIndex = offSetWidth / (self.view.width + 20);
    
    if (_currentIndex != currentIndex) {
        _currentIndex = currentIndex;
    }
}

#pragma mark - UICollectionViewDataSource && Delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _models.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LHPhotoPreviewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"LHPhotoPreviewCell" forIndexPath:indexPath];
    [cell setImageUrlWith:self.messageObject];
//    cell.imageUrl = _models[indexPath.row];
    
    if (!cell.singleTapGestureBlock) {
        LHWeakSelf;
        __weak XSBrowserAnimateDelegate *weakDelegate = [XSBrowserAnimateDelegate shareInstance];
        cell.singleTapGestureBlock = ^(CGRect imageRect) {
            weakDelegate.currentFrame = imageRect;
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        };
    }
    if (!cell.longPressGestureBlock) {
        LHWeakSelf;
        cell.longPressGestureBlock = ^(UIImage *image) {
            [UIActionSheet showInView:self.view withTitle:NSLocalizedString(@"Save_image_to_album", @"保存图片到相册") cancelButtonTitle:NSLocalizedString(@"Cancel", @"取消") destructiveButtonTitle:nil otherButtonTitles:@[NSLocalizedString(@"Save", @"保存")] tapBlock:^(UIActionSheet * _Nonnull actionSheet, NSInteger buttonIndex) {
                if (!buttonIndex) {
                    dispatch_async(dispatch_get_global_queue(0, 0), ^{
                        NSData *data = UIImageJPEGRepresentation(image, 1.0);
                        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                            PHAssetCreationRequest *createRequest = nil;
                            if ([data isKindOfClass:NSData.class]) {
                                PHAssetResourceCreationOptions *options = [[PHAssetResourceCreationOptions alloc] init];
                                createRequest = [PHAssetCreationRequest creationRequestForAsset];
                                [createRequest addResourceWithType:PHAssetResourceTypePhoto data:data options:options];
                            }
                        } completionHandler:^(BOOL success, NSError * _Nullable error) {
                            if (success) {
                                [weakSelf showReminderWithContent:NSLocalizedString(@"Image_saved_to_album", @"图片已保存到相册")];
                            }
                        }];
//                        UIImageWriteToSavedPhotosAlbum(image, nil, nil,nil);
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            [weakSelf showReminderWithContent:NSLocalizedString(@"Image_saved_to_album", @"图片已保存到相册")];
                        });
                    });
                    
                }
            }];
        };
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[LHPhotoPreviewCell class]]) {
        [(LHPhotoPreviewCell *)cell recoverSubviews];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[LHPhotoPreviewCell class]]) {
        [(LHPhotoPreviewCell *)cell recoverSubviews];
    }
}


@end
