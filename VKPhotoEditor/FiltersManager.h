//
//  FiltersManager.h
//  VKPhotoEditor
//
//  Created by asya on 10/30/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPUImageOutput.h"
#import "GPUImageStillCamera.h"
#import "GPUImageView.h"
#import "BlurMode.h"

@interface FiltersManager : NSObject

@property (nonatomic, strong, readonly) GPUImageOutput<GPUImageInput> *blurFilter;
@property (nonatomic, strong, readonly) GPUImageOutput<GPUImageInput> *basicFilter;
@property (nonatomic, strong, readonly) GPUImageStillCamera *stillCamera;
@property (nonatomic, strong, readonly) GPUImageView *cameraView;
@property (nonatomic, assign, readonly) NSInteger filterIndex;

- (void)setFilterWithIndex:(NSInteger)index;
- (void)setBlurFilterWithMode:(BlurMode *)mode;
- (void)setBlurFilterRadius:(CGFloat)radius;

FiltersManager *FiltersManagerMake(id basic, id camera, id view);

@end
