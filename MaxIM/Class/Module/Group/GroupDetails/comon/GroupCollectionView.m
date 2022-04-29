//
//  ----------------------------------------------------------------------
//   File    :  GroupCollectionView.m
//   Author  : shaohui.yang shaohui@bmxlabs.com
//   Purpose :
//   Created : 2018/12/26 by shaohui.yang shaohui@bmxlabs.com
//
//  ----------------------------------------------------------------------
//
//                    Copyright (C) 2018-2019   MaxIM.Top
//
// You may obtain a copy of the licence at http://www.maxim.top/LICENCE-MAXIM.md
//
//  ----------------------------------------------------------------------
    

#import "GroupCollectionView.h"
#import <UIImageView+WebCache.h>

#import "GroupAddMemberController.h"

#import <floo-ios/BMXClient.h>
#import <floo-ios/BMXRoster.h>





@interface GroupMemberCollectionCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView* avatar;
@property (nonatomic, strong) UILabel* textLabel;
@end
@implementation GroupMemberCollectionCell
-(instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        [self initCell];
    }
    return self;
}

-(void) initCell
{
    self.avatar = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 40, 40)];
    [self.contentView addSubview:self.avatar];
    self.textLabel = [[UILabel alloc] initWithFrame:CGRectMake(3, 60, 64, 20)];
    self.textLabel.textAlignment = NSTextAlignmentCenter;
    self.textLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
    self.textLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1/1.0];
    [self.contentView addSubview:self.textLabel];
}
-(void) cellContentWithAvatar:(NSString*) url Name:(NSString*) name
{
    [self.avatar sd_setImageWithURL:[NSURL URLWithString:url]];
    self.textLabel.text = name;
}
-(void) cellContentWIthRoster:(BMXRoster*) roster
{
    if(roster.avatarThumbnailPath == nil || [@"" isEqualToString:roster.avatarThumbnailPath]) {
        self.avatar.image = [UIImage imageNamed:@"contact_placeholder"];
    }else {
        UIImage* image = [UIImage imageWithContentsOfFile:roster.avatarThumbnailPath];
        if(!image){
            [[[BMXClient sharedClient] rosterService] downloadAvatarWithRoster:roster isThumbnail:YES progress:^(int progress, BMXError *error) {
                
            } completion:^(BMXRoster *aroster, BMXError *error) {
                if(!error) {
                    UIImage* simage = [UIImage imageWithContentsOfFile:aroster.avatarThumbnailPath];
                    if(simage != nil) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.avatar.image = simage;
                            
                        });
                        
                    }

                }
            }];
        }else {
            self.avatar.image = image;
        }
    }
    
    NSString* name = roster.nickName;
    if(name == nil || [name isEqualToString:@""]) {
        name = roster.userName;
    }
    self.textLabel.text = name;
}
-(void) setLast
{
    self.textLabel.text = @"";
    self.avatar.image = [UIImage imageNamed:@"gray"];
}
@end

//////////////////////////////////////////////

@interface GroupCollectionView()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
{
    UICollectionView* _collectionView;
    NSInteger _avaliableCount;
}
@property (nonatomic, strong) NSArray* memberList;
@property (nonatomic, assign) BOOL limit;
@end

@implementation GroupCollectionView

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        [self prepareDataSource];
        [self initViews];
    }
    return self;
}

-(void) prepareDataSource
{
    _avaliableCount = self.memberList == nil ? 0 : self.memberList.count;
    if(self.limit) {
        NSInteger perLineCount = (MAXScreenW + 15) /  (60+15);
        NSInteger max = perLineCount * 2; //  2行最大数量
        if(self.memberList == nil) {
            _avaliableCount = 1;
        }else if(self.memberList.count >= max-1) {
            _avaliableCount = max;
        }else {
            _avaliableCount = self.memberList.count+1;
        }
        
        CGRect frame = self.frame;
        if(_avaliableCount <= perLineCount) { // 1行
            frame.size.height = 65+30;
        }else {
            frame.size.height = 65*2 + 45;
        }
        self.frame = frame;
        _collectionView.frame = frame;
    }else {
        _collectionView.frame = self.frame;
        _avaliableCount = self.memberList.count;
    }
}

- (void)initViews
{
    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
    _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [_collectionView registerClass:[GroupMemberCollectionCell class] forCellWithReuseIdentifier:@"GroupMemberCollectionCell"];
    [self addSubview:_collectionView];
}

#pragma mark ---- UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _avaliableCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.row;
    GroupMemberCollectionCell *cell = (GroupMemberCollectionCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"GroupMemberCollectionCell" forIndexPath:indexPath];
    if (index == _avaliableCount-1 && self.limit) {
        [cell setLast];
    }else {
        BMXRoster* roster = [self.memberList objectAtIndex:indexPath.item];
        [cell cellContentWIthRoster:roster];
    }
    
    return cell;
}

#pragma mark ---- UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(70, 80);  // image : 40, text: 20 + 5.
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsZero;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

#pragma mark ---- UICollectionViewDelegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
// 点击高亮
- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
//    cell.backgroundColor = [UIColor greenColor];
}
// 选中某item
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.item;
    if(index == _avaliableCount -1 && self.limit) { //最后一个
        if([self.gmCollectionDelegate respondsToSelector:@selector(groupMemberCellTouchedAdd)]) {
            [self.gmCollectionDelegate groupMemberCellTouchedAdd];
        }
    } else {
        if([self.gmCollectionDelegate respondsToSelector:@selector(groupMemberCellTouchedRoster:)]) {
            BMXRoster* roster = (BMXRoster*)[self.memberList objectAtIndex:index];
            [self.gmCollectionDelegate groupMemberCellTouchedRoster:roster];
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(nullable id)sender
{

}

-(CGFloat) viewHeight
{
    return 65*2 + 45;
}

-(void) fillRosterList:(NSArray<BMXRoster*>*) list limit2line:(BOOL) limit
{
    self.memberList = [NSArray arrayWithArray:list];
    self.limit = limit;
    [self prepareDataSource];
    [_collectionView reloadData];
}

+ (CGFloat) calcHeightWithArrcount:(NSInteger) count limt:(BOOL) limit
{
    // 宽高 : 70 * 50，高边距 80+15， 高计算: 80*n + 15;

    NSInteger lineCount =   (MAXScreenW + 15) /  (60+15);
    NSInteger lines = count/lineCount;
    if(count% lineCount > 0 && count >lineCount) {
        lines = lines + 1;
    } else if(count% lineCount == 0) {
        lines = lines + 1;
    } else {
        lines = 1;
    }
    
    if(lines > 2 && limit) {
        lines = 2;
    }
    return 80*lines + 15;
}
@end
