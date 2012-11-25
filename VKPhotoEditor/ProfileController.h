//
//  ProfileController.h
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/27/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "UserProfile.h"
#import "PullTableView.h"
#import "ImageToUpload.h"
#import "FlexibleButton.h"
#import "RemoteImageView.h"

@protocol ProfileControllerDelegate;

@interface ProfileController : UIViewController
@property (nonatomic, assign) id<ProfileControllerDelegate> delegate;
@property (nonatomic, strong) IBOutlet PullTableView *tableView;

// header view
@property (nonatomic, strong) IBOutlet UIView *headerView;
@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet FlexibleButton *setPhotoButton;
@property (nonatomic, strong) IBOutlet RemoteImageView *avatarView;
@property (nonatomic, strong) IBOutlet UIView *headerTopView;
@property (nonatomic, strong) IBOutlet UIView *headerBottomView;
@property (nonatomic, strong) IBOutlet UIImageView *noAvatarImageView;

// upload view
@property (nonatomic, strong) IBOutlet UIView *uploadingContainerView;
@property (nonatomic, strong) IBOutlet UIView *uploadingView;
@property (nonatomic, strong) IBOutlet UIImageView *uploadingImageView;
@property (nonatomic, strong) IBOutlet UILabel *uploadInfoLabel;
@property (nonatomic, strong) IBOutlet UILabel *noPhotoLabel;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *savingIndicator;

- (id)initWithProfile:(UserProfile*)profile;
- (void)uploadImage:(ImageToUpload*)image;
- (IBAction)openProfile;
@end

@protocol ProfileControllerDelegate
- (void)profileControllerDidOpenProfile:(ProfileController*)ctrl;
- (void)profileControllerDidBack:(ProfileController*)ctrl;
- (void)profileController:(ProfileController*)ctrl didTapHashTag:(NSString*)hashTag;
@end
