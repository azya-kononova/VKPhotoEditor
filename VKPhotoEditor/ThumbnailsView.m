//
//  ThumbnailView.m
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 9/23/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "ThumbnailsView.h"
#import "NSArray+Creation.h"

@interface ThumbnailsView () <UIScrollViewDelegate>
@property (nonatomic, strong, readonly) UIScrollView *scroll;
@end

@implementation ThumbnailsView {
    NSMutableArray *views;
    UITapGestureRecognizer *tapRecognizer;
    CGFloat thumbnailHeight;
    CGFloat thumbnailWidth;
}
@synthesize scroll = _scroll;
@synthesize dataSource;
@synthesize margin;
@synthesize displayedItemIndex;
@synthesize delegate;
@synthesize highlightBorderColor;
@synthesize highlightBorderWidth;
@synthesize highlightShadowColor;
@synthesize highlightShadowRadius;
@synthesize highlightShadowOffset;
@synthesize thumbConrnerRadius;

- (void)_init
{
    margin = 10;
    highlightBorderColor = [UIColor whiteColor];
    highlightBorderWidth = 3.0f;
    highlightShadowColor = [UIColor colorWithRed:230./255 green:230./255 blue:230./255 alpha:1];
    highlightShadowRadius = 3.0;
    highlightShadowOffset = CGSizeMake(0,0);
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnView)];
}

- (void)didTapOnView
{
    NSInteger index = [tapRecognizer locationInView:_scroll].x / (thumbnailWidth + margin);
    if (index > views.count - 1) return;
    [delegate thumbnailsView:self didTapOnItemWithIndex:index];
    [self setView:[views objectAtIndex:displayedItemIndex] highlighted:NO];
    displayedItemIndex = index;
    [self setView:[views objectAtIndex:displayedItemIndex] highlighted:YES];
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
        _scroll.pagingEnabled = NO;
        _scroll.clipsToBounds = YES;
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
        CGRect frame = CGRectMake(margin + (thumbnailWidth + margin) * i, margin, thumbnailWidth, thumbnailHeight);
        UIView *thumb = [dataSource thumbnailsView:self viewForItemWithIndex:i];
        thumb.layer.masksToBounds = YES;
        thumb.layer.cornerRadius = thumbConrnerRadius;
        
        UIView* containerView = [[UIView alloc] initWithFrame:frame];
        thumb.frame = containerView.bounds;
        [containerView addSubview:thumb];
        
        if (i ==  displayedItemIndex) [self setView:containerView highlighted:YES];

        [self.scroll addSubview:containerView];
        [arr addObject:containerView];
    }
    views = arr.copy;
    
    CGFloat contentWidth = margin + (thumbnailWidth + margin) * count;
    self.scroll.frame = self.bounds;
    self.scroll.contentSize = CGSizeMake(fmaxf(self.bounds.size.width + 1, contentWidth), self.bounds.size.height);
}

- (void)setView:(UIView*)containerView highlighted:(BOOL)highlighted
{
    UIView *contentView = [containerView.subviews objectAtIndex:0];
    if (highlighted) {
        contentView.layer.borderColor = highlightBorderColor.CGColor;
        contentView.layer.borderWidth = highlightBorderWidth;
        containerView.layer.shadowColor = highlightShadowColor.CGColor;
        containerView.layer.shadowRadius = highlightShadowRadius;
        containerView.layer.shadowOffset = highlightShadowOffset;
        containerView.layer.shadowOpacity = 1;
        
    } else {
        contentView.layer.borderWidth = 0;
        containerView.layer.shadowRadius = 0;
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
