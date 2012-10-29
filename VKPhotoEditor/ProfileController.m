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
#import "RequestExecutorDelegateAdapter.h"
#import "PhotosList.h"
#import "LoadingCell.h"

@interface ProfileController () <UITableViewDataSource, UITableViewDelegate, PhotosListDelegate>
@end

@implementation ProfileController {
    UserAccount *account;
    PhotosList *photosList;
    NSMutableArray *sectionHeaders;
    RequestExecutorDelegateAdapter *adapter;
    NSInteger offset;
}

@synthesize nameLabel;
@synthesize delegate;
@synthesize tableView;

- (id)initWithAccount:(UserAccount *)_account
{
    if (self = [super init]) {
        account = _account;
        photosList = [[PhotosList alloc] initWithPhotos:account.lastPhotos];
        photosList.delegate = self;
        sectionHeaders = [NSMutableArray new];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    nameLabel.text = account.login;
}

#pragma mark - actions

- (IBAction)openProfile
{
    [delegate profileControllerDidOpenProfile:self];
}

#pragma mark - PhotosListDelegate

- (void)photosList:(PhotosList *)photosList didUpdatePhotos:(NSArray *)photos
{
    [tableView reloadData];
}

- (void)photosList:(PhotosList *)photosList didFailToUpdate:(NSError *)error
{
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return photosList.photos.count + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == photosList.photos.count) {
        return photosList.completed ? 0 : 1;
    }
    return 1;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section == photosList.photos.count ? 28 : 320;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == photosList.photos.count) {
        [photosList loadNextPageFor:account.accountId];
        return [LoadingCell dequeOrCreateInTable:tableView];
    }
    PhotoCell *cell = [PhotoCell dequeOrCreateInTable:tableView];
    VKPhoto *photo = [photosList.photos objectAtIndex:indexPath.section];
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
    return (section == photosList.photos.count) ? 0 : 46.0;
}

- (UIView *)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    PhotoHeaderView* headerView = [self dequeueHeader];
    if (!headerView)
    {
        headerView = [PhotoHeaderView loadFromNIB];
        [sectionHeaders addObject:headerView];
    }
    [headerView displayPhoto:[photosList.photos objectAtIndex:section]];
    return headerView;
}

@end
