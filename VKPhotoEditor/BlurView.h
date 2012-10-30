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

- (id)initWithCenter:(CGPoint)center margin:(CGFloat)margin;

- (void)reloadData;
- (void)show:(BOOL)isShown;

@end

@protocol BlurViewDelegate
- (void)blurView:(BlurView *)view didFinishWithBlurMode:(BlurMode *)mode;
- (void)blurView:(BlurView *)view didChangeBlurRadius:(CGFloat)radius;
@end