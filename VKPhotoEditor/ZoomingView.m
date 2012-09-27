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
    BOOL reallyNeedsLayout_;
}

@synthesize minZoomScale;
@synthesize maxZoomScale;
@synthesize shouldCenterizeContent;

- (void)setNeedsLayout
{
    [super setNeedsLayout];
    reallyNeedsLayout_ = YES;
}

- (void)setFrame:(CGRect)rect
{
    [super setFrame:rect];
    reallyNeedsLayout_ = YES;
}

- (void)centerContent:(BOOL)animated
{
    CGPoint contentCenter = contentView.center;
    CGPoint scrollCenter = scroll.center;
    CGPoint offset = CGPointMake(contentCenter.x - scrollCenter.x, contentCenter.y - scrollCenter.y);
    [scroll setContentOffset:offset animated:animated];
}

- (CGFloat)zoomScaleToFitOrFill:(BOOL)fit
{
    CGPoint scale = CGFrameScale(self.bounds, contentView.bounds);
    return fit ? fminf(scale.x, scale.y) : fmaxf(scale.x, scale.y);
}

- (void)setupZoom
{
    BOOL fit = self.contentMode == UIViewContentModeScaleAspectFit;
    scroll.minimumZoomScale = (minZoomScale) ? minZoomScale : fminf(1, [self zoomScaleToFitOrFill:YES]);
    scroll.maximumZoomScale = (maxZoomScale) ? maxZoomScale : 1;
    
    [scroll setZoomScale:[self zoomScaleToFitOrFill:fit] animated:NO];
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
    [self setupInsetsAndZoom];
    scroll.zoomScale = initialZoomScale;
    [self centerContent:NO];   
}

- (id)initWithContentView:(UIView *)view frame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        shouldCenterizeContent = YES;
        self.contentMode = UIViewContentModeScaleAspectFit;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
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

- (void) layoutSubviews
{
    if (!reallyNeedsLayout_) return;
    reallyNeedsLayout_ = NO;
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
   [self setupInsets];
}

@end