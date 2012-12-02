//
//  ReplyPhotoCell.m
//  VKPhotoEditor
//
//  Created by asya on 12/1/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "ReplyPhotoCell.h"
#import "UITextView+Resize.h"
#import "ReplyPhotoList.h"
#import "DataFormatter.h"
#import "PhotoCell.h"

@interface ReplyPhotoCell ()<TheaterViewDataSource, TheaterViewDelegate, PhotoListDelegate>
@end

@implementation ReplyPhotoCell {
    VKPhoto *photo;
    NSMutableArray *replyPhotos;
    NSMutableDictionary *replyPhotoViews;
    
    ReplyPhotoList *repliesList;
}

@synthesize avatarImageView;
@synthesize replyToImageView;
@synthesize userNameLabel;
@synthesize postDateLabel;
@synthesize theaterView;
@synthesize delegate;

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    replyPhotoViews = [NSMutableDictionary dictionary];
    
    replyPhotos = [NSMutableArray array];
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handelTap:)];
    [self addGestureRecognizer:recognizer];
}

- (void)displayPhoto:(VKPhoto *)_photo
{
    self.hidden = _photo.imageURL == nil;
    photo = _photo;
    [avatarImageView displayImage:photo.account.avatar];
    [replyToImageView displayImage:photo.replyToPhoto.photo];
    
    userNameLabel.text = photo.account.login;
    postDateLabel.text = [DataFormatter formatRelativeDate:photo.date];
    
    //TODO: load replies
    [replyPhotos addObject:photo];
    [replyPhotos addObject:photo.replyToPhoto];
    
    [theaterView reloadData];
}

- (UIView *)arrowToCell:(PhotoCell *)photoCell
{
    UIImageView *arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NextPhoto.png"]];
    CGRect rect = arrowImageView.frame;
    rect.origin = CGPointMake(photoCell.bounds.size.width - rect.size.width - 10, (photoCell.bounds.size.height - rect.size.height)/2);
    arrowImageView.frame = rect;
    
    return arrowImageView;
}

- (void)handelTap:(UITapGestureRecognizer *)recognizer
{
    CGPoint point = [recognizer locationInView:self];
    if (!CGRectContainsPoint(theaterView.frame, point)) {
        [delegate replyPhotoCell:self didTapOnAccount:photo.account];
    }
}

- (void)loadRepliesForPhoto:(VKPhoto *)_photo
{
    if (repliesList) {
        [repliesList reset];
        repliesList.delegate = nil;
        repliesList = nil;
    }
    
    repliesList = [[ReplyPhotoList alloc] initWithPhotoID:_photo.replyTo];
    repliesList.delegate = self;
    [repliesList loadMore];
}

#pragma mark - TheaterViewDataSource

- (NSUInteger)numberOfItemsInTheaterView:(TheaterView*)view
{
    return replyPhotos.count;
}

- (UIView*)theaterView:(TheaterView*)view viewForItemWithIndex:(NSUInteger)index
{
    VKPhoto *replyPhoto = [replyPhotos objectAtIndex:index];
    PhotoCell *photoCell = [replyPhotoViews objectForKey:[NSNumber numberWithInt:index]];
    
    if (!photoCell) {
        photoCell = [PhotoCell loadFromNIB];
        
        if (replyPhoto.replyTo) {
            [photoCell addSubview:[self arrowToCell:photoCell]];
        }
        
        [replyPhotoViews setObject:photoCell forKey:[NSNumber numberWithInt:index]];
    }
    
    [photoCell displayPhoto:replyPhoto];
    
    return photoCell;
}

#pragma mark - TheaterViewDelegate

- (void)theaterView:(TheaterView*)view didTapOnItemWithIndex:(NSUInteger)index
{
    [delegate replyPhotoCell:self didTapOnPhoto:[replyPhotos objectAtIndex:index]];
}

- (void)theaterView:(TheaterView *)view didScrollToItemWithIndex:(NSUInteger)index
{
    VKPhoto *_photo = [replyPhotos objectAtIndex:index];
    if (_photo.replyTo && index == replyPhotos.count - 1) {
        [self loadRepliesForPhoto:_photo];
    }
}

#pragma mark - PhotoListDelegate

- (void)photoList:(PhotoList*)photoList didUpdatePhotos:(NSArray*)photos
{
    [replyPhotos addObjectsFromArray:photos];
    [theaterView reloadData];
}

- (void)photoList:(PhotoList *)photoList didFailToUpdate:(NSError*)error
{
    
}

@end
