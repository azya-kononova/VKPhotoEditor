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
#import "VKPhoto.h"
#import "MentionList.h"
#import "MentionPhotoCell.h"
#import "ReplyPhotoCell.h"

@interface RepliesViewController () <UIActionSheetDelegate, GridModeButtonDelegate, ThumbnailPhotoCellDelegate, FastViewerControllerDelegate, PhotoListDelegate, MentionPhotoCellDelegate>
@end

@implementation RepliesViewController {
    MentionList *mentionList;
    RequestExecutorDelegateAdapter *adapter;
    
    BOOL isGridMode;
    BOOL isFastViewerOpen;
    
    NSInteger itemsInRow;
    NSInteger gridCellHeight;
    
    UserProfile *profile;
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
    
    [mentionList loadMore];
    
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
}

#pragma mark - Internals

- (NSArray *)getPhotosForIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:itemsInRow];
    
    for (int i = 0; i < itemsInRow; i++) {
        int row = itemsInRow * indexPath.row + i;
        if (row < mentionList.photos.count) {
            [photos addObject:[mentionList.photos objectAtIndex:row]];
        }
    }
    
    return photos;
}

#pragma mark - PhotosListDelegate

- (void)reloadPullTable
{
    activityIndicator.hidden = YES;
    noPhotosLabel.hidden = mentionList.photos.count;
    
    [tableView reloadData];
    tableView.pullTableIsLoadingMore = NO;
    tableView.pullTableIsRefreshing = NO;
    
    //    [tableView setCompleted:searchResultsList.completed];
}

- (void)photoList:(PhotoList *)photoList didUpdatePhotos:(NSArray *)photos
{
    tableView.pullLastRefreshDate = [NSDate date];
    [self reloadPullTable];
}

- (void)photoList:(PhotoList *)photoList didFailToUpdate:(NSError *)error
{
    [self reloadPullTable];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return isGridMode ? (NSInteger) ceil((double) mentionList.photos.count / itemsInRow) : mentionList.photos.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return isGridMode ? gridCellHeight : 364;
}

- (UITableViewCell*)mentionOrReplyForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VKPhoto *photo = [mentionList.photos objectAtIndex:indexPath.row];
    if (photo.type == VKPhotoTypeMention) {
        MentionPhotoCell *cell = [MentionPhotoCell loadFromNIB];
        cell.delegate = self;
        [cell displayPhoto:[mentionList.photos objectAtIndex:indexPath.row]];
        
        return cell;
    } else if (photo.type == VKPhotoTypeReply) {
        ReplyPhotoCell *cell = [ReplyPhotoCell loadFromNIB];
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
        return [self mentionOrReplyForRowAtIndexPath:indexPath];
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
    [mentionList loadMore];
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

#pragma mark - MentionPhotoCellDelegate

- (void)mentionPhotoCell:(MentionPhotoCell *)cell didTapOnAccount:(Account *)account
{
    [delegate repliesViewController:self didSelectAccount:account];
}

- (void)mentionPhotoCell:(MentionPhotoCell *)cell didTapOnPhoto:(VKPhoto *)photo
{
    [delegate repliesViewController:self didReplyToPhoto:photo];
}

@end