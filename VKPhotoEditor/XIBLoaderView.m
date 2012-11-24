#import "XIBLoaderView.h"
#import "UIView+NIB.h"

@implementation XIBLoaderView

@synthesize fileOwner;
@synthesize delegate;

- (void)awakeFromNib {
    [super awakeFromNib];

    NSArray *params = [self.text componentsSeparatedByString:@";"];
    NSString *className = [params objectAtIndex:0];
    
    UIView *view = [NSClassFromString(className) loadFromNIBWithOwner:fileOwner];
    view.frame = self.frame;
    view.autoresizingMask = self.autoresizingMask;
    view.tag = self.tag;

    [self.superview addSubview:view];
    [self removeFromSuperview];
    
    NSArray *userParams = [params subarrayWithRange:NSMakeRange(1, params.count-1)];
    [delegate xibLoaderView:self replacedWithView:view userParams:userParams];
}

@end
