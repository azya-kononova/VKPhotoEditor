//
//  ProfileController.h
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/27/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserAccount.h"

@interface ProfileController : UIViewController
@property (nonatomic, strong) IBOutlet UILabel *nameLabel;

- (id)initWithAccount:(UserAccount*)account;
@end
