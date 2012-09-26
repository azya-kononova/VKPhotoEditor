#import "ZoomingView.h"

@interface ZoomingView () <UIScrollViewDelegate>
@end

static CGPoint CGFrameScale(CGRect f1, CGRect f2)
{
    return CGPointMake(f1.size.width / f2.size.width, f1.size.height / f2.size.height);
}

@implementation ZoomingView {
    UIView *contentView;
    UIScrollView *scroll;
    CGFloat initialZoomScale;
}

@synthesize minZoomScale;
@synthesize maxZoomScale;
@synthesize shouldCenterizeContent;

- (void)centerContent:(BOOL)animated
{
    CGPoint contentCenter = contentView.center;
    CGPoint scrollCenter = scroll.center;
    CGPoint offset = CGPointMake(contentCenter.x - scrollCenter.x, contentCenter.y - scrollCenter.y);
    [scroll setContentOffset:offset animated:animated];
}

- (CGFloat)zoomScaleToFitOrFill:(BOOL)fit
{
    CGPoint scale = CGFrameScale(self.bounds, contentView.frame);
    return fit ? fminf(scale.x, scale.y) : fmaxf(scale.x, scale.y);
}

- (void)setupZoom
{
    BOOL fit = self.contentMode == UIViewContentModeScaleAspectFit;
    scroll.minimumZoomScale = (minZoomScale) ? minZoomScale : fminf(1, [self zoomScaleToFitOrFill:YES]);
    scroll.maximumZoomScale = (maxZoomScale) ? maxZoomScale : 1;

    scroll.zoomScale = [self zoomScaleToFitOrFill:fit];
    initialZoomScale = scroll.zoomScale;
    
    if (fit && shouldCenterizeContent) {
        [self centerContent:NO];
    }
}

- (void)setupInsets
{
    CGFloat dx = scroll.frame.size.width - contentView.frame.size.width;
    CGFloat dy = scroll.frame.size.height - contentView.frame.size.height;
    UIEdgeInsets insets = UIEdgeInsetsZero;
    if (dx > 0) insets.left = dx/2;
    if (dy > 0) insets.top = dy/2;
    
    scroll.contentInset = insets;
}

- (void) setupInsetsAndZoom
{
    [self setupInsets];
    [self setupZoom];
}

- (void) resetZoom
{
    scroll.zoomScale = initialZoomScale;
    [self centerContent:NO];
}

- (id)initWithContentView:(UIView *)view frame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        shouldCenterizeContent = YES;
        self.contentMode = UIViewContentModeScaleAspectFit;
        contentView = view;
        contentView.frame = view.bounds;
        scroll = [[UIScrollView alloc] initWithFrame:self.bounds];
        scroll.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        scroll.delegate = self;
        scroll.showsVerticalScrollIndicator = NO;
        scroll.showsHorizontalScrollIndicator = NO;
        [scroll addSubview:contentView];
        [self addSubview:scroll];
    }
    
    return self;
}

- (id)initWithContentView:(UIView *)view
{
    return [self initWithContentView:view frame:view.frame];
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    [self setupInsetsAndZoom];
}

- (CGFloat)zoomScale
{
    return scroll.zoomScale;
}

- (CGPoint)contentOffset
{
    return scroll.contentOffset;
}

#pragma mark - ScrollView delegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return contentView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat offsetX = (scroll.bounds.size.width > scroll.contentSize.width) ? (scroll.bounds.size.width - scroll.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scroll.bounds.size.height > scroll.contentSize.height) ? (scroll.bounds.size.height - scroll.contentSize.height) * 0.5 : 0.0;
    contentView.center = CGPointMake(scroll.contentSize.width * 0.5 + offsetX, scroll.contentSize.height * 0.5 + offsetY);
}

@end