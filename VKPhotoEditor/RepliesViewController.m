//
//  RepliesViewController.m
//  VKPhotoEditor
//
//  Created by asya on 12/1/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "RepliesViewController.h"
#import "UIView+Helpers.h"
#import "RequestExecutorDelegateAdapter.h"
#import "VKConnectionService.h"
#import "ThumbnailPhotoCell.h"
#import "GridModeButton.h"
#import "UIColor+VKPhotoEditor.h"
#import "FastViewerController.h"
#import "MentionList.h"
#import "ReplyPhotoCell.h"
#import "PhotoCell.h"
#import "RepliesUpdateLoader.h"

@interface RepliesViewController () <UIActionSheetDelegate, GridModeButtonDelegate, ThumbnailPhotoCellDelegate, FastViewerControllerDelegate, PhotoListDelegate, ReplyPhotoCellDelegate, PhotoCellDelegate>
@end

@implementation RepliesViewController {
    MentionList *mentionList;
    RequestExecutorDelegateAdapter *adapter;
    
    BOOL isGridMode;
    BOOL isFastViewerOpen;
    
    NSInteger itemsInRow;
    NSInteger gridCellHeight;
    
    UserProfile *profile;
    NSArray *gridMentionList;
}

@synthesize tableView;
@synthesize tableHeaderView;
@synthesize noPhotosLabel;
@synthesize activityIndicator;
@synthesize delegate;

- (id)initWithProfile:(UserProfile *)_profile
{
    self = [super init];
    if (self) {
        profile = _profile;
        mentionList = [MentionList new];
        mentionList.delegate = self;
        mentionList.account = profile;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    tableView.tableHeaderView = tableHeaderView;
    
    tableView.pullArrowImage = [UIImage imageNamed:@"grayArrow"];
    tableView.pullBackgroundColor = [UIColor blackColor];
    tableView.loadBackgroundColor = [UIColor whiteColor];
    tableView.pullTextColor = [UIColor blackColor];
    
    GridModeButton *gridButton = [GridModeButton loadFromNIB];
    gridButton.delegate = self;
    [gridButton moveTo:CGPointMake(280, 5)];
    [tableHeaderView addSubview:gridButton];
    
    adapter = [[RequestExecutorDelegateAdapter alloc] initWithTarget:self];
    
    ThumbnailPhotoCell *cell = [UITableViewCell loadCellOfType:[ThumbnailPhotoCell class] fromNib:@"ThumbnailPhotoCell" withId:@"ThumbnailPhotoCell"];
    itemsInRow = cell.itemsInRow;
    gridCellHeight = cell.frame.size.height;
}

- (void) viewWillAppear:(BOOL)animated {
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:animated];
    [super viewWillAppear:animated];
    
    //Send -1 for reset badge
    [[NSNotificationCenter defaultCenter] postNotificationName:VKUpdateRepliesBadge object:[NSNumber numberWithInt:-1]];
    [mentionList loadMore];
}

#pragma mark - Internals

- (NSArray *)getPhotosForIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:itemsInRow];
    
    for (int i = 0; i < itemsInRow; i++) {
        int row = itemsInRow * indexPath.row + i;
        if (row < gridMentionList.count) {
            [photos addObject:[gridMentionList objectAtIndex:row]];
        }
    }
    
    return photos;
}

- (NSArray *)getGridPhotos
{
    NSMutableArray *photos = [NSMutableArray array];
    
    for (VKPhoto *photo in mentionList.photos) {
        [self addPhoto:photo to:photos];
    }
    return photos;
}

- (void)addPhoto:(VKPhoto *)photo to:(NSMutableArray *)array
{
    [array addObject:photo];
    
    if (photo.replyToPhoto) {
        [self addPhoto:photo.replyToPhoto to:array];
    }
}

#pragma mark - PhotosListDelegate

- (void)reloadPullTable
{
    activityIndicator.hidden = YES;
    noPhotosLabel.hidden = mentionList.photos.count;
    gridMentionList = [self getGridPhotos];
    
    [tableView reloadData];
    tableView.pullTableIsLoadingMore = NO;
    tableView.pullTableIsRefreshing = NO;
    
    //    [tableView setCompleted:searchResultsList.completed];
}

- (void)photoList:(PhotoList *)photoList didUpdatePhotos:(NSArray *)photos
{
    tableView.pullLastRefreshDate = [NSDate date];
    [self reloadPullTable];
    [mentionList saveSinceValue];
}

- (void)photoList:(PhotoList *)photoList didFailToUpdate:(NSError *)error
{
    [self reloadPullTable];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return isGridMode ? (NSInteger) ceil((double) gridMentionList.count / itemsInRow) : mentionList.photos.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return isGridMode ? gridCellHeight : 366;
}

- (UITableViewCell*)mentionOrReplyForRowAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView*)_tableView
{
    VKPhoto *photo = [mentionList.photos objectAtIndex:indexPath.row];
    if (photo.type == VKPhotoTypeMention) {
        PhotoCell *cell = [PhotoCell dequeOrCreateInTable:_tableView];
        cell.delegate = self;
        [cell displayPhoto:[mentionList.photos objectAtIndex:indexPath.row]];
        
        return cell;
    } else if (photo.type == VKPhotoTypeReply) {
        ReplyPhotoCell *cell = [ReplyPhotoCell dequeOrCreateInTable:_tableView];
        cell.delegate = self;
        [cell displayPhoto:[mentionList.photos objectAtIndex:indexPath.row]];
        
        return cell;
    }
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isGridMode) {
        ThumbnailPhotoCell *cell = [ThumbnailPhotoCell dequeOrCreateInTable:tableView];
        cell.delegate = self;
        [cell displayPhotos:[self getPhotosForIndexPath:indexPath]];
        return cell;
    } else {
        return [self mentionOrReplyForRowAtIndexPath:indexPath tableView:_tableView];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isGridMode) return;
    
    VKPhoto *photo = [mentionList.photos objectAtIndex:indexPath.row];
    [delegate repliesViewController:self didReplyToPhoto:photo];
}


#pragma mark - PullTableViewDelegate

- (void)pullTableViewDidTriggerRefresh:(PullTableView *)pullTableView
{
    [mentionList reset];
    [mentionList loadMore];
}

- (void)pullTableViewDidTriggerLoadMore:(PullTableView *)pullTableView
{
    if (!mentionList.completed) {
        [mentionList loadMore];
    } else {
        [self performSelector:@selector(reloadPullTable) withObject:nil afterDelay:0.2];
    }
}


#pragma mark - GridModeButtonDelegate

- (void)gridModeButtonDidSwitchMode:(GridModeButton *)gridButton
{
    isGridMode = !isGridMode;
    [tableView reloadData];
}

#pragma mark - ThumbnailPhotoCellDelegate

- (void)thumbnailPhotoCell:(ThumbnailPhotoCell *)cell didSelectPhoto:(VKPhoto *)photo
{
    if (!isFastViewerOpen) {
        isFastViewerOpen = YES;
        
        FastViewerController *controller = [[FastViewerController alloc] initWithPhoto:photo];
        controller.delegate = self;
        [delegate repliesViewController:self presenModalViewController:controller animated:YES];
    }
}

#pragma mark - FastViewerControllerDelegate

- (void)fastViewerControllerDidFinish:(FastViewerController *)controller
{
    [delegate repliesViewController:self dismissModalViewController:controller animated:YES];
    isFastViewerOpen = NO;
}

- (void)fastViewerController:(FastViewerController *)controller didFinishWithAccount:(Account *)account
{
    [delegate repliesViewController:self didSelectAccount:account animated:NO];
    [delegate repliesViewController:self dismissModalViewController:controller animated:NO];
    isFastViewerOpen = NO;
}

#pragma mark - PhotoCellDelegate

- (void)photoCell:(PhotoCell *)photoCell didSelectAccount:(Account *)account
{
    [delegate repliesViewController:self didSelectAccount:account animated:YES];
}

- (void)photoCell:(PhotoCell *)photoCell didTapOnPhoto:(VKPhoto *)photo
{
     [delegate repliesViewController:self didReplyToPhoto:photo];
}

- (void)photoCell:(PhotoCell *)photoCell didTapHashTag:(NSString *)hashTag
{
    
}

#pragma mark - ReplyPhotoCellDelegate

- (void)replyPhotoCell:(ReplyPhotoCell *)cell didTapOnAccount:(Account *)account
{
    [delegate repliesViewController:self didSelectAccount:account animated:YES];
}

- (void)replyPhotoCell:(ReplyPhotoCell *)cell didTapOnPhoto:(VKPhoto *)photo
{
    [delegate repliesViewController:self didReplyToPhoto:photo];
}

@end