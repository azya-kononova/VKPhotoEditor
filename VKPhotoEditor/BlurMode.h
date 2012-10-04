//
//  BlurMode.h
//  VKPhotoEditor
//
//  Created by asya on 10/4/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BlurMode : NSObject

@property (nonatomic, strong, readonly) UIImage *image;
@property (nonatomic, strong, readonly) UIImage *iconImage;
@property (nonatomic, assign, readonly) NSInteger mode;

BlurMode *MakeBlurMode(NSInteger mode, NSString *imageName, NSString *iconImageName);

@end
