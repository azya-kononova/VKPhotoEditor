//
//  Filters.m
//  VKPhotoEditor
//
//  Created by asya on 9/23/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "Filters.h"
#import "ImageFilter.h"
#import "GPUImage.h"

NSString *MonochromeFilterName = @"MonochromeFilter";
NSString *DefaultFilterName = @"DefaulFilter";
NSString *GrayscaleFilterName = @"GrayscaleFilter";
NSString *VignetteFilterName = @"VignetteFilter";
NSString *KuwaharaFilterName = @"KuwaharaFilter";
NSString *HazeFilterName = @"HazeFilter";
NSString *SharpenFilterName = @"SharpenFilter";
NSString *SaturationFilterName = @"SaturationFilter";
NSString *ContrastFilterName = @"ContrastFilter";
NSString *ToonFilterName = @"ToonFilter";

@implementation Filters

+ (NSArray *)filters
{
    
    return [NSArray arrayWithObjects: [[ImageFilter alloc] initWithPreviewPath:@"Basic.png" name:DefaultFilterName],
            [[ImageFilter alloc] initWithPreviewPath:@"Filter1.png" name:MonochromeFilterName],
            [[ImageFilter alloc] initWithPreviewPath:@"Filter2.png" name:GrayscaleFilterName],
            [[ImageFilter alloc] initWithPreviewPath:@"Filter3.png" name:VignetteFilterName],
            [[ImageFilter alloc] initWithPreviewPath:@"Filter4.png" name:HazeFilterName],
            [[ImageFilter alloc] initWithPreviewPath:@"Filter5.png" name:SharpenFilterName],
            [[ImageFilter alloc] initWithPreviewPath:@"Filter6.png" name:SaturationFilterName],
            [[ImageFilter alloc] initWithPreviewPath:@"Filter7.png" name:ContrastFilterName],
            [[ImageFilter alloc] initWithPreviewPath:@"Filter8.png" name:ToonFilterName], nil];
}

+ (GPUImageFilter*)GPUFilterWithName:(NSString*)name
{
    if (name == MonochromeFilterName)
        return [GPUImageMonochromeFilter new];
    if (name == GrayscaleFilterName)
        return [GPUImageGrayscaleFilter new];
    if (name == VignetteFilterName) {
        GPUImageFilter *filter = [GPUImageVignetteFilter new];
        [(GPUImageVignetteFilter *)filter setVignetteStart:0.1];
        return filter;
    }
    if (name == KuwaharaFilterName)
        return [GPUImageKuwaharaFilter new];
    if (name == HazeFilterName)
        return [GPUImageHazeFilter new];
    if (name == SharpenFilterName) {
        GPUImageFilter *filter = [GPUImageSharpenFilter new];
        [(GPUImageSharpenFilter *)filter setSharpness:2.0];
        return filter;
    }
    if (name == SaturationFilterName) {
        GPUImageFilter *filter = [GPUImageSaturationFilter new];
        [(GPUImageSaturationFilter*)filter setSaturation:1.8];
        return filter;
    }
    if (name == ContrastFilterName) {
        GPUImageFilter *filter = [GPUImageContrastFilter new];
        [(GPUImageContrastFilter *)filter setContrast:2.7];
        return filter;
    }
    if (name == ToonFilterName) {
        GPUImageFilter *filter = [GPUImageToonFilter new];
        [(GPUImageToonFilter *)filter setQuantizationLevels:5];
        return filter;
    }
    else
        return [GPUImageEmptyFilter new];
}

@end
