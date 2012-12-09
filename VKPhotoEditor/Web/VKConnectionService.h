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
#import "ImageToUpload.h"

extern NSString *VKRequestDidInfoUpdateNotification;
extern NSString *VKRequestDidFailNotification;
extern NSString *VKRequestDidUpdateAvatarNotification;
extern NSString *VKRequestDidLogin;
extern NSString *VKRequestDidLogout;

@interface VKConnectionService : NSObject

@property (nonatomic, strong, readonly) NSURL *rootURL;
@property (nonatomic, strong, readonly) UserProfile *profile;
@property (nonatomic, strong) NSString *replySince;

+ (VKConnectionService*)shared;

- (id)initWithURL:(NSURL*)url;

- (VKRequestExecutor*)login:(NSString*)login;
- (VKRequestExecutor*)uploadPhoto:(ImageToUpload *)image;
- (VKRequestExecutor*)deletePhoto:(NSString*)photoId;
- (VKRequestExecutor*)getPhotos:(NSInteger)userId offset:(NSInteger)offset limit:(NSInteger)limit userPic:(BOOL)userPic;
- (VKRequestExecutor*)searchPhotos:(NSString*)query offset:(NSInteger)offset limit:(NSInteger)limit;
- (VKRequestExecutor*)getMentions:(NSInteger)userId since:(NSString*)since after:(NSString*)after limit:(NSInteger)limit;
- (VKRequestExecutor*)getHistory:(NSString*)photoId limit:(NSInteger)limit;
- (VKRequestExecutor*)followUser:(NSInteger)userId;
- (VKRequestExecutor*)unfollowUser:(NSInteger)userId;
- (VKRequestExecutor*)getUsers:(NSArray*)users;
- (VKRequestExecutor*)getUser:(NSInteger)userId;
- (VKRequestExecutor*)updateUserPic:(NSString*)pictureId;
- (VKRequestExecutor*)getNewsfeedSince:(NSString*)since after:(NSString*)after limit:(NSInteger)limit;
- (VKRequestExecutor*)getFollowers:(NSInteger)accountId offset:(NSInteger)offset limit:(NSInteger)limit filter:(NSString*)filter;
- (VKRequestExecutor*)blockUser:(NSInteger)userId;
- (VKRequestExecutor*)unblockUser:(NSInteger)userId;
- (VKRequestExecutor*)registerDevice:(NSString*)token sandbox:(BOOL)sanbox;
- (void)logout;
@end
