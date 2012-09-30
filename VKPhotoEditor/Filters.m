//
//  Filters.m
//  VKPhotoEditor
//
//  Created by asya on 9/23/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "Filters.h"
#import "ImageFilter.h"

@implementation Filters

+ (NSArray *)filters
{
    NSString *defaultVSPath = [self shaderAt:@"DefaultVertexShader"];
    NSString *defaultFSPath = [self shaderAt:@"DefaultFragmentShader"];
    NSString *overlayFSPath = [self shaderAt:@"OverlayFragmentShader"];
    NSString *overlayVSPath = [self shaderAt:@"OverlayVertexShader"];
    NSString *luminancePath = [self shaderAt:@"LuminanceFragmentShader"];
    NSString *blurFSPath = [self shaderAt:@"BlurFragmentShader"];
    NSString *hBlurVSPath = [self shaderAt:@"HBlurVertexShader"];
    NSString *vBlurVSPath = [self shaderAt:@"VBlurVertexShader"];
    NSString *discretizePath = [self shaderAt:@"DiscretizeShader"];
    NSString *pixelatePath = [self shaderAt:@"PixelateShader"];
    NSString *suckPath = [self shaderAt:@"SuckShader"];
    
    return [NSArray arrayWithObjects: [self filterWithPreview:@"Basic.png" fsPaths:[NSArray arrayWithObject:defaultFSPath] vsPaths:nil],
            [self filterWithPreview:@"Filter1.png" fsPaths:[NSArray arrayWithObject:overlayFSPath] vsPaths:[NSArray arrayWithObject:overlayVSPath]],
            [self filterWithPreview:@"Filter2.png" fsPaths:[NSArray arrayWithObject:suckPath] vsPaths:nil],
            [self filterWithPreview:@"Filter3.png" fsPaths:[NSArray arrayWithObject:pixelatePath] vsPaths:nil],
            [self filterWithPreview:@"Filter4.png" fsPaths:[NSArray arrayWithObject:discretizePath] vsPaths:nil],
            [self filterWithPreview:@"Filter5.png" fsPaths:[NSArray arrayWithObject:luminancePath] vsPaths:nil],
            [self filterWithPreview:@"Filter6.png" fsPaths:[NSArray arrayWithObject:blurFSPath] vsPaths:[NSArray arrayWithObject:hBlurVSPath]],
            [self filterWithPreview:@"Filter7.png" fsPaths:[NSArray arrayWithObjects:blurFSPath, hBlurVSPath, nil] vsPaths:[NSArray arrayWithObjects:vBlurVSPath, hBlurVSPath, nil]],
            [self filterWithPreview:@"Filter8.png" fsPaths:[NSArray arrayWithObjects:luminancePath, blurFSPath, blurFSPath, nil] vsPaths:[NSArray arrayWithObjects:defaultVSPath, vBlurVSPath, hBlurVSPath, nil]], nil];
}

+ (ImageFilter*)filterWithPreview:(NSString*)preview fsPaths:(NSArray*)fsPaths vsPaths:(NSArray*)vsPaths
{
    return [[ImageFilter alloc] initWithPreviewPath:preview fragmentShaderPaths:fsPaths vertexShaderPaths:vsPaths];
}

+ (NSString*)shaderAt:(NSString*)path
{
    return [[NSBundle mainBundle] pathForResource:path ofType:@"glsl"];
}

@end
