//
//  UserAccount.h
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/25/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Account.h"

@interface UserAccount : NSObject
@property (nonatomic, strong) NSString *login;
@property (nonatomic, assign) NSInteger accountId;
@property (nonatomic, strong) NSURL *avatarURL;
@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSArray *lastPhotos;

@property (nonatomic, strong, readonly) RemoteImage *avatar;

+ (id)accountWithDict:(NSDictionary*)dict;
@end
