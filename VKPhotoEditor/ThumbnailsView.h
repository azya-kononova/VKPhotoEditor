//
//  ThumbnailView.h
//  Mascotte
//
//  Created by Developer on 12/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ThumbnailsViewDataSource;
@protocol ThumbnailsViewDelegate;

@interface ThumbnailsView : UIView
@property (nonatomic, assign) IBOutlet id<ThumbnailsViewDelegate> delegate;
@property (nonatomic, assign) IBOutlet id<ThumbnailsViewDataSource> dataSource;
@property (nonatomic, assign) CGFloat margin;
@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, assign) CGFloat borderWidth;
@property (nonatomic, assign, readonly) NSUInteger displayedItemIndex;
@property (nonatomic, assign) BOOL enablePaging;
@property (nonatomic, assign) BOOL clip;
@property (nonatomic, assign) BOOL useManualScroll;
@property (nonatomic, assign) BOOL shouldCenterizeContent;

- (void)displayItemAtIndex:(NSUInteger)index animated:(BOOL)animated;
- (void)reloadData;
@end

@protocol ThumbnailsViewDataSource
- (NSUInteger)numberOfItemsInThumbnailsView:(ThumbnailsView*)view;
- (UIView*)thumbnailsView:(ThumbnailsView*)view viewForItemWithIndex:(NSUInteger)index;
- (CGFloat)thumbnailsView:(ThumbnailsView*)view thumbnailWidthForHeight:(CGFloat)height;
@end

@protocol ThumbnailsViewDelegate <NSObject>
@optional
- (void)thumbnailsView:(ThumbnailsView*)view didScrollToItemWithIndex:(NSUInteger)index;
- (void)thumbnailsView:(ThumbnailsView *)view didTapOnItemWithIndex:(NSUInteger)index;
@end

