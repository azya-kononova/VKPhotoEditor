//
//  ProfileController.h
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/27/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "UserProfile.h"
#import "RemoteImageButton.h"
#import "PullTableView.h"
#import "ImageToUpload.h"

@protocol ProfileControllerDelegate;

@interface ProfileController : UIViewController
@property (nonatomic, assign) id<ProfileControllerDelegate> delegate;
@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet PullTableView *tableView;
@property (nonatomic, strong) IBOutlet UIView *titleView;
@property (nonatomic, strong) IBOutlet RemoteImageButton *avatarButton;
@property (nonatomic, strong) IBOutlet UIView *addAvatarView;

@property (nonatomic, strong) IBOutlet UIView *uploadingContainerView;
@property (nonatomic, strong) IBOutlet UIView *uploadingView;
@property (nonatomic, strong) IBOutlet UIImageView *uploadingImageView;
@property (nonatomic, strong) IBOutlet UILabel *uploadInfoLabel;
@property (nonatomic, strong) IBOutlet UILabel *noPhotoLabel;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *savingIndicator;

- (id)initWithAccount:(UserProfile*)account;
- (void)uploadImage:(ImageToUpload*)image;
- (IBAction)openProfile;
@end

@protocol ProfileControllerDelegate
- (void)profileControllerDidOpenProfile:(ProfileController*)ctrl;
- (void)profileControllerDidBack:(ProfileController*)ctrl;
- (void)profileController:(ProfileController*)ctrl didTapHashTag:(NSString*)hashTag;
@end
