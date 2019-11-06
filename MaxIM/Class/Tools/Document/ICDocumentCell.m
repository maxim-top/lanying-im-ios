//
//  ICDocumentCell.m
//  XZ_WeChat
//
//  Created by hyt on 16/7/22.
//  Copyright © 2016年 gxz All rights reserved.
//

#import "ICDocumentCell.h"


@interface ICDocumentCell ()

@property (nonatomic, weak) UIImageView *imageV;
@property (nonatomic, weak) UILabel *nameLabel;
@property (nonatomic, weak) UILabel *sizeLabel;


@end

@implementation ICDocumentCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.leftFreeSpace = 115;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}


+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"docCell";
    ICDocumentCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[ICDocumentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    return cell;
}

// 这里name是拼接后的全称
- (void)setName:(NSString *)name
{

    _name = name;
    self.nameLabel.text = name;
}



- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.selectBtn.frame = CGRectMake(15, 30, 20, 20);
    self.imageV.frame    = CGRectMake(55, 15, 50, 50);
    self.nameLabel.frame = CGRectMake(_imageV.right+10, 15, MAXScreenW-_imageV.right-10-40, 16);
    [_nameLabel sizeToFit];
    self.sizeLabel.frame = CGRectMake(_imageV.right+10,_imageV.bottom-15 , 100, 15);
    [_sizeLabel sizeToFit];
}


- (void)selectBtnClicked:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(selectBtnClicked:)]) {
        [self.delegate selectBtnClicked:sender];
    }
}

#pragma mark - Getter

- (UIButton *)selectBtn
{
    if (!_selectBtn) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.contentView addSubview:btn];
        _selectBtn = btn;
        [_selectBtn setImage:[UIImage imageNamed:@"App_select_dis"] forState:UIControlStateNormal];
        [_selectBtn setImage:[UIImage imageNamed:@"App_select"] forState:UIControlStateSelected];
        [_selectBtn addTarget:self action:@selector(selectBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _selectBtn;
}

- (UIImageView *)imageV
{
    if (!_imageV) {
        UIImageView *imageV = [[UIImageView alloc] init];
        [self.contentView addSubview:imageV];
        _imageV = imageV;
    }
    return _imageV;
}

- (UILabel *)nameLabel
{
    if (!_nameLabel) {
        UILabel *label = [[UILabel alloc] init];
        [self.contentView addSubview:label];
        _nameLabel = label;
        _nameLabel.font = [UIFont systemFontOfSize:15.0];
        _nameLabel.numberOfLines = 2;
        _nameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        _nameLabel.textColor = [UIColor blackColor];
    }
    return _nameLabel;
}

- (UILabel *)sizeLabel
{
    if (!_sizeLabel) {
        UILabel *label = [[UILabel alloc] init];
        [self.contentView addSubview:label];
        _sizeLabel = label;
        _sizeLabel.font = [UIFont systemFontOfSize:11.0];
        _sizeLabel.textColor = [UIColor grayColor];
    }
    return _sizeLabel;
}


@end
