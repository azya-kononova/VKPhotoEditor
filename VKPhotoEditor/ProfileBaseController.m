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
#import "CALayer+Animations.h"

@interface ProfileBaseController () <PhotoCellDelegate, UIActionSheetDelegate, PhotoListDelegate>
@end

@implementation ProfileBaseController{
    UserProfile *profile;
    RequestExecutorDelegateAdapter *adapter;
    VKConnectionService *service;
    NSInteger selectedPhoto;
    NSMutableDictionary *avatarsForIndexes;
    ProfileModeState mode;
    BOOL notLoaded;
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
@synthesize state;
@synthesize avatarActivity;
@synthesize noAvatarLabel;

@synthesize sourceList;
@synthesize photosList;
@synthesize avatarsList;
@synthesize followersList;
@synthesize mentionsList;

- (id)initWithProfile:(UserProfile *)_profile
{
    if (self = [super init]) {
        profile = _profile;
        photosList = [profile isKindOfClass:UserProfile.class] ? [[UserPhotoList alloc] initWithPhotos:_profile.lastPhotos] : [UserPhotoList new];
        photosList.delegate = self;
        photosList.account = profile;
        
        avatarsList = [UserPhotoList new];
        avatarsList.delegate = self;
        avatarsList.userPic = YES;
        avatarsList.account = profile;
        
        mentionsList = [MentionList new];
        mentionsList.account = profile;
        mentionsList.delegate = self;
        
        avatarsForIndexes = [NSMutableDictionary new];
        service = [VKConnectionService shared];
        selectedPhoto = -1;
        adapter = [[RequestExecutorDelegateAdapter alloc] initWithTarget:self];
        sourceList = photosList;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    centralButton.bgImagecaps = CGSizeMake(23, 0);
    
    nameLabel.text = profile.login;
    
    photosTableView.tableHeaderView = headerView;
    photosTableView.pullArrowImage = [UIImage imageNamed:@"grayArrow"];
    photosTableView.pullBackgroundColor = [UIColor blackColor];
    photosTableView.loadBackgroundColor = [UIColor whiteColor];
    photosTableView.pullTextColor = [UIColor blackColor];
    
    [photosList loadMore];
    
    UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressOnTable:)];
    recognizer.minimumPressDuration = 2.0;
    [photosTableView addGestureRecognizer:recognizer];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!notLoaded) {
        [avatarsList loadMore];
        notLoaded = YES;
    }
}

- (void)setState:(ProfileModeState)_state
{
    state = _state;
    switch (state) {
        case ProfilePhotosMode:
            sourceList = photosList;
            break;
        case ProfileFollowersMode:
            sourceList = followersList;
            break;
        case ProfileMentionsMode:
            sourceList = mentionsList;
            break;
        default:
            break;
    }
    if (sourceList.photos.count == 0) {
        [sourceList reset];
        [sourceList loadMore];
    }
    [photosTableView reloadData];
}


- (void)viewWillDisappear:(BOOL)animated
{
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        [delegate profileBaseControllerDidBack:self];
    }
}

- (void)reloadAvatarList
{
    avatarsForIndexes = nil;
    [avatarsList reset];
    [avatarsList loadMore];
}

- (void)reloadAvatarAnimated:(BOOL)animated;
{
    [avatarTheaterView reloadData];
    
    BOOL show = avatarsList.photos.count != 0;
    [avatarActivity stopAnimating];
    noAvatarLabel.hidden = show;
    
    if (show == !avatarTheaterView.hidden) return;
    
    [avatarTheaterView.layer fade];
    avatarTheaterView.hidden = !show;
    
    [photosTableView beginUpdates];
    CGFloat newHeight = headerTopView.frame.size.height + headerBottomView.frame.size.height + (show ? avatarTheaterView.frame.size.height : noAvatarImageView.frame.size.height);
    if (animated)
        [UIView animateWithDuration:0.3 delay:0 options: UIViewAnimationCurveEaseOut animations:^{
            [headerView resizeTo:CGSizeMake(headerView.frame.size.height, newHeight)];
        } completion:^(BOOL finished) {  }];
    else
        [headerView resizeTo:CGSizeMake(headerView.frame.size.height, newHeight)];
    [photosTableView endUpdates];
    photosTableView.tableHeaderView = headerView;
}

#pragma mark - Actions

- (IBAction)rightOptionSelected
{
    self.state = ProfileMentionsMode;
}

- (IBAction)leftOptionSelected
{
    self.state = ProfilePhotosMode;
}

#pragma mark - PhotoListDelegate

- (void)reloadPullTable
{
    noPhotoLabel.hidden = sourceList.photos.count;
    [photosTableView reloadData];
    photosTableView.pullTableIsLoadingMore = NO;
    photosTableView.pullTableIsRefreshing = NO;
}

- (void)photoList:(PhotoList *)photoList didUpdatePhotos:(NSArray *)photos
{
    if (photoList == sourceList) {
        photosTableView.pullLastRefreshDate = [NSDate date];
        [self reloadPullTable];
    } else {
        [self reloadAvatarAnimated:YES];
    }
}

- (void)photoList:(PhotoList *)photoList didFailToUpdate:(NSError *)error
{
    (photoList ==  sourceList) ? [self reloadPullTable] :  [self reloadAvatarAnimated:YES];
}

#pragma mark - Request Handler

- (void)exec:(VKRequestExecutor*)exec didDeletePhoto:(id)ids
{
    if ([ids count]) [photosList deletePhoto:[ids objectAtIndex:0]];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return sourceList.photos.count * 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.row % 2 == 0) ? 46 : 320;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row % 2 == 0) {
        PhotoHeaderCell *cell = [PhotoHeaderCell dequeOrCreateInTable:photosTableView];
        [cell displayPhoto:[sourceList.photos objectAtIndex:indexPath.row / 2]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType =  UITableViewCellAccessoryNone;
        return cell;
    } else {
        PhotoCell *cell = [PhotoCell dequeOrCreateInTable:tableView];
        cell.delegate = self;
        VKPhoto *photo = [sourceList.photos objectAtIndex:(indexPath.row - 1) / 2];
        [cell displayPhoto:photo];
        return cell;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row % 2 == 0) return;
    
    VKPhoto *photo = [sourceList.photos objectAtIndex:(indexPath.row - 1) / 2];
    [delegate profileBaseController:self didReplyToPhoto:photo];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0 && sourceList == photosList) {
        VKPhoto *photo = [sourceList.photos objectAtIndex:selectedPhoto];
        [adapter start:[service deletePhoto:photo.photoId] onSuccess:@selector(exec: didDeletePhoto:) onError:@selector(exec: didFailWithError:)];
    } else if (buttonIndex == 1) {
        VKPhoto *photo = [sourceList.photos objectAtIndex:selectedPhoto];
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
    [sourceList reset];
    [sourceList loadMore];
}

- (void)pullTableViewDidTriggerLoadMore:(PullTableView *)pullTableView
{
    [sourceList loadMore];
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

#pragma mark - UILongPressGestureRecognizer

-(void)handleLongPressOnTable:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state != UIGestureRecognizerStateBegan) return;
    
    CGPoint point = [recognizer locationInView:photosTableView];
    NSIndexPath *indexPath = [photosTableView indexPathForRowAtPoint:point];
    
    if (indexPath) {
        if (indexPath.row % 2 == 0) return;
        
        selectedPhoto = (indexPath.row - 1) / 2;
        UIActionSheet *actSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                              delegate:self
                                                     cancelButtonTitle:@"Cancel"
                                                destructiveButtonTitle:@"Delete Image"
                                                     otherButtonTitles:@"Save Image",nil];
        actSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        [actSheet showInView:self.view.superview];
    }
}

@end
