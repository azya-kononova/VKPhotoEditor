//
//  PhotosList.h
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/29/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "PhotoList.h"
#import "Account.h"
#import "VKPhoto.h"

@protocol PhotosListDelegate;

@interface UserPhotoList : PhotoList

@property (nonatomic, assign) BOOL userPic;

- (id)initWithPhotos:(NSArray*)photos;

- (void)loadPageFor:(Account *)account;
- (void)insert:(VKPhoto*)photo;
- (void)deletePhoto:(NSString*)photoId;
@end
