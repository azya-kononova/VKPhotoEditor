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

#define MIN_BLUR_RADIUS 0.12
#define BLUR_SIZE_STEP 4

typedef void (^GaussianFilterBlock)(GPUImageGaussianSelectiveBlurFilter *gaussian);
typedef void (^TiltShiftFilterBlock)(GPUImageTiltShiftFilter *tiltShift);

@interface FiltersManager ()
@property (nonatomic, strong) GPUImageOutput<GPUImageInput> *blurFilter;
@property (nonatomic, strong) GPUImageOutput<GPUImageInput> *basicFilter;
@property (nonatomic, strong) GPUImageStillCamera *stillCamera;
@property (nonatomic, strong) GPUImageView *cameraView;
@property (nonatomic, assign) NSInteger filterIndex;
@end


@implementation FiltersManager {
    NSArray *blurTargets;
    CGFloat blurRadius;
    CGFloat topFocusLevel;
    CGFloat bottomFocusLevel;
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

- (void)setFilterWithIndex:(NSInteger)index prepare:(PrepareFilter)prerareFilter
{
    filterIndex = index;
    ImageFilter *imageFilter = [Filters.filters objectAtIndex:filterIndex];
    GPUImageOutput<GPUImageInput> *filter = [Filters GPUFilterWithName:imageFilter.name];
    [filter addTarget: cameraView];
    
    if (prerareFilter) {
        prerareFilter(filter);
    }
    
    if (blurFilter) {
        [blurFilter removeAllTargets];
        [blurFilter addTarget:filter];
    } else {
        [basicFilter removeAllTargets];
        [basicFilter addTarget:filter];
    }
    
    blurTargets = [NSArray arrayWithObject:filter];
}

- (void)setBlurFilterWithMode:(BlurMode *)mode prepare:(PrepareFilter)prerareFilter
{
    [self setBlurFilterWithFilter:mode.filter prepare:prerareFilter];
}

- (void)setBlurFilterWithFilter:(GPUImageOutput<GPUImageInput> *)filter prepare:(PrepareFilter)prerareFilter
{
    [basicFilter removeAllTargets];
    blurFilter = filter;
    [blurFilter removeAllTargets];
    
    if (blurFilter) {
        for (GPUImageOutput<GPUImageInput> *target in blurTargets) {
            [blurFilter addTarget:target];
        }
        if (prerareFilter) {
            prerareFilter(blurFilter);
        }
        [basicFilter addTarget:blurFilter];
    } else {
        for (GPUImageOutput<GPUImageInput> *target in blurTargets) {
            [basicFilter addTarget:target];
        }
    }
}

- (void)setBlurFilterScale:(CGFloat)scale
{
    [self executeGaussianFilterBlock:^(GPUImageGaussianSelectiveBlurFilter *gaussian) {
        CGFloat radius = blurRadius * scale;
        [gaussian setExcludeCircleRadius:radius < MIN_BLUR_RADIUS ? MIN_BLUR_RADIUS : radius];
    } tiltShiftFilterBlock:^(GPUImageTiltShiftFilter *filter) {
        if ((bottomFocusLevel * scale - topFocusLevel / scale) > 0) {
            [filter setTopFocusLevel:topFocusLevel / scale];
            [filter setBottomFocusLevel:bottomFocusLevel * scale];
        }
    }];
}

- (void)beginBlurScaleEditing
{
    [self executeGaussianFilterBlock:^(GPUImageGaussianSelectiveBlurFilter *gaussian) {
        gaussian.blurSize += BLUR_SIZE_STEP;
        blurRadius = gaussian.excludeCircleRadius;
    } tiltShiftFilterBlock:^(GPUImageTiltShiftFilter *filter) {
        filter.blurSize += BLUR_SIZE_STEP;
        topFocusLevel = filter.topFocusLevel;
        bottomFocusLevel = filter.bottomFocusLevel;
    }];
}

- (void)finishBlurScaleEditing
{
    [self executeGaussianFilterBlock:^(GPUImageGaussianSelectiveBlurFilter *gaussian) {
        gaussian.blurSize -= BLUR_SIZE_STEP;
    } tiltShiftFilterBlock:^(GPUImageTiltShiftFilter *filter) {
        filter.blurSize -= BLUR_SIZE_STEP;
    }];
}

- (void)executeGaussianFilterBlock:(GaussianFilterBlock)gaussianBlock tiltShiftFilterBlock:(TiltShiftFilterBlock)tiltShiftBlock
{
    if ([blurFilter isKindOfClass:[GPUImageTiltShiftFilter class]]) {
        GPUImageTiltShiftFilter *filter = (GPUImageTiltShiftFilter*)blurFilter;
        tiltShiftBlock(filter);
    }
    if ([blurFilter isKindOfClass:[GPUImageGaussianSelectiveBlurFilter class]]) {
        GPUImageGaussianSelectiveBlurFilter *gaussian = (GPUImageGaussianSelectiveBlurFilter *)blurFilter;
        gaussianBlock(gaussian);
    }
}

@end
