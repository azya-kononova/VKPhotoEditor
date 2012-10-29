//
//  VKRequestExecutor.h
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/23/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import <Foundation/Foundation.h>

extern const NSString* VKRequestExecutorErrorDomain;

@protocol VKRequestExecutorDelegate;

@interface VKRequestExecutor : NSObject
@property (nonatomic, strong, readonly) NSURLRequest *request;
@property (nonatomic, assign) id<VKRequestExecutorDelegate> delegate;
@property (nonatomic, assign, readonly) BOOL isFinished;

- (id)initWithRequest:(NSURLRequest*)request;

- (void)start;
- (void)stop;

@end


@protocol VKRequestExecutorDelegate
- (void)VKRequestExecutor:(VKRequestExecutor*)executor didFinishWithObject:(id)value;
- (void)VKRequestExecutor:(VKRequestExecutor*)executor didFailedWithError:(NSError*)error;
@end

