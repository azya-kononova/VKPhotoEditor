@interface ZoomingView : UIView 

@property (nonatomic, assign) CGFloat minZoomScale;
@property (nonatomic, assign) CGFloat maxZoomScale;
@property (nonatomic, assign) BOOL shouldCenterizeContent;
@property (nonatomic, assign, readonly) CGFloat zoomScale;
@property (nonatomic, assign, readonly) CGPoint contentOffset;

- (id)initWithContentView:(UIView *)view frame:(CGRect)frame;
- (void)resetZoom;

@end
