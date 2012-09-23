//
//  ThumbnailView.m
//  FeedReader
//
//  Created by Sergey Martynov on 29.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ThumbnailsView.h"
#import "NSArray+Creation.h"

@interface ThumbnailsView () <UIScrollViewDelegate>
@property (nonatomic, strong, readonly) UIScrollView *scroll;

- (void)centerizeContent:(BOOL)centerize contentWidth:(CGFloat)contentWidth;
@end

@implementation ThumbnailsView {
    NSMutableArray *views;
    struct {
        unsigned int delegateRespondsToDidScroll : 1;
        unsigned int delegateRespondsToDidTap : 1;
    } flags;
    UITapGestureRecognizer *tapRecognizer;
    CGFloat thumbnailHeight;
    CGFloat thumbnailWidth;
}
@synthesize scroll = _scroll;
@synthesize dataSource;
@synthesize margin;
@synthesize displayedItemIndex;
@synthesize enablePaging;
@synthesize clip;
@synthesize useManualScroll;
@synthesize delegate;
@synthesize shouldCenterizeContent;
@synthesize borderColor;
@synthesize borderWidth;

- (void)_init
{
    margin = 10;
    borderColor = [UIColor whiteColor];
    borderWidth = 4.0f;
    enablePaging = NO;
    clip = YES;
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnView)];
}

- (void)setDelegate:(id<ThumbnailsViewDelegate>)_delegate
{
    delegate = _delegate;
    flags.delegateRespondsToDidScroll = [delegate respondsToSelector:@selector(thumbnailsView:didScrollToItemWithIndex:)];
    flags.delegateRespondsToDidTap = [delegate respondsToSelector:@selector(thumbnailsView:didTapOnItemWithIndex:)];
}

- (void)didTapOnView
{
    if (flags.delegateRespondsToDidTap) {
        NSInteger index = [tapRecognizer locationInView:_scroll].x / (thumbnailWidth + margin);
        if (index > views.count - 1) return;
        [delegate thumbnailsView:self didTapOnItemWithIndex:index];
    }
}

- (UIScrollView*)scroll
{
    if (!_scroll) {
        _scroll = [UIScrollView new];
        _scroll.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _scroll.backgroundColor = [UIColor clearColor];
        _scroll.frame = self.bounds;
        _scroll.showsHorizontalScrollIndicator = NO;
        _scroll.showsVerticalScrollIndicator = NO;
        _scroll.pagingEnabled = enablePaging;
        _scroll.clipsToBounds = clip;
        _scroll.delegate = self;
        [_scroll addGestureRecognizer:tapRecognizer];
        [self addSubview:_scroll];
    }
    return _scroll;
}

- (void)reloadData
{
    NSUInteger count = [dataSource numberOfItemsInThumbnailsView:self];
    
    for (UIView *view in views) {
        [view removeFromSuperview];
    }
    
    thumbnailHeight = self.bounds.size.height - margin*2;
    thumbnailWidth = roundf([dataSource thumbnailsView:self thumbnailWidthForHeight:thumbnailHeight]);
    self.scroll.contentOffset = CGPointZero;
    
    NSMutableArray *arr = [NSMutableArray new];
    
    for (NSUInteger i = 0; i < count; ++i) {
        UIView *thumb = [dataSource thumbnailsView:self viewForItemWithIndex:i];
        
        CGRect frame = CGRectMake(margin + (thumbnailWidth + margin) * i, margin, thumbnailWidth, thumbnailHeight);
        thumb.frame = frame;
       
        thumb.layer.masksToBounds = NO;
        thumb.layer.borderColor = borderColor.CGColor;
        thumb.layer.borderWidth = borderWidth;
        thumb.layer.shadowColor = [UIColor colorWithRed:230./255 green:230./255 blue:230./255 alpha:1].CGColor;
        thumb.layer.ShadowOpacity = 1;
        thumb.layer.ShadowRadius = 4.0;
        thumb.layer.ShadowOffset = CGSizeMake(0,0);

        [self.scroll addSubview:thumb];        
        
        [arr addObject:thumb];
    }
    
    views = [arr copy];
    
    CGFloat contentWidth = margin + (thumbnailWidth + margin) * count;
    [self centerizeContent:shouldCenterizeContent contentWidth:contentWidth];
    
    [self displayItemAtIndex:displayedItemIndex animated:NO];
}

- (void)displayItemAtIndex:(NSUInteger)index animated:(BOOL)animated
{
    if (index >= views.count) return;
    
    CGRect scrollFrame = self.scroll.frame;
    CGRect itemFrame = [[views objectAtIndex:index] frame];
    
    CGFloat contentOffsetX = CGRectGetMidX(itemFrame) - CGRectGetMidX(scrollFrame);
    CGFloat maxOffset = self.scroll.contentSize.width - scrollFrame.size.width;
    contentOffsetX = fmaxf(0, fminf(maxOffset, contentOffsetX));
    
    [self.scroll setContentOffset:CGPointMake(contentOffsetX, 0) animated:animated];
    displayedItemIndex = index;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (useManualScroll) {
        NSUInteger index = scrollView.contentOffset.x / CGRectGetWidth(scrollView.frame);
        [self displayItemAtIndex:index animated:NO];
        if (flags.delegateRespondsToDidScroll) {
            [delegate thumbnailsView:self didScrollToItemWithIndex:displayedItemIndex];
        }
    }
}

- (void)centerizeContent:(BOOL)centerize contentWidth:(CGFloat)contentWidth
{
    if (centerize && CGRectGetWidth(self.frame) > contentWidth) {
        CGRect scrollFrame = self.scroll.frame;
        scrollFrame.size.width = contentWidth;
        scrollFrame.origin.x = (CGRectGetWidth(self.frame) - CGRectGetWidth(scrollFrame)) / 2.0;
        self.scroll.frame = scrollFrame;
        
        self.scroll.contentSize = CGSizeMake(self.scroll.bounds.size.width + 1, self.bounds.size.height);
        self.scroll.clipsToBounds = NO;
    }
    else {
        self.scroll.frame = self.bounds;
        self.scroll.contentSize = CGSizeMake(fmaxf(self.bounds.size.width + 1, contentWidth), self.bounds.size.height);
        self.scroll.clipsToBounds = clip;
    }
}

#pragma mark Lifecycle

- (id)init
{
    self = [super init];
    if (self) {
        [self _init];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _init];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self _init];
}

@end
