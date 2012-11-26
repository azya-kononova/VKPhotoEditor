//
//  PhotosList.h
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/29/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "VKPhoto.h"

@protocol PhotosListDelegate;

@interface UserPhotosList : NSObject
@property (nonatomic, assign) id<PhotosListDelegate> delegate;
@property (nonatomic, strong) NSArray *photos;
@property (nonatomic, assign) NSInteger limit;
@property (nonatomic, assign, readonly) BOOL completed;

- (void)reset;
- (void)insert:(VKPhoto*)photo;
- (void)deletePhoto:(NSString*)photoId;
- (void)loadNextPageFor:(NSInteger)userId;
- (void)loadNextPageFor:(NSInteger)userId userPic:(BOOL)userPic;

- (id)initWithPhotos:(NSArray*)photos;
@end

@protocol PhotosListDelegate
- (void)photosList:(UserPhotosList*)photosList didUpdatePhotos:(NSArray*)photos;
- (void)photosList:(UserPhotosList *)photosList didFailToUpdate:(NSError*)error;
@end

