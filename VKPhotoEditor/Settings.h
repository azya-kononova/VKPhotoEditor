//
//  Settings.h
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/25/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Settings : NSObject
@property (nonatomic, strong, readonly) NSURL *serviceRootURL;
@property (nonatomic, strong) NSString *login;

- (id)initWithDefaults:(NSDictionary*)defs;

+ (Settings*)current;

- (void)sync;

@end