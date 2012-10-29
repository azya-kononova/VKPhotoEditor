//
//  ProfileController.h
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/27/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserAccount.h"

@protocol ProfileControllerDelegate;

@interface ProfileController : UIViewController
@property (nonatomic, assign) id<ProfileControllerDelegate> delegate;
@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

- (id)initWithAccount:(UserAccount*)account;

- (IBAction)openProfile;
@end

@protocol ProfileControllerDelegate
- (void)profileControllerDidOpenProfile:(ProfileController*)ctrl;
@end
