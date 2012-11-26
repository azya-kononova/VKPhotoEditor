//
//  TheaterView.m
//  FeedReader
//
//  Created by Sergey Martynov on 29.11.11.
//  Copyright (c) 2011 StudioMobile. All rights reserved.
//

#import "TheaterView.h"

@interface TheaterView () <UIScrollViewDelegate>
@property (nonatomic, strong, readonly) UIScrollView *scroll;
@end

@implementation TheaterView {
    NSMutableArray *views;
    struct {
        unsigned int delegateRespondsToDidScroll : 1;
    } flags;
}
@synthesize scroll = _scroll;
@synthesize dataSource;
@synthesize delegate;
@synthesize displayedItemIndex;
@synthesize previousDisplayedItemIndex;

- (void)setDelegate:(id<TheaterViewDelegate>)_delegate
{
    delegate = _delegate;
    flags.delegateRespondsToDidScroll = [delegate respondsToSelector:@selector(theaterView:didScrollToItemWithIndex:)];
}

- (UIScrollView*)scroll
{
    if (!_scroll) {
        _scroll = [UIScrollView new];
        _scroll.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _scroll.backgroundColor = [UIColor clearColor];
        _scroll.frame = self.bounds;
        _scroll.delegate = self;
        _scroll.showsHorizontalScrollIndicator = NO;
        _scroll.showsVerticalScrollIndicator = NO;
        _scroll.pagingEnabled = YES;
        _scroll.bounces = NO;
        [self addSubview:_scroll];
    }
    return _scroll;
}

- (BOOL)scrollEnabled
{
    return self.scroll.scrollEnabled;
}

- (void)setScrollEnabled:(BOOL)scrollEnabled
{
    self.scroll.scrollEnabled = scrollEnabled;
}

- (NSMutableArray*)nulls:(NSUInteger)count
{
    NSNull *null = [NSNull null];
    NSMutableArray *nulls = [[NSMutableArray alloc] initWithCapacity:count];
    for (NSUInteger i = 0; i < count; ++i) {
        [nulls addObject:null];
    }
    return nulls;
}

- (void)reloadData
{
    NSUInteger count = [dataSource numberOfItemsInTheaterView:self];
    CGSize sSize = self.scroll.frame.size;

    for (UIView *view in views) {
        if ((id)view == [NSNull null]) continue;
        [view removeFromSuperview];
    }
    views = [self nulls:count];
    displayedItemIndex = MIN(displayedItemIndex, count-1);

    [self displayItemAtIndex:displayedItemIndex animated:NO];
    
    self.scroll.contentSize = CGSizeMake(sSize.width * count, sSize.height);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGSize sSize = self.scroll.frame.size;
    for (NSUInteger i = 0; i < views.count; ++i) {
        UIView *view = [views objectAtIndex:i];
        if ((id)view == [NSNull null]) continue;
        view.frame = CGRectMake(sSize.width * i, 0, sSize.width, sSize.height);
    }
}

- (UIView*)viewForItemWithIndex:(NSUInteger)index
{
    return [dataSource theaterView:self viewForItemWithIndex:index];
}

- (void)updatePage:(NSUInteger)index
{
    NSUInteger tail = 1;
    NSUInteger start = MIN(index > tail ? index-tail : 0, views.count);
    NSUInteger end = MIN(index+tail, views.count);

    NSMutableIndexSet *idxSet = [NSMutableIndexSet new];
    [idxSet addIndexesInRange:NSMakeRange(0, start)];
    [idxSet addIndexesInRange:NSMakeRange(end, views.count - end)];
    NSMutableIndexSet *toClean = [NSMutableIndexSet new];
    [views enumerateObjectsAtIndexes:idxSet options:0 usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (obj == [NSNull null]) return;
        [(UIView*)obj removeFromSuperview];
        [toClean addIndex:idx];
    }];
    [views replaceObjectsAtIndexes:toClean withObjects:[self nulls:toClean.count]];

    CGSize sSize = self.scroll.frame.size;
    for (NSUInteger i = start; i < end; ++i) {
        UIView *view = [views objectAtIndex:i];
        if ((id)view != [NSNull null]) continue;
        view = [self viewForItemWithIndex:i];
        view.frame = CGRectMake(sSize.width * i, 0, sSize.width, sSize.height);
        [views replaceObjectAtIndex:i withObject:view];
        [self.scroll addSubview:view];
    }
}

- (void)currentPageChanged
{ 
    previousDisplayedItemIndex = displayedItemIndex;
    displayedItemIndex = self.scroll.contentOffset.x / self.scroll.frame.size.width;
    [self updatePage:displayedItemIndex];
    if (flags.delegateRespondsToDidScroll) {
        [delegate theaterView:self didScrollToItemWithIndex:displayedItemIndex];
    }
}

- (void)displayItemAtIndex:(NSUInteger)index animated:(BOOL)animated
{
    CGFloat offsetX = self.scroll.frame.size.width * index;
    [self.scroll setContentOffset:CGPointMake(offsetX, 0) animated:animated];
    if (!animated) {
        [self currentPageChanged];
    }
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pages = self.scroll.contentOffset.x / self.scroll.frame.size.width;
    CGFloat index = pages;
    if (pages - (NSUInteger)pages > 0) ++index;
    [self updatePage:index];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self currentPageChanged];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self currentPageChanged];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self currentPageChanged];
}

@end
