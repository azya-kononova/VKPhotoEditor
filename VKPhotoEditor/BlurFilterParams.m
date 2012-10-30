//
//  BlurFilterParams.m
//  VKPhotoEditor
//
//  Created by asya on 10/7/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "BlurFilterParams.h"
#import "Filters.h"
#import "GPUImageFilterGroup.h"

#define FILTER_NAME @"filterName"
#define BLUR_SIZE @"blurSize"
#define CIRCLE_RADIUS @"excludeCircleRadius"
#define TOP_FOCUS_LEVEL @"topFocusLevel"
#define BOTTOM_FOCUS_LEVEL @"bottomFocusLevel"

#define SET_PARAMS_FROM_FILTER(filter, params, key) { if ([filter respondsToSelector:NSSelectorFromString(key)]) [params setValue:[filter valueForKey:key] forKey:key]; }
#define SET_FILTER_PARAMS(filter, params, key) { if ([filter respondsToSelector:NSSelectorFromString(key)]) [filter setValue:[params objectForKey:key] forKey:key]; }

@implementation BlurFilterParams

+ (NSDictionary *)paramsWithFilter:(GPUImageOutput<GPUImageInput> *)filter
{
    if (!filter) return nil;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:[Filters nameWithGPUFilter:filter] forKey:FILTER_NAME];
    
    SET_PARAMS_FROM_FILTER(filter, params, BLUR_SIZE);
    SET_PARAMS_FROM_FILTER(filter, params, CIRCLE_RADIUS);
    SET_PARAMS_FROM_FILTER(filter, params, TOP_FOCUS_LEVEL);
    SET_PARAMS_FROM_FILTER(filter, params, BOTTOM_FOCUS_LEVEL);
    
    return params;
}

+ (GPUImageOutput<GPUImageInput>*)filterWithParams:(NSDictionary *)params
{
    if (!params) return nil;
    
    NSString *filterName = [params objectForKey:FILTER_NAME];
    GPUImageOutput<GPUImageInput> *filter = [Filters GPUFilterWithName:filterName];
    
    SET_FILTER_PARAMS(filter, params, BLUR_SIZE);
    SET_FILTER_PARAMS(filter, params, CIRCLE_RADIUS);
    SET_FILTER_PARAMS(filter, params, TOP_FOCUS_LEVEL);
    SET_FILTER_PARAMS(filter, params, BOTTOM_FOCUS_LEVEL);
    
    return filter;
}

+ (GPUImageOutput<GPUImageInput>*)filterWithFilter:(GPUImageOutput<GPUImageInput> *)filter
{
    return [self filterWithParams:[self paramsWithFilter:filter]];
}

@end
