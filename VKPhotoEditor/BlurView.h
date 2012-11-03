//
//  BlurView.h
//  VKPhotoEditor
//
//  Created by asya on 10/30/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BlurMode.h"

@protocol BlurViewDelegate;

@interface BlurView : UIView

@property (nonatomic, strong, readonly) UIPinchGestureRecognizer *pinch;
@property (nonatomic, assign, readonly) BOOL isShown;
@property (nonatomic, unsafe_unretained) id<BlurViewDelegate> delegate;
@property (nonatomic, strong, readonly) BlurMode *mode;

- (id)initWithCenter:(CGPoint)center margin:(CGFloat)margin;

- (void)reloadData;
- (void)show:(BOOL)isShown;
- (void)setModeWithFilter:(id)filter;

@end

@protocol BlurViewDelegate
- (void)blurView:(BlurView *)view didFinishWithBlurMode:(BlurMode *)mode blurFilter:(id)filter;
- (void)blurViewDidBeginBlurScaleEditing:(BlurView *)view;
- (void)blurViewDidFinishBlurScaleEditing:(BlurView *)view;
- (void)blurView:(BlurView *)view didChangeBlurScale:(CGFloat)scale;
@end