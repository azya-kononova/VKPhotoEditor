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
    NSInteger initialOffset;
    VKConnectionService *service;
    NSInteger nextPage;
    VKRequestExecutor *exec;
    NSInteger limit;
}

@property (nonatomic, assign) id<PhotoListDelegate> delegate;
@property (nonatomic, assign, readonly) BOOL completed;
@property (nonatomic, strong) NSArray *photos;

- (void)reset;
- (void)loadMore;
- (void)append:(NSArray*)photos totalCount:(NSUInteger)totalCount;

- (void)mapData:(id)data;
- (VKRequestExecutor*)newPageExec;
@end

@protocol PhotoListDelegate
- (void)photoList:(PhotoList*)photoList didUpdatePhotos:(NSArray*)photos;
- (void)photoList:(PhotoList *)photoList didFailToUpdate:(NSError*)error;
@end
