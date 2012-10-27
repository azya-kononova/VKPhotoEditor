//
//  RequestExecutorProxy.h
//  VK
//
//  Created by Sergey Martynov on 06.02.12.
//  Copyright (c) 2012 vladimir.chernokulsky@gmail.com. All rights reserved.
//

#import "VKRequestExecutor.h"

@interface RequestExecutorProxy : VKRequestExecutor <VKRequestExecutorDelegate>
@property (nonatomic, assign) id target;
@property (nonatomic, assign) SEL onSuccess;
@property (nonatomic, assign) SEL onError;
@end
