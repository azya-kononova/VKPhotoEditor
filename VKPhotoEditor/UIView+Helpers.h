#import <UIKit/UIKit.h>

typedef CGRect (^UIViewFrameAdjustBlock)(CGRect frame);

@interface UIView (Helpers)

- (void)adjustFrame:(UIViewFrameAdjustBlock)block;
- (void)moveBy:(CGPoint)offset;
- (void)moveTo:(CGPoint)origin;
- (void)resizeTo:(CGSize)size;
- (void)expand:(CGSize)size;

- (void)roundCorners:(UIRectCorner)corners;

@end
