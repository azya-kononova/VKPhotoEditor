//
//  RemoteImageView.h
//  Radario
//
//  Created by Sergey Martynov on 27.01.12.
//  Copyright (c) 2012 vladimir.chernokulsky@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RemoteImage.h"

@interface RemoteImageView : UIView
@property (nonatomic, strong, readonly) RemoteImage *image;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UIView *placeholder;
@property (nonatomic, assign) BOOL isCircular;

- (void)displayImage:(RemoteImage*)imaged;

@end
