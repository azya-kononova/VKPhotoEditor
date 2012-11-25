//
//  VKConnectionService.h
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/23/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserProfile.h"
#import "VKRequestExecutor.h"

extern NSString *VKErrorDomain;
extern NSString *VKRequestDidFailNotification;

@interface VKConnectionService : NSObject

@property (nonatomic, strong, readonly) NSURL *rootURL;
@property (nonatomic, strong, readonly) UserProfile *profile;

+ (VKConnectionService*)shared;

- (id)initWithURL:(NSURL*)url;

- (VKRequestExecutor*)login:(NSString*)login;
- (VKRequestExecutor*)uploadPhoto:(UIImage*)photo withCaption:(NSString*)caption;
- (VKRequestExecutor*)deletePhoto:(NSString*)photoId;
- (VKRequestExecutor*)getPhotos:(NSInteger)userId offset:(NSInteger)offset limit:(NSInteger)limit;
- (VKRequestExecutor*)searchPhotos:(NSString*)query offset:(NSInteger)offset limit:(NSInteger)limit;
- (void)logout;
@end
