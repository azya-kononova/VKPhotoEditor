//
//  TheaterView.h
//  FeedReader
//
//  Created by Sergey Martynov on 29.11.11.
//  Copyright (c) 2011 StudioMobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TheaterViewDataSource;
@protocol TheaterViewDelegate;

@interface TheaterView : UIView
@property (nonatomic, unsafe_unretained) IBOutlet id<TheaterViewDataSource> dataSource;
@property (nonatomic, unsafe_unretained) IBOutlet id<TheaterViewDelegate> delegate;
@property (nonatomic, readonly) NSUInteger displayedItemIndex;
@property (nonatomic, assign) BOOL scrollEnabled;
@property (nonatomic, assign, readonly) NSUInteger previousDisplayedItemIndex;

- (void)reloadData;

- (void)displayItemAtIndex:(NSUInteger)index animated:(BOOL)animated;

@end


@protocol TheaterViewDataSource
- (NSUInteger)numberOfItemsInTheaterView:(TheaterView*)view;
- (UIView*)theaterView:(TheaterView*)view viewForItemWithIndex:(NSUInteger)index;
@end


@protocol TheaterViewDelegate <NSObject>
@optional
- (void)theaterView:(TheaterView*)view didScrollToItemWithIndex:(NSUInteger)index;
@end
