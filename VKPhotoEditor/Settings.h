//
//  Settings.h
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/25/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserProfile.h"

@interface Settings : NSObject
@property (nonatomic, strong, readonly) NSURL *serviceRootURL;

@property (nonatomic, strong) UserProfile *profile;
@property (nonatomic, assign) BOOL firstLaunch;

- (id)initWithDefaults:(NSDictionary*)defs;
- (NSString*)descriptionForErrorKey:(NSString*)errorKey;
- (void)sync;

+ (Settings*)current;
@end