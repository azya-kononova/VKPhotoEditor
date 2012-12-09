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
#import "PhotoView.h"
#import "UIView+Helpers.h"
#import "HighlightedButton.h"

@interface ReplyPhotoCell ()<TheaterViewDataSource, TheaterViewDelegate, PhotoListDelegate, HighlightedButtonDelegate>
@end

@implementation ReplyPhotoCell {
    VKPhoto *photo;
    NSMutableArray *replyPhotos;
    NSMutableDictionary *replyPhotoViews;
    
    ReplyPhotoList *repliesList;
    NSInteger emplyCellCount;
}

@synthesize avatarImageView;
@synthesize replyToImageView;
@synthesize userNameLabel;
@synthesize postDateLabel;
@synthesize theaterView;
@synthesize delegate;
@synthesize loadingView;

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    replyPhotoViews = [NSMutableDictionary dictionary];
    
    replyPhotos = [NSMutableArray array];
    
    emplyCellCount = 0;
}

- (void)displayPhoto:(VKPhoto *)_photo
{
    if (_photo == photo) return;
    
    self.hidden = _photo.imageURL == nil;
    photo = _photo;
    [avatarImageView displayImage:photo.account.avatar];
    [replyToImageView displayImage:photo.replyToPhoto.photo];
    
    userNameLabel.text = photo.account.login;
    postDateLabel.text = [DataFormatter formatRelativeDate:photo.date];
    
    //TODO: load replies
    replyPhotos = [NSMutableArray new];
    [replyPhotos addObject:photo];
    [replyPhotos addObject:photo.replyToPhoto];
    
    emplyCellCount = [replyPhotos.lastObject replyTo] ? 1 : 0;
    
    [theaterView reloadData];
}

- (UIView *)arrowToView:(PhotoView *)photoView
{
    UIImageView *arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NextPhoto.png"]];
    CGRect rect = arrowImageView.frame;
    rect.origin = CGPointMake(photoView.bounds.size.width - rect.size.width - 10, (photoView.bounds.size.height - rect.size.height)/2);
    arrowImageView.frame = rect;
    
    return arrowImageView;
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

 -(IBAction)selectAccount
{
    [delegate replyPhotoCell:self didTapOnAccount:photo.account];
}

#pragma mark - TheaterViewDataSource

- (NSUInteger)numberOfItemsInTheaterView:(TheaterView*)view
{
    return replyPhotos.count + emplyCellCount;
}

- (UIView*)theaterView:(TheaterView*)view viewForItemWithIndex:(NSUInteger)index
{
    if (index == replyPhotos.count) return loadingView;
    
    VKPhoto *replyPhoto = [replyPhotos objectAtIndex:index];
    PhotoView *photoView = [replyPhotoViews objectForKey:[NSNumber numberWithInt:index]];
    
    if (!photoView) {
        photoView = [PhotoView loadFromNIB];
        [photoView resizeTo:CGSizeMake(320, 320)];

        [replyPhotoViews setObject:photoView forKey:[NSNumber numberWithInt:index]];
    }
    
    [photoView displayPhoto:replyPhoto];
    photoView.arrowImageView.hidden = !replyPhoto.replyTo;
    return photoView;
}

#pragma mark - TheaterViewDelegate

- (void)theaterView:(TheaterView*)view didTapOnItemWithIndex:(NSUInteger)index
{
    if (index == replyPhotos.count) return;
    
    [delegate replyPhotoCell:self didTapOnPhoto:[replyPhotos objectAtIndex:index]];
}

- (void)theaterView:(TheaterView *)view didScrollToItemWithIndex:(NSUInteger)index
{
    if (index == replyPhotos.count) {
        VKPhoto *_photo = [replyPhotos objectAtIndex:index - 1];
        [self loadRepliesForPhoto:_photo];
    }
}

#pragma mark - PhotoListDelegate

- (void)photoList:(PhotoList*)photoList didUpdatePhotos:(NSArray*)photos
{
    [replyPhotos addObjectsFromArray:photos];
    emplyCellCount = [replyPhotos.lastObject replyTo] ? 1 : 0;
    [loadingView removeFromSuperview];
    
    [theaterView reloadData];
}

- (void)photoList:(PhotoList *)photoList didFailToUpdate:(NSError*)error
{
    
}


#pragma mark - HighlightedButtonDelegate

- (void)highlightedButton:(HighlightedButton *)button didBecameHighlighted:(BOOL)highlighted
{
    userNameLabel.highlighted = highlighted;
    postDateLabel.highlighted = highlighted;
}

@end
