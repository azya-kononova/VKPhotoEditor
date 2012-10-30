//
//  BlurFilterParams.h
//  VKPhotoEditor
//
//  Created by asya on 10/7/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPUImageOutput.h"

@interface BlurFilterParams : NSObject

+ (NSDictionary *)paramsWithFilter:(GPUImageOutput<GPUImageInput>*)filter;
+ (GPUImageOutput<GPUImageInput>*)filterWithParams:(NSDictionary *)params;
+ (GPUImageOutput<GPUImageInput>*)filterWithFilter:(GPUImageOutput<GPUImageInput>*)filter;

@end
