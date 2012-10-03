//
//  Filters.m
//  VKPhotoEditor
//
//  Created by asya on 9/23/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "Filters.h"
#import "ImageFilter.h"
#import "GPUImageSepiaFilter.h"
#import "GPUImageGrayscaleFilter.h"
#import "GPUImageEmptyFilter.h"

NSString *SepiaFilterName = @"SepiaFilter";
NSString *DefaultFilterName = @"DefaulFilter";
NSString *GrayscaleFilterName = @"GrayscaleFilter";

@implementation Filters

+ (NSArray *)filters
{
    
    return [NSArray arrayWithObjects: [[ImageFilter alloc] initWithPreviewPath:@"Basic.png" name:DefaultFilterName],
            [[ImageFilter alloc] initWithPreviewPath:@"Filter1.png" name:SepiaFilterName],
            [[ImageFilter alloc] initWithPreviewPath:@"Filter2.png" name:GrayscaleFilterName], nil];
}

+ (GPUImageFilter*)GPUFilterWithName:(NSString*)name
{
    if (name == SepiaFilterName)
        return [GPUImageSepiaFilter new];
    if (name == GrayscaleFilterName)
        return [GPUImageGrayscaleFilter new];
    else
        return [GPUImageEmptyFilter new];
}

@end
