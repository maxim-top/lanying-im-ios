#import <UIKit/UIKit.h>

@interface LHChatBarEmoticonCell : UICollectionViewCell

@property (nonatomic, strong) UILabel *emoticonLabel;
@property (nonatomic, copy) NSString *emoticon;

@end

@interface LHChatBarEmoticonView : UIView

@property (nonatomic, copy) void (^didSelectEmoticon)(NSString *emoticon);

@end