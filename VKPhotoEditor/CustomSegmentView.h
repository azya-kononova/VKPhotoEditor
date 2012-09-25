//
//  CustomSegmentView.h
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 9/23/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

@protocol CustomSegmentViewDelegate;

@interface CustomSegmentView : UIView
@property (nonatomic, assign) id<CustomSegmentViewDelegate> delegate;
@property (nonatomic, assign) CGSize segmentSize;
@property (nonatomic, strong) UIImage *leftBgImage;
@property (nonatomic, strong) UIImage *leftBgImageSelected;
@property (nonatomic, strong) UIImage *rightBgImage;
@property (nonatomic, strong) UIImage *rightBgImageSelected;
@property (nonatomic, strong) UIImage *bgImage;
@property (nonatomic, strong) UIImage *bgImageSelected;
@property (nonatomic, assign) NSInteger selectedSegmentIndex;

- (void)addItems:(NSArray *)items;
- (void)setFont:(UIFont *)font forSegmentAtIndex:(NSUInteger)segment;
@end

@protocol CustomSegmentViewDelegate <NSObject>
@optional
- (void)segmentView:(CustomSegmentView*)segmentView selectSegmentAtIndex:(NSInteger)index;
@end