//
//  RemoteImageView.h
//  Radario
//
//  Created by Sergey Martynov on 27.01.12.
//  Copyright (c) 2012 vladimir.chernokulsky@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RemoteImage.h"

@protocol RemoteImageViewDelegate;

@interface RemoteImageView : UIView
@property (nonatomic, assign) IBOutlet id<RemoteImageViewDelegate> delegate;
@property (nonatomic, strong, readonly) RemoteImage *image;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UIView *placeholder;
@property (nonatomic, assign) BOOL isCircular;
@property (nonatomic, strong) IBOutlet UIView *progressView;

- (void)displayImage:(RemoteImage*)imaged;

@end

@protocol RemoteImageViewDelegate <NSObject>
@optional
- (void)remoteImageView:(RemoteImageView*)view didLoadImage:(UIImage*)image;
@end