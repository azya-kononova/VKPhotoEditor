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
#import "VKConnectionService.h"
#import "VKRequestExecutor.h"

@interface ProfileController () <UITableViewDataSource, UITableViewDelegate, PhotosListDelegate, UIActionSheetDelegate>
@end

@implementation ProfileController {
    UserAccount *account;
    PhotosList *photosList;
    NSMutableArray *sectionHeaders;
    RequestExecutorDelegateAdapter *adapter;
    NSInteger offset;
    VKConnectionService *service;
    NSInteger selectedPhoto;
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
        service = [VKConnectionService shared];
        adapter = [[RequestExecutorDelegateAdapter alloc] initWithTarget:self];
        
        selectedPhoto = -1;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    nameLabel.text = account.login;
}

- (void)uploadImage:(UIImage *)image
{
    [adapter start:[service uploadPhoto:image withCaption:@"test"] onSuccess:@selector(exec:didUploadPhoto:) onError:@selector(exec:didFailToUpload:)];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
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

#pragma mark - Request Handler

//TODO: show result with row animation???

- (void)exec:(VKRequestExecutor*)exec didUploadPhoto:(id)value
{
    VKPhoto *photo = [VKPhoto VKPhotoWithDict:[value objectForKey:@"photo"]];
    photo.account = [Account accountWithDict:[[value objectForKey:@"users"] objectAtIndex:0]];
    photo.justUploaded = YES;
    [photosList insert:photo];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)exec:(VKRequestExecutor*)exec didDeletePhoto:(id)ids
{
    if ([ids count]) [photosList deletePhoto:[ids objectAtIndex:0]];
}

- (void)exec:(VKRequestExecutor*)exec didFailWithError:(NSError*)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
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
    return indexPath.section == photosList.photos.count ? 41 : 320;
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
    if (section == photosList.photos.count) return nil;
    
    PhotoHeaderView* headerView = [self dequeueHeader];
    if (!headerView)
    {
        headerView = [PhotoHeaderView loadFromNIB];
        [sectionHeaders addObject:headerView];
    }
    [headerView displayPhoto:[photosList.photos objectAtIndex:section]];
    return headerView;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedPhoto = indexPath.section;
    UIActionSheet *actSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                          delegate:self
                                                 cancelButtonTitle:@"Cancel"
                                            destructiveButtonTitle:@"Delete Image"
                                                 otherButtonTitles:@"Save Image",nil];
    actSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actSheet showInView:self.view.superview];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        VKPhoto *photo = [photosList.photos objectAtIndex:selectedPhoto];
        [adapter start:[service deletePhoto:photo.photoId] onSuccess:@selector(exec: didDeletePhoto:) onError:@selector(exec: didFailWithError:)];
    } else {
        selectedPhoto = -1;
    }
}

@end
