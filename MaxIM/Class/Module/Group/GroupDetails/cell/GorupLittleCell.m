//
//  ----------------------------------------------------------------------
//   File    :  GorupLittleCell.m
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
    

#import "GorupLittleCell.h"
#import <UIImageView+WebCache.h>
#import "UIView+BMXframe.h"
#import "BMXRoster.h"
#import "BMXClient.h"

// cell height: 60;

@interface GorupLittleCell()
{
    UIImageView* _avatar;
    UILabel* _rosterName;
    UIImageView* _selectionImage;
    UIImageView* _adminImage;
}

@end

@implementation GorupLittleCell

-(instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initViews];
    }
    return self;
}

-(void) initViews
{
    _avatar = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 40, 40)];
    _avatar.layer.cornerRadius = 3.0f;
    _avatar.layer.masksToBounds = YES;
    [self.contentView addSubview:_avatar];
    
    _rosterName = [[UILabel alloc] init];
    _rosterName.frame = CGRectMake(70, 0, MAXScreenW-120, 60);
    _rosterName.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16];
    [self.contentView addSubview:_rosterName];
    
    _selectionImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check"]];
    _selectionImage.bmx_right = MAXScreenW - 15;
    _selectionImage.bmx_centerY = 30;
    _selectionImage.bmx_size = CGSizeMake(16, 13);
    _selectionImage.image = [UIImage imageNamed:@"check"];
    [_selectionImage setHidden:YES];
    [self.contentView addSubview:_selectionImage];
    
    _adminImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"personal"]];
    _adminImage.frame = CGRectMake(MAXScreenW-35, 20, 20, 20);
    [self.contentView addSubview:_adminImage];
    [_adminImage setHidden:YES];
}

- (void)setDlownAvatar:(BMXRoster *)roster Selected:(BOOL) isSelected {
    _avatar.image = [UIImage imageNamed:@"contact_placeholder"];
    
    UIImage *image = [UIImage imageWithContentsOfFile:roster.avatarThumbnailPath];
    if (!image) {
        [[[BMXClient sharedClient] rosterService] downloadAvatarWithRoster:roster progress:^(int progress, BMXError *error) {
            
        }  completion:^(BMXRoster *rosterObjc, BMXError *error) {
            if (!error) {
                UIImage *image = [UIImage imageWithContentsOfFile:rosterObjc.avatarThumbnailPath];
                dispatch_async(dispatch_get_main_queue(), ^{
                    _avatar.image = image;
                });
            }
        }];
    }else {
        _avatar.image = image;
    }

}

-(void) setAvatarStr:(NSString*) avatarStr RosterName:(NSString*) name Selected:(BOOL) isSelected
{
    _rosterName.text = name;
    [_selectionImage setHidden:!isSelected];
}

-(void) setAvatarRoster:(BMXRoster*)roster RosterName:(NSString*) name Selected:(BOOL) isSelected
{
    _avatar.image = [UIImage imageNamed:@"contact_placeholder"];

    [_selectionImage setHidden:!isSelected];
    UIImage *image = [UIImage imageWithContentsOfFile:roster.avatarThumbnailPath];
    if (!image) {
        [[[BMXClient sharedClient] rosterService] downloadAvatarWithRoster:roster progress:^(int progress, BMXError *error) {
            
        }  completion:^(BMXRoster *rosterObjc, BMXError *error) {
            if (!error) {
                UIImage *image = [UIImage imageWithContentsOfFile:rosterObjc.avatarThumbnailPath];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self->_avatar.image = image;
                });
            }
        }];
    }else {
        _avatar.image = image;
    }
    _rosterName.text = name;
}
-(void) setAvatarUrl:(NSString*) avatarUrl RosterName:(NSString*) name Selected:(BOOL) isSelected
{
    [_avatar sd_setImageWithURL:[NSURL URLWithString:avatarUrl] placeholderImage:[UIImage imageNamed:@"contact_placeholder"]];
    _rosterName.text = name;
    [_selectionImage setHidden:!isSelected];
}

-(void) setSelect:(BOOL) isSelect
{
    [_selectionImage setHidden:!isSelect];
}

-(void) showAdmin:(BOOL) isShow
{
    [_adminImage setHidden:!isShow];
}




@end
