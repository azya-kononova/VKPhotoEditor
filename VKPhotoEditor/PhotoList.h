//
//  PhotoList.h
//  VKPhotoEditor
//
//  Created by Kate on 11/27/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "VKConnectionService.h"
#import "VKRequestExecutor.h"

@protocol PhotoListDelegate;

@interface PhotoList : NSObject <VKRequestExecutorDelegate> {
    VKConnectionService *service;
    VKRequestExecutor *exec;
    @protected
    BOOL completed;
}

@property (nonatomic, assign) id<PhotoListDelegate> delegate;
@property (nonatomic, assign, readonly) BOOL completed;
@property (nonatomic, strong) NSArray *photos;
@property (nonatomic, strong) NSMutableDictionary *sectionsInfo;
@property (nonatomic, assign) NSInteger limit;

- (void)reset;
- (void)loadMore;
- (void)append:(NSArray*)photos totalCount:(NSUInteger)totalCount;

- (void)mapData:(id)data;
- (VKRequestExecutor*)newPageExec;

- (NSInteger)numberOfItemsInSection:(NSInteger)section;

- (void)deletePhoto:(NSString *)photoId;

@end

@protocol PhotoListDelegate
- (void)photoList:(PhotoList*)photoList didUpdatePhotos:(NSArray*)photos;
- (void)photoList:(PhotoList *)photoList didFailToUpdate:(NSError*)error;
@end
