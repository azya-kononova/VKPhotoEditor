//
//  ImageFilter.h
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 9/30/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageFilter : NSObject
@property (nonatomic, strong, readonly) NSString *previewPath;
@property (nonatomic, strong, readonly) NSArray *fragmentShaderPaths;
@property (nonatomic, strong, readonly) NSArray *vertexShaderPaths;

- (id)initWithPreviewPath:(NSString*)previewPath fragmentShaderPaths:(NSArray*)fsPaths vertexShaderPaths:(NSArray*)vsPaths;
@end
