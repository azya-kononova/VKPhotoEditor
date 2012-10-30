//
//  PhotosList.h
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/29/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "VKPhoto.h"

@protocol PhotosListDelegate;

@interface PhotosList : NSObject
@property (nonatomic, assign) id<PhotosListDelegate> delegate;
@property (nonatomic, strong) NSArray *photos;
@property (nonatomic, assign) NSInteger limit;
@property (nonatomic, assign, readonly) BOOL completed;

- (void)reset;
- (void)append:(NSArray*)photos;
- (void)insert:(VKPhoto*)photo;
- (void)deletePhoto:(NSString*)photoId;
- (void)loadNextPageFor:(NSInteger)userId;

- (id)initWithPhotos:(NSArray*)photos;
@end

@protocol PhotosListDelegate
- (void)photosList:(PhotosList*)photosList didUpdatePhotos:(NSArray*)photos;
- (void)photosList:(PhotosList *)photosList didFailToUpdate:(NSError*)error;
@end

