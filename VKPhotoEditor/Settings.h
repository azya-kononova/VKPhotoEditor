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
@property (nonatomic, assign) NSInteger userId;
@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSURL *avatarURL;
@property (nonatomic, strong) NSString *avatarId;
@property (nonatomic, assign) BOOL firstLaunch;

- (id)initWithDefaults:(NSDictionary*)defs;
- (NSString*)descriptionForErrorKey:(NSString*)errorKey;

+ (Settings*)current;
@end