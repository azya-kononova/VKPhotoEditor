//
//  ThumbnailView.h
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 9/23/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ThumbnailsViewDataSource;
@protocol ThumbnailsViewDelegate;

@interface ThumbnailsView : UIView
@property (nonatomic, assign) IBOutlet id<ThumbnailsViewDelegate> delegate;
@property (nonatomic, assign) IBOutlet id<ThumbnailsViewDataSource> dataSource;
@property (nonatomic, assign) CGFloat margin;

@property (nonatomic, strong) UIColor *shadowColor;
@property (nonatomic, assign) CGFloat shadowRadius;
@property (nonatomic, assign) CGSize shadowOffset;

@property (nonatomic, strong) UIColor *highlightBorderColor;
@property (nonatomic, assign) CGFloat highlightBorderWidth;
@property (nonatomic, strong) UIColor *highlightShadowColor;
@property (nonatomic, assign) CGFloat highlightShadowRadius;
@property (nonatomic, assign) CGSize highlightShadowOffset;
@property (nonatomic, assign) CGFloat thumbConrnerRadius;

@property (nonatomic, assign, readonly) NSUInteger displayedItemIndex;
- (void)reloadData;
@end

@protocol ThumbnailsViewDataSource
- (NSUInteger)numberOfItemsInThumbnailsView:(ThumbnailsView*)view;
- (UIView*)thumbnailsView:(ThumbnailsView*)view viewForItemWithIndex:(NSUInteger)index;
- (CGFloat)thumbnailsView:(ThumbnailsView*)view thumbnailWidthForHeight:(CGFloat)height;
@end

@protocol ThumbnailsViewDelegate <NSObject>
- (void)thumbnailsView:(ThumbnailsView *)view didTapOnItemWithIndex:(NSUInteger)index;
@end

