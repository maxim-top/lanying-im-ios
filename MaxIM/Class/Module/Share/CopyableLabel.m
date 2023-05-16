#import "CopyableLabel.h"

@implementation CopyableLabel

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.userInteractionEnabled = YES;
        
        UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] init];
        [gesture addTarget:self action:@selector(longPressAction:)];
        [self addGestureRecognizer:gesture];
    }
    return self;
}

- (void)longPressAction:(UILongPressGestureRecognizer *)rec
{
    [self becomeFirstResponder];

    UIMenuItem *copyMenuItem = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copyAction)];
    UIMenuController *controller = [UIMenuController sharedMenuController];
    [controller setMenuItems:[NSArray arrayWithObject:copyMenuItem]];
    [controller setTargetRect:self.frame inView:self.superview];
    [controller setMenuVisible:YES animated:YES];
}

- (void)copyAction
{
    UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
    pasteBoard.string = self.text;
}

#pragma mark  --  UIResponder
- (BOOL)canBecomeFirstResponder
{
    return YES;
}
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    return action == @selector(copyAction);
}
@end
