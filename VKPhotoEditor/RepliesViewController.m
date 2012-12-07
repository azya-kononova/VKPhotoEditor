//
//  RepliesViewController.m
//  VKPhotoEditor
//
//  Created by asya on 12/1/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "RepliesViewController.h"
#import "UIView+Helpers.h"
#import "VKConnectionService.h"
#import "UIColor+VKPhotoEditor.h"
#import "MentionList.h"
#import "ReplyPhotoCell.h"
#import "PhotoUpdatesLoader.h"

@interface RepliesViewController () <ReplyPhotoCellDelegate>
@end

@implementation RepliesViewController {
    UserProfile *profile;
}

- (id)initWithProfile:(UserProfile *)_profile
{
    self = [super init];
    if (self) {
        profile = _profile;
        photoList = [MentionList new];
        photoList.delegate = self;
        ((MentionList *)photoList).account = profile;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //Send -1 for reset badge
    [[NSNotificationCenter defaultCenter] postNotificationName:VKUpdateRepliesBadge object:[NSNumber numberWithInt:-1]];
    [photoList loadMore];
}

#pragma mark - Internals


- (NSArray *)gridPhotoList
{
    NSMutableArray *photos = [NSMutableArray array];
    
    for (VKPhoto *photo in photoList.photos) {
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


- (void)photoList:(PhotoList *)_photoList didUpdatePhotos:(NSArray *)photos
{
    [super photoList:_photoList didUpdatePhotos:photos];
    [(MentionList *)photoList saveSinceValue];
}


#pragma mark - UITableViewDataSource


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return isGridMode ? gridCellHeight : 366;
}

- (UITableViewCell*)mentionOrReplyForRowAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView*)_tableView
{
    VKPhoto *photo = [photoList.photos objectAtIndex:indexPath.row];
    if (photo.type == VKPhotoTypeMention || photo.type == VKPhotoTypePhoto) {
        PhotoCell *cell = [PhotoCell dequeOrCreateInTable:_tableView];
        cell.delegate = self;
        [cell displayPhoto:[photoList.photos objectAtIndex:indexPath.row]];
        
        return cell;
    } else if (photo.type == VKPhotoTypeReply) {
        ReplyPhotoCell *cell = [ReplyPhotoCell dequeOrCreateInTable:_tableView];
        cell.delegate = self;
        [cell displayPhoto:[photoList.photos objectAtIndex:indexPath.row]];
        
        return cell;
    }
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:_tableView cellForRowAtIndexPath:indexPath];
    return cell ? cell : [self mentionOrReplyForRowAtIndexPath:indexPath tableView:_tableView];
}


#pragma mark - PullTableViewDelegate

- (void)pullTableViewDidTriggerLoadMore:(PullTableView *)pullTableView
{
    if (!photoList.completed) {
        [super pullTableViewDidTriggerLoadMore:pullTableView];
    } else {
        [self performSelector:@selector(reloadPullTable) withObject:nil afterDelay:0.2];
    }
}

#pragma mark - ReplyPhotoCellDelegate

- (void)replyPhotoCell:(ReplyPhotoCell *)cell didTapOnAccount:(Account *)account
{
    [self.delegate listBaseController:self didSelectAccount:account animated:YES];
}

- (void)replyPhotoCell:(ReplyPhotoCell *)cell didTapOnPhoto:(VKPhoto *)photo
{
    [self.delegate listBaseController:self didReplyToPhoto:photo];
}

@end