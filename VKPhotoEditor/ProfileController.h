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

// upload view
@property (nonatomic, strong) IBOutlet UIView *uploadingContainerView;
@property (nonatomic, strong) IBOutlet UIView *uploadingView;
@property (nonatomic, strong) IBOutlet UIImageView *uploadingImageView;
@property (nonatomic, strong) IBOutlet UILabel *uploadInfoLabel;

- (id)initWithProfile:(UserProfile*)profile;
- (void)uploadImage:(ImageToUpload*)image;
@end

