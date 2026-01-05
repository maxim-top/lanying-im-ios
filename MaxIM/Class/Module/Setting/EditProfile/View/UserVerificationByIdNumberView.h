#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@protocol BindPhoneProtocol <NSObject>

@optional

- (void)commitName:(NSString *)name idNumber:(NSString *)idNumber;

@end

@interface UserVerificationByIdNumberView : UIView

@property (nonatomic, assign) id<BindPhoneProtocol> delegate;

@end

NS_ASSUME_NONNULL_END
