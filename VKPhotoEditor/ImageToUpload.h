//
//  ImageToUpload.h
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 11/3/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageToUpload : NSObject
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *caption;

+ (ImageToUpload*)imageWithImage:(UIImage*)image caption:(NSString*)caption;
@end
