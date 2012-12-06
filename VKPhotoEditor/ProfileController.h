//
//  ProfileController.h
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/27/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "UserProfile.h"
#import "ImageToUpload.h"
#import "RemoteImageView.h"

#import "ProfileBaseController.h"

@interface ProfileController : ProfileBaseController

- (id)initWithProfile:(UserProfile*)profile;
@end

