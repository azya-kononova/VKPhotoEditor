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
@property (nonatomic, strong) NSString *replyToUser;
@property (nonatomic, strong) NSString *replyToPhoto;
@property (nonatomic, assign) NSNumber *replyToFeed;
@property (nonatomic, assign, readonly) BOOL isAvatar;

ImageToUpload *ImageToUploadMake(UIImage *image, NSString *caption, NSString *replyToUser, NSString *replyToPhoto, NSNumber *replyToFeed);

@end
