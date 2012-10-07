//
//  Filters.h
//  VKPhotoEditor
//
//  Created by asya on 9/23/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPUImageEmptyFilter.h"

extern NSString *SepiaFilterName;
extern NSString *DefaultFilterName;
extern NSString *GrayscaleFilterName;

@interface Filters : NSObject

+ (NSArray*)filters;

+ (NSArray*)captionViewTemplates;
+ (GPUImageOutput<GPUImageInput>*)GPUFilterWithName:(NSString*)name;
+ (NSString *)nameWithGPUFilter:(GPUImageOutput<GPUImageInput>*)filter;
@end
