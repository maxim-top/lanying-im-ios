#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@protocol BindPhoneProtocol <NSObject>

@optional

- (void)sendChaptchaWithPhone:(NSString *)phone;

- (void)commitPhone:(NSString *)phone chptcha:(NSString *)chptcha;

@end

@interface UserVerificationView : UIView

@property (nonatomic, assign) id<BindPhoneProtocol> delegate;


- (instancetype)initWithFrame:(CGRect)frame
                   needTitle:(BOOL)needTitle
                    titleText:(NSString *)titleText;

- (void)setPhoneNum:(NSString *)phoneNum;

@end

NS_ASSUME_NONNULL_END
