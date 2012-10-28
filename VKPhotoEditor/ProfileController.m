//
//  ProfileController.m
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/27/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "ProfileController.h"
#import "PhotoCell.h"
#import "PhotoHeaderView.h"
#import "UITableViewCell+NIB.h"
#import "VKPhoto.h"
#import "UIView+NIB.h"

@interface ProfileController () <UITableViewDataSource, UITableViewDelegate>
@end

@implementation ProfileController {
    UserAccount *account;
    NSMutableArray *photos;
    NSMutableArray *sectionHeaders;
}
@synthesize nameLabel;
@synthesize delegate;

- (id)initWithAccount:(UserAccount *)_account
{
    if (self = [super init]) {
        account = _account;
        photos = account.lastPhotos.mutableCopy;
        sectionHeaders = [NSMutableArray new];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    nameLabel.text = account.account.login;
}

#pragma mark - actions

- (IBAction)openProfile
{
    [delegate profileControllerDidOpenProfile:self];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return photos.count; 
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoCell *cell = [PhotoCell dequeOrCreateInTable:tableView];
    VKPhoto *photo = [photos objectAtIndex:indexPath.section];
    [cell displayPhoto:photo];
    return cell;
}

- (PhotoHeaderView *)dequeueHeader
{
    for (PhotoHeaderView *view in sectionHeaders) {
        if (!view.superview) return view;
    }
    return nil;
}

- (NSString *)sectionHeaderTitleForSection:(NSInteger)section
{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 46.0;
}

- (UIView *)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    PhotoHeaderView* headerView = [self dequeueHeader];
    if (!headerView)
    {
        headerView = [PhotoHeaderView loadFromNIB];
        [sectionHeaders addObject:headerView];
    }
    [headerView displayPhoto:[photos objectAtIndex:section]];
    return headerView;
}

@end
