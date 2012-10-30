//
//  FiltersManager.m
//  VKPhotoEditor
//
//  Created by asya on 10/30/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "FiltersManager.h"
#import "Filters.h"
#import "ImageFilter.h"
#import "GPUImageTiltShiftFilter.h"
#import "GPUImageGaussianSelectiveBlurFilter.h"

@interface FiltersManager ()
@property (nonatomic, strong) GPUImageOutput<GPUImageInput> *blurFilter;
@property (nonatomic, strong) GPUImageOutput<GPUImageInput> *basicFilter;
@property (nonatomic, strong) GPUImageStillCamera *stillCamera;
@property (nonatomic, strong) GPUImageView *cameraView;
@property (nonatomic, assign) NSInteger filterIndex;
@end


@implementation FiltersManager {
    NSArray *blurTargets;
}

@synthesize basicFilter, blurFilter, cameraView, stillCamera, filterIndex;

FiltersManager *FiltersManagerMake(id basic, id camera, id view)
{
    FiltersManager *manager = [FiltersManager new];
    manager.basicFilter = basic;
    manager.stillCamera = camera;
    manager.cameraView = view;
    
    return manager;
}

- (void)setBasicFilter:(GPUImageOutput<GPUImageInput> *)_basicFilter
{
    basicFilter = _basicFilter;
    blurTargets = basicFilter.targets;
}

- (void)setFilterWithIndex:(NSInteger)index
{
    filterIndex = index;
    ImageFilter *imageFilter = [Filters.filters objectAtIndex:filterIndex];
    GPUImageOutput<GPUImageInput> *filter = [Filters GPUFilterWithName:imageFilter.name];
    [filter addTarget: cameraView];
    [filter prepareForImageCapture];
    
    if (blurFilter) {
        [blurFilter removeAllTargets];
        [blurFilter addTarget:filter];
    } else {
        [basicFilter removeAllTargets];
        [basicFilter addTarget:filter];
    }
    
    blurTargets = [NSArray arrayWithObject:filter];
}

- (void)setBlurFilterWithMode:(BlurMode *)mode
{
    [basicFilter removeAllTargets];
    blurFilter = mode.filter;
    [blurFilter removeAllTargets];
    
    if (blurFilter) {
        for (GPUImageOutput<GPUImageInput> *target in blurTargets) {
            [blurFilter addTarget:target];
        }
        [blurFilter prepareForImageCapture];
        [basicFilter addTarget:blurFilter];
    } else {
        for (GPUImageOutput<GPUImageInput> *target in blurTargets) {
            [basicFilter addTarget:target];
        }
    }
}

- (void)setBlurFilterRadius:(CGFloat)radius
{
    if ([blurFilter isKindOfClass:[GPUImageTiltShiftFilter class]]) {
        [(GPUImageTiltShiftFilter *)blurFilter setTopFocusLevel:radius - 0.1];
        [(GPUImageTiltShiftFilter *)blurFilter setBottomFocusLevel:radius + 0.1];
    }
    if ([blurFilter isKindOfClass:[GPUImageGaussianSelectiveBlurFilter class]]) {
        [(GPUImageGaussianSelectiveBlurFilter *)blurFilter setExcludeCircleRadius:radius];
    }
}

- (CGFloat)calculateBlurFilterRadius:(CGFloat)radius
{
    //TODO: right way to calculate radius
    if ([blurFilter isKindOfClass:[GPUImageGaussianSelectiveBlurFilter class]]) {
        return [(GPUImageGaussianSelectiveBlurFilter *)blurFilter excludeCircleRadius] * radius;
    }
    
    return 0;
}
@end
