//
//  ProfileBaseController.m
//  VKPhotoEditor
//
//  Created by Kate on 11/26/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "ProfileBaseController.h"
#import "PhotoCell.h"
#import "PhotoView.h"
#import "UIView+Helpers.h"
#import "VKConnectionService.h"
#import "UITableViewCell+NIB.h"
#import "CALayer+Animations.h"
#import "NSArray+Helpers.h"

@interface ProfileBaseController () <PhotoCellDelegate, UIActionSheetDelegate, PhotoListDelegate>
@end

@implementation ProfileBaseController{
    UserProfile *profile;
    NSInteger selectedPhoto;
    NSMutableDictionary *avatarsForIndexes;
    ProfileModeState mode;
    BOOL avatarsLoaded;
    BOOL infoLoaded;
}
@synthesize photosTableView;
@synthesize delegate;
@synthesize noPhotoLabel;
@synthesize loadingView;

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
@synthesize photosLabelCount;
@synthesize mentionsLabelCount;
@synthesize followersLabelCount;

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
    
    photosTableView.tableHeaderView = headerTopView;
    photosTableView.pullArrowImage = [UIImage imageNamed:@"grayArrow"];
    photosTableView.pullBackgroundColor = [UIColor blackColor];
    photosTableView.loadBackgroundColor = [UIColor whiteColor];
    photosTableView.pullTextColor = [UIColor blackColor];
    
    [photosList loadMore];
    [avatarsList loadMore];
    
    UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressOnTable:)];
    recognizer.minimumPressDuration = 2.0;
    [photosTableView addGestureRecognizer:recognizer];
    
//    [adapter start:[service getUser:self.profile.accountId] onSuccess:@selector(exec:didGetUser:) onError:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        [delegate profileBaseControllerDidBack:self];
    }
}

- (void)showContent
{
    if (infoLoaded && avatarsLoaded) {
        loadingView.hidden = YES;
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

- (void)reloadAvatarList
{
    avatarsForIndexes = nil;
    [avatarsList reset];
    [avatarsList loadMore];
}

- (void)reloadAvatar;
{
    [avatarTheaterView reloadData];
    
    photosTableView.tableHeaderView = nil;
    [headerTopView removeFromSuperview];
    [headerView addSubview:headerTopView];
    
    if (followedByMe) {
        photosTableView.tableHeaderView = headerBottomView;
        return;
    }
    
    BOOL show = avatarsList.photos.count != 0;
    [avatarActivity stopAnimating];
    noAvatarLabel.hidden = show;
    
    if (show == !avatarTheaterView.hidden) return;
    
    [avatarTheaterView.layer fade];
    avatarTheaterView.hidden = !show;
    CGFloat newHeight = headerTopView.frame.size.height + headerBottomView.frame.size.height + (show ? avatarTheaterView.frame.size.height : noAvatarImageView.frame.size.height);
    [headerView resizeTo:CGSizeMake(headerView.frame.size.width, newHeight)];
    
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
        [self reloadAvatar];
        if (!avatarsLoaded) {
            avatarsLoaded = YES;
            [self showContent];
        } 
    }
}

- (void)photoList:(PhotoList *)photoList didFailToUpdate:(NSError *)error
{
    (photoList ==  sourceList) ? [self reloadPullTable] : [self reloadAvatar];
}

#pragma mark - Request Handler

- (void)exec:(VKRequestExecutor*)exec didDeletePhoto:(id)ids
{
    if ([ids count]) [photosList deletePhoto:[ids objectAtIndex:0]];
}

- (void)exec:(VKRequestExecutor*)exec didGetUser:(id)data
{
    NSDictionary *userInfo = [[data objectForKey:@"users_info"] objectAtIndex:0];
    photosLabelCount.text = [[userInfo objectForKey:@"photos_count"] stringValue];
    mentionsLabelCount.text = [[userInfo objectForKey:@"mentions_count"] stringValue];
    followersLabelCount.text = [[userInfo objectForKey:@"followers_count"] stringValue];
    
    NSArray *connections = [userInfo objectForKey:@"connections"];
    followedByMe = [connections find:^BOOL (NSString* string) { return [string isEqualToString:@"following"]; }] != nil;
    
    if (!infoLoaded) {
        infoLoaded = YES;
        [self showContent];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return sourceList.photos.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 366;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoCell *cell = [PhotoCell dequeOrCreateInTable:tableView];
    cell.delegate = self;
    VKPhoto *photo = [sourceList.photos objectAtIndex:indexPath.row ];
    [cell displayPhoto:photo canSelectAccount:NO];
    return cell;
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

- (void)photoCell:(PhotoCell *)photoCell didSelectAccount:(Account *)account
{
    
}

- (void)photoCell:(PhotoCell *)photoCell didTapOnPhoto:(VKPhoto *)photo
{
    [delegate profileBaseController:self didReplyToPhoto:photo];
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
    PhotoView *viewForIndex =  [avatarsForIndexes objectForKey:[NSNumber numberWithInteger:index]];
    if (!viewForIndex) {
        viewForIndex = [PhotoView loadFromNIB];
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
