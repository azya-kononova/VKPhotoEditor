//
//  RequestExecutorDelegateApadter.h
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/29/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "VKRequestExecutor.h"

@protocol RequestExecutorDelegateAdapterDelegate;

@interface RequestExecutorDelegateAdapter : NSObject <VKRequestExecutorDelegate>
@property (nonatomic, assign) id<RequestExecutorDelegateAdapterDelegate> delegate;
@property (nonatomic, assign, readonly) id target;
@property (nonatomic, assign, readonly) BOOL completed;

- (id)initWithTarget:(id)target;

- (void)start:(VKRequestExecutor*)exec onSuccess:(SEL)success onError:(SEL)error;
- (void)stopAll;

@end

@protocol RequestExecutorDelegateAdapterDelegate

- (void)adapter:(RequestExecutorDelegateAdapter*)adapter didStartRequest:(VKRequestExecutor*)executor;

- (void)adapterDidCompleteAll:(RequestExecutorDelegateAdapter*)adapter;

@end
