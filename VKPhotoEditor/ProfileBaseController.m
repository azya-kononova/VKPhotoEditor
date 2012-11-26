//
//  ProfileBaseController.m
//  VKPhotoEditor
//
//  Created by Kate on 11/26/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "ProfileBaseController.h"
#import "PhotoCell.h"
#import "AvatarView.h"
#import "UIView+Helpers.h"
#import "RequestExecutorDelegateAdapter.h"
#import "VKConnectionService.h"
#import "PhotoHeaderCell.h"
#import "UITableViewCell+NIB.h"

@interface ProfileBaseController () <PhotoCellDelegate, UIActionSheetDelegate, PhotosListDelegate>
@end

@implementation ProfileBaseController{
    UserProfile *profile;
    RequestExecutorDelegateAdapter *adapter;
    VKConnectionService *service;
    NSInteger selectedPhoto;
    NSMutableDictionary *avatarsForIndexes;
}
@synthesize photosTableView;
@synthesize delegate;
@synthesize noPhotoLabel;

@synthesize avatarTheaterView;
@synthesize headerView;
@synthesize nameLabel;
@synthesize centralButton;
@synthesize headerTopView;
@synthesize headerBottomView;
@synthesize noAvatarImageView;
@synthesize profile;

@synthesize photosList;
@synthesize avatarsList;

- (id)initWithProfile:(UserProfile *)_profile
{
    if (self = [super init]) {
        profile = _profile;
        photosList = [profile isKindOfClass:UserProfile.class] ? [[UserPhotosList alloc] initWithPhotos:_profile.lastPhotos] : [UserPhotosList new];
        photosList.delegate = self;
        avatarsList = [UserPhotosList new];
        avatarsList.delegate = self;
        avatarsForIndexes = [NSMutableDictionary new];
        service = [VKConnectionService shared];
        selectedPhoto = -1;
        adapter = [[RequestExecutorDelegateAdapter alloc] initWithTarget:self];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self showAvatar:profile.avatar animated:NO];
    
    centralButton.bgImagecaps = CGSizeMake(23, 0);
    
    nameLabel.text = profile.login;
    
    photosTableView.tableHeaderView = headerView;
    photosTableView.pullArrowImage = [UIImage imageNamed:@"grayArrow"];
    photosTableView.pullBackgroundColor = [UIColor blackColor];
    photosTableView.pullTextColor = [UIColor blackColor];
    
    [photosList loadNextPageFor:profile.accountId];
    [avatarsList loadNextPageFor:profile.accountId userPic:YES];
    [avatarTheaterView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        [delegate profileBaseControllerDidBack:self];
    }
}

- (void)showAvatar:(RemoteImage*)avatar animated:(BOOL)animated;
{
    BOOL show = YES;
    avatarTheaterView.hidden = !show;
    [photosTableView beginUpdates];
    CGFloat newHeight = headerTopView.frame.size.height + headerBottomView.frame.size.height + (show ? avatarTheaterView.frame.size.height : noAvatarImageView.frame.size.height);
    if (animated)
        [UIView animateWithDuration:0.8 delay:0 options: UIViewAnimationCurveEaseOut animations:^{
            [headerView resizeTo:CGSizeMake(headerView.frame.size.height, newHeight)];
        } completion:^(BOOL finished) {}];
    else
        [headerView resizeTo:CGSizeMake(headerView.frame.size.height, newHeight)];
    [photosTableView endUpdates];
    photosTableView.tableHeaderView = headerView;
}

#pragma mark - PhotosListDelegate

- (void)reloadPullTable
{
    noPhotoLabel.hidden = photosList.photos.count;
    [photosTableView reloadData];
    photosTableView.pullTableIsLoadingMore = NO;
    photosTableView.pullTableIsRefreshing = NO;
}

- (void)photosList:(UserPhotosList *)_photosList didUpdatePhotos:(NSArray *)photos
{
    if (_photosList == photosList) {
        photosTableView.pullLastRefreshDate = [NSDate date];
        [self reloadPullTable];
    } else {
        [avatarTheaterView reloadData];
    }
}

- (void)photosList:(UserPhotosList *)_photosList didFailToUpdate:(NSError *)error
{
    (_photosList ==  photosList) ? [self reloadPullTable] :  [avatarTheaterView reloadData];
}

#pragma mark - Request Handler

- (void)exec:(VKRequestExecutor*)exec didDeletePhoto:(id)ids
{
    if ([ids count]) [photosList deletePhoto:[ids objectAtIndex:0]];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return photosList.photos.count * 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.row % 2 == 0) ? 46 : 320;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row % 2 == 0) {
        PhotoHeaderCell *cell = [PhotoHeaderCell dequeOrCreateInTable:photosTableView];
        [cell displayPhoto:[photosList.photos objectAtIndex:indexPath.row / 2]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType =  UITableViewCellAccessoryNone;
        return cell;
    } else {
        PhotoCell *cell = [PhotoCell dequeOrCreateInTable:tableView];
        cell.delegate = self;
        VKPhoto *photo = [photosList.photos objectAtIndex:(indexPath.row - 1) / 2];
        [cell displayPhoto:photo];
        return cell;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row % 2 == 0) return;
    
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
    } else if (buttonIndex == 1) {
        VKPhoto *photo = [photosList.photos objectAtIndex:selectedPhoto];
        if (photo.photo.image) {
            UIImageWriteToSavedPhotosAlbum( photo.photo.image , self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        }
    }
    selectedPhoto = -1;
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
}

#pragma mark - PhotoCellDelegate

- (void)photoCell:(PhotoCell *)photoCell didTapHashTag:(NSString *)hashTag
{
    [delegate profileBaseController:self didTapHashTag:hashTag];
}

#pragma mark - PullTableViewDelegate

- (void)pullTableViewDidTriggerRefresh:(PullTableView *)pullTableView
{
    noPhotoLabel.hidden = YES;
    [photosList reset];
    [photosList loadNextPageFor:profile.accountId];
}

- (void)pullTableViewDidTriggerLoadMore:(PullTableView *)pullTableView
{
    [photosList loadNextPageFor:profile.accountId];
}

- (NSUInteger)numberOfItemsInTheaterView:(TheaterView*)view
{
    return avatarsList.photos.count;
}

- (UIView*)theaterView:(TheaterView*)view viewForItemWithIndex:(NSUInteger)index
{
    AvatarView *viewForIndex =  [avatarsForIndexes objectForKey:[NSNumber numberWithInteger:index]];
    if (!viewForIndex) {
        viewForIndex = [AvatarView loadFromNIB];
        [viewForIndex displayPhoto:[avatarsList.photos objectAtIndex:index]];
        [avatarsForIndexes setObject:viewForIndex forKey:[NSNumber numberWithInteger:index]];
    }
    return viewForIndex;
}

@end
