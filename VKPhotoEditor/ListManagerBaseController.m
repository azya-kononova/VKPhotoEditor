//
//  ListManagerBaseController.m
//  VKPhotoEditor
//
//  Created by asya on 12/7/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "ListManagerBaseController.h"

#import "UIView+Helpers.h"
#import "UIColor+VKPhotoEditor.h"

@implementation ListManagerBaseController

@synthesize tableView;
@synthesize tableHeaderView;
@synthesize noPhotosLabel;
@synthesize activityIndicator;
@synthesize delegate;
@synthesize gridPhotoList;


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
        if (row < self.gridPhotoList.count) {
            [photos addObject:[self.gridPhotoList objectAtIndex:row]];
        }
    }
    
    return photos;
}


#pragma mark - PhotosListDelegate

- (void)reloadPullTable
{
    activityIndicator.hidden = YES;
    noPhotosLabel.hidden = photoList.photos.count;
    
    [tableView reloadData];
    tableView.pullTableIsLoadingMore = NO;
    tableView.pullTableIsRefreshing = NO;
    
    //    [tableView setCompleted:searchResultsList.completed];
}

- (void)photoList:(PhotoList *)_photoList didUpdatePhotos:(NSArray *)photos
{
    tableView.pullLastRefreshDate = [NSDate date];
    [self reloadPullTable];
}

- (void)photoList:(PhotoList *)_photoList didFailToUpdate:(NSError *)error
{
    [self reloadPullTable];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return isGridMode ? (NSInteger) ceil((double) self.gridPhotoList.count / itemsInRow) : photoList.photos.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isGridMode) {
        ThumbnailPhotoCell *cell = [ThumbnailPhotoCell dequeOrCreateInTable:tableView];
        cell.delegate = self;
        [cell displayPhotos:[self getPhotosForIndexPath:indexPath]];
        return cell;
    } else {
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isGridMode) return;
    
    VKPhoto *photo = [photoList.photos objectAtIndex:indexPath.row];
    [delegate listBaseController:self didReplyToPhoto:photo];
}


#pragma mark - PullTableViewDelegate

- (void)pullTableViewDidTriggerRefresh:(PullTableView *)pullTableView
{
    [photoList reset];
    [photoList loadMore];
}

- (void)pullTableViewDidTriggerLoadMore:(PullTableView *)pullTableView
{
    [photoList loadMore];
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
        [delegate listBaseController:self presenModalViewController:controller animated:YES];
    }
}

#pragma mark - FastViewerControllerDelegate

- (void)fastViewerControllerDidFinish:(FastViewerController *)controller
{
    [delegate listBaseController:self dismissModalViewController:controller animated:YES];
    isFastViewerOpen = NO;
}

- (void)fastViewerController:(FastViewerController *)controller didFinishWithAccount:(Account *)account
{
    [delegate listBaseController:self didSelectAccount:account animated:YES];
    [delegate listBaseController:self dismissModalViewController:controller animated:YES];
    isFastViewerOpen = NO;
}

#pragma mark - PhotoCellDelegate

- (void)photoCell:(PhotoCell *)photoCell didSelectAccount:(Account *)account
{
    [delegate listBaseController:self didSelectAccount:account animated:YES];
}

- (void)photoCell:(PhotoCell *)photoCell didTapOnPhoto:(VKPhoto *)photo
{
    [delegate listBaseController:self didReplyToPhoto:photo];
}

- (void)photoCell:(PhotoCell *)photoCell didTapHashTag:(NSString *)hashTag
{
    
}

@end
