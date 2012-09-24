#import "UIView+Helpers.h"

@implementation UIView (Helpers)

- (void)adjustFrame:(UIViewFrameAdjustBlock)block
{
    self.frame = block(self.frame);
}

- (void)moveBy:(CGPoint)offset
{
    [self adjustFrame:^CGRect(CGRect frame) {
        frame.origin.x += offset.x;
        frame.origin.y += offset.y;
        return frame;
    }];
}

- (void)moveTo:(CGPoint)origin
{
    [self adjustFrame:^CGRect(CGRect frame) {
        frame.origin = origin;
        return frame;
    }];
}

- (void)resizeTo:(CGSize)size
{
    [self adjustFrame:^CGRect(CGRect frame) {
        frame.size = size;
        return frame;
    }];
}

- (void)expand:(CGSize)size
{
    [self adjustFrame:^CGRect(CGRect frame) {
        frame.size.width += size.width;
        frame.size.height += size.height;
        return frame;
    }];
}

- (void)roundCorners:(UIRectCorner)corners
{
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds 
                                                   byRoundingCorners:corners
                                                         cornerRadii:CGSizeMake(7.5, 7.5)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    
    self.layer.mask = maskLayer;
}

@end
