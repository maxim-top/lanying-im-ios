#import <UIKit/UIKit.h>
#import "LHChatBarEmoticonView.h"

@interface LHChatBarEmoticonView () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *recentCollectionView;
@property (nonatomic, strong) UICollectionView *allEmoticonCollectionView;
//@property (nonatomic, strong) NSMutableArray<NSString *> *recentEmoticons;
@property (nonatomic, strong) NSArray<NSString *> *allEmoticons;
@property (nonatomic, strong) UIButton *backspaceButton;
@property (nonatomic, strong) UIButton *sendButton;

@end

@implementation LHChatBarEmoticonCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.emoticonLabel = [[UILabel alloc] init];
        self.emoticonLabel.textAlignment = NSTextAlignmentCenter;
        self.emoticonLabel.font = [UIFont systemFontOfSize:30];
        [self.contentView addSubview:self.emoticonLabel];
        
        self.emoticonLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
            [self.emoticonLabel.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor],
            [self.emoticonLabel.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor]
        ]];
    }
    return self;
}

- (void)setEmoticon:(NSString *)emoticon {
    _emoticon = [emoticon copy];
    self.emoticonLabel.text = emoticon;
}

@end

@implementation LHChatBarEmoticonView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupData];
        [self setupUI];
    }
    return self;
}

- (void)setupData {
    // 初始化表情数据
//    self.recentEmoticons = [NSMutableArray array];
    
    // 这里使用一些常用的emoji表情作为示例
    self.allEmoticons = @[@"😀", @"😃", @"😄", @"😁", @"😆", @"😅", @"😂", @"🤣", @"☺️", @"😊",
                          @"😇", @"🙂", @"🙃", @"😉", @"😌", @"😍", @"🥰", @"😘", @"😗", @"😙",
                          @"😚", @"😋", @"😛", @"😝", @"😜", @"🤪", @"🤨", @"🧐", @"🤓", @"😎",
                          @"🤩", @"🥳", @"😏", @"😒", @"😞", @"😔", @"😟", @"😕", @"🙁", @"☹️",
                          @"😣", @"😖", @"😫", @"😩", @"🥺", @"😢", @"😭", @"😮", @"😯", @"😲",
                          @"😳", @"🥵", @"🥶", @"😱", @"😨", @"😰", @"😥", @"😓", @"🤗", @"🤔",
                          @"🤭", @"🤫", @"🤥", @"😶", @"😐", @"😑", @"😬", @"🙄", @"😯", @"😦",
                          @"😧", @"😮", @"😲", @"🥱", @"😴", @"🤤", @"😪", @"😵", @"🥴", @"🤢",
                          @"🤮", @"🤧", @"😷", @"🤒", @"🤕", @"🤠", @"🥸", @"😈", @"👿", @"👹",
                          @"👺", @"🤡", @"💩", @"👻", @"💀", @"☠️", @"👽", @"👾", @"🤖", @"🎃",
                          @"😺", @"😸", @"😹", @"😻", @"😼", @"😽", @"🙀", @"😿", @"😾", @"🙈", @"🙉", @"🙊",
                          @"❤️", @"🧡", @"💛", @"💚", @"💙", @"💜", @"🖤", @"🤍", @"🤎", @"💔", @"❣️", @"💕", @"💞", @"💓", @"💗", @"💖", @"💘", @"💝",
                          @"👍", @"👎", @"👌", @"🤏", @"✌️", @"🤞", @"🤟", @"🤘", @"👊", @"✊", @"🤛", @"🤜", @"👏", @"🙌", @"🤲", @"👐", @"🤝", @"🙏",
                          @"💪", @"👀", @"👁️", @"🧠",
                          @"🥲", @"😮‍💨", @"😵‍💫", @"❤️‍🔥", @"❤️‍🩹"];
}

- (void)setupUI {
//    // 最近使用的表情布局
//    UICollectionViewFlowLayout *recentLayout = [[UICollectionViewFlowLayout alloc] init];
//    recentLayout.itemSize = CGSizeMake(50, 50);
//    recentLayout.minimumInteritemSpacing = 5;
//    recentLayout.minimumLineSpacing = 5;
//    recentLayout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
//    
//    // 最近使用的表情CollectionView
//    self.recentCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:recentLayout];
//    self.recentCollectionView.backgroundColor = [UIColor clearColor];
//    self.recentCollectionView.dataSource = self;
//    self.recentCollectionView.delegate = self;
//    [self.recentCollectionView registerClass:[LHChatBarEmoticonCell class] forCellWithReuseIdentifier:@"RecentCell"];
//    [self addSubview:self.recentCollectionView];
    
    // 所有表情布局
    UICollectionViewFlowLayout *allLayout = [[UICollectionViewFlowLayout alloc] init];
    allLayout.itemSize = CGSizeMake(45, 45);
    allLayout.minimumInteritemSpacing = 2;
    allLayout.minimumLineSpacing = 2;
    allLayout.sectionInset = UIEdgeInsetsMake(0, 5, 0, 5);
    
    // 所有表情CollectionView
    self.allEmoticonCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:allLayout];
    self.allEmoticonCollectionView.backgroundColor = [UIColor clearColor];
    self.allEmoticonCollectionView.dataSource = self;
    self.allEmoticonCollectionView.delegate = self;
    [self.allEmoticonCollectionView registerClass:[LHChatBarEmoticonCell class] forCellWithReuseIdentifier:@"AllCell"];
    [self addSubview:self.allEmoticonCollectionView];
    
    // 设置约束
//    self.recentCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.allEmoticonCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [NSLayoutConstraint activateConstraints:@[
//        // 最近使用的表情约束
//        [self.recentCollectionView.topAnchor constraintEqualToAnchor:self.topAnchor],
//        [self.recentCollectionView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
//        [self.recentCollectionView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
//        [self.recentCollectionView.heightAnchor constraintEqualToConstant:50],
        
        // 所有表情约束
        [self.allEmoticonCollectionView.topAnchor constraintEqualToAnchor:self.self.topAnchor],
        [self.allEmoticonCollectionView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [self.allEmoticonCollectionView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [self.allEmoticonCollectionView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor]
    ]];
    
    // 创建退格键按钮
    self.backspaceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backspaceButton setImage:[UIImage imageNamed:@"backspace"] forState:UIControlStateNormal];
    [self.backspaceButton addTarget:self action:@selector(backspaceButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.backspaceButton];
    
    // 创建发送键按钮
    self.sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [self.sendButton setImage:[UIImage imageNamed:@"send"] forState:UIControlStateNormal];
    [self.sendButton setTitle:NSLocalizedString(@"Send", @"发送") forState:UIControlStateNormal];
    [self.sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.sendButton.titleLabel.font =  [UIFont systemFontOfSize:16];
    self.sendButton.layer.cornerRadius = 4;
    self.sendButton.layer.backgroundColor = [UIColor systemGreenColor].CGColor;
    [self.sendButton addTarget:self action:@selector(sendButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.sendButton];
    
    // 设置按钮约束，使其浮于右下角
    self.backspaceButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.sendButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    [NSLayoutConstraint activateConstraints:@[
        // 退格键按钮约束
        [self.backspaceButton.widthAnchor constraintEqualToConstant:40],
        [self.backspaceButton.heightAnchor constraintEqualToConstant:40],
        [self.backspaceButton.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-20],
        [self.backspaceButton.trailingAnchor constraintEqualToAnchor:self.sendButton.leadingAnchor constant:-10],
        
        // 发送键按钮约束
        [self.sendButton.widthAnchor constraintEqualToConstant:50],
        [self.sendButton.heightAnchor constraintEqualToConstant:40],
        [self.sendButton.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-20],
        [self.sendButton.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-10]
    ]];

    // 确保按钮浮于上层
    [self bringSubviewToFront:self.backspaceButton];
    [self bringSubviewToFront:self.sendButton];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
//    if (collectionView == self.recentCollectionView) {
//        return MIN(self.recentEmoticons.count, 8);
//    } else {
        return self.allEmoticons.count;
//    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
//    NSString *identifier = collectionView == self.recentCollectionView ? @"RecentCell" : @"AllCell";
    NSString *identifier = collectionView == self.recentCollectionView ? @"RecentCell" : @"AllCell";
    LHChatBarEmoticonCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    NSString *emoticon;
//    if (collectionView == self.recentCollectionView) {
//        emoticon = self.recentEmoticons[indexPath.item];
//    } else {
        emoticon = self.allEmoticons[indexPath.item];
//    }
    
    cell.emoticon = emoticon;
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *selectedEmoticon;
//    if (collectionView == self.recentCollectionView) {
//        selectedEmoticon = self.recentEmoticons[indexPath.item];
//    } else {
        selectedEmoticon = self.allEmoticons[indexPath.item];
//        // 添加到最近使用
//        if (![self.recentEmoticons containsObject:selectedEmoticon]) {
//            [self.recentEmoticons insertObject:selectedEmoticon atIndex:0];
//            if (self.recentEmoticons.count > 8) {
//                [self.recentEmoticons removeLastObject];
//            }
//            [self.recentCollectionView reloadData];
//        }
//    }
    
    if (self.didSelectEmoticon) {
        self.didSelectEmoticon(selectedEmoticon);
    }
}

#pragma mark - Button Actions

- (void)backspaceButtonTapped {
    // 处理退格键点击事件
    if (self.didSelectEmoticon) {
        self.didSelectEmoticon(@"backspace");
    }
}

- (void)sendButtonTapped {
    // 处理发送键点击事件
    if (self.didSelectEmoticon) {
        self.didSelectEmoticon(@"send");
    }
}

@end
