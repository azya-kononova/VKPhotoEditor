//
//  ProfileController.h
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/27/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserProfile.h"
#import "FlexibleButton.h"
#import "PullTableView.h"

@protocol ProfileControllerDelegate;

@interface ProfileController : UIViewController
@property (nonatomic, assign) id<ProfileControllerDelegate> delegate;
@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet PullTableView *tableView;
@property (nonatomic, strong) IBOutlet UIView *titleView;

- (id)initWithAccount:(UserProfile*)account;
- (void)uploadImage:(UIImage*)image;
- (IBAction)openProfile;
@end

@protocol ProfileControllerDelegate
- (void)profileControllerDidOpenProfile:(ProfileController*)ctrl;
- (void)profileControllerDidBack:(ProfileController*)ctrl;
- (void)profileController:(ProfileController*)ctrl didTapHashTag:(NSString*)hashTag;
@end
