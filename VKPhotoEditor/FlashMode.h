//
//  FlashMode.h
//  VKPhotoEditor
//
//  Created by asya on 10/4/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlashMode : NSObject

@property (nonatomic, strong, readonly) UIImage *image;
@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, assign, readonly) NSInteger mode;

FlashMode *MakeFlashMode(NSInteger mode, NSString *name, NSString *imageName);

@end
