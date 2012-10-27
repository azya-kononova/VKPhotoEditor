//
//  ProfileController.m
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/27/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "ProfileController.h"
#import "PhotoCell.h"
#import "UITableViewCell+NIB.h"
#import "VKPhoto.h"

@interface ProfileController () <UITableViewDataSource, UITableViewDelegate>
@end

@implementation ProfileController {
    UserAccount *account;
    NSMutableArray *photos;
}
@synthesize nameLabel;

- (id)initWithAccount:(UserAccount *)_account
{
    if (self = [super init]) {
        account = _account;
        photos = account.lastPhotos.mutableCopy;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    nameLabel.text = account.login;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return photos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoCell *cell = [PhotoCell dequeOrCreateInTable:tableView];
    VKPhoto *photo = [photos objectAtIndex:indexPath.row];
    [cell displayPhoto:photo];
    return cell;
}


@end
