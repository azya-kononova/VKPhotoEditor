//
//  GridModes.h
//  VKPhotoEditor
//
//  Created by asya on 12/8/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GridModes : NSObject

@property (nonatomic, assign, readonly) BOOL isGridMode;

- (void)setMode:(BOOL)mode forKey:(NSString *)key;
- (void)switchCurrentModeValue;
- (void)setCurrentModeKey:(NSString *)key;

@end
