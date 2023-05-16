#import <UIKit/UIKit.h>
#import <floo-ios/floo_proxy.h>

@class CallViewController;
@protocol CallViewControllerDelegate <NSObject>

- (void)viewControllerDidFinish:(CallViewController *)viewController;

@end

@interface CallViewController : UIViewController
@property(nonatomic, assign) long long roomId;
@property(nonatomic, strong) NSString *callId;
@property(nonatomic, strong) NSString *pin;
@property(nonatomic, assign) long long myId;
@property(nonatomic, assign) long long peerId;
@property(nonatomic, assign) long long messageId;
@property(nonatomic, assign) BOOL isCaller;
@property(nonatomic, assign) BOOL hasVideo;

- (instancetype)initForRoom:(long long)roomId
                     callId:(NSString*)callId
                       myId:(long long)myId
                     peerId:(long long)peerId
                  messageId:(long long)messageId
                        pin:(NSString*)pin
                   isCaller:(BOOL)isCaller
                   hasVideo:(BOOL)hasVideo
              currentRoster:(BMXRosterItem *)roster;

@end
