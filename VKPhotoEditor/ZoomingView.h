@interface ZoomingView : UIView 

@property (nonatomic, assign) CGFloat minZoomScale;
@property (nonatomic, assign) CGFloat maxZoomScale;
@property (nonatomic, assign) BOOL shouldCenterizeContent;
@property (nonatomic, assign, readonly) CGFloat zoomScale;
@property (nonatomic, assign, readonly) CGPoint contentOffset;
@property (nonatomic, assign) UIEdgeInsets scrollInsets;
@property (nonatomic, assign) BOOL shouldClip;

- (id)initWithContentView:(UIView *)view frame:(CGRect)frame;
- (void)resetZoom;

@end
