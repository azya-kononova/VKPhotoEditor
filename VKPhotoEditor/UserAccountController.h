//
//  UserAccountController.h
//  VKPhotoEditor
//
//  Created by Kate on 11/27/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "ProfileBaseController.h"

@interface UserAccountController : ProfileBaseController
@property (nonatomic, strong) IBOutlet FlexibleButton *backButton;

- (IBAction)back:(id)sender;
@end
