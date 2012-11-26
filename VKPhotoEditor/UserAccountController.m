//
//  UserAccountController.m
//  VKPhotoEditor
//
//  Created by Kate on 11/27/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "UserAccountController.h"

@interface UserAccountController ()
@end

@implementation UserAccountController
@synthesize backButton;

- (id)initWithProfile:(UserProfile *)_profile
{
    if (self = [super initWithProfile:_profile]) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    backButton.bgImagecaps = CGSizeMake(15, 0);
}

#pragma mark - actions

- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
