//
//  ReplyPhotoCell.m
//  VKPhotoEditor
//
//  Created by asya on 12/1/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "ReplyPhotoCell.h"
#import "TheaterView.h"
#import "UITextView+Resize.h"

@interface ReplyPhotoCell ()<TheaterViewDataSource, TheaterViewDelegate>
@end

@implementation ReplyPhotoCell {
    TheaterView *theaterView;
    VKPhoto *photo;
    NSArray *replyPhotos;
}

@synthesize avatarImageView;
@synthesize replyToImageView;
@synthesize userNameLabel;
@synthesize postDateLabel;
@synthesize placeholder;
@synthesize captionTextView;


- (void)awakeFromNib
{
    [super awakeFromNib];
    
    theaterView = [TheaterView loadFromNIB];
    theaterView.dataSource = self;
    theaterView.delegate = self;
    [placeholder addSubview:theaterView];
}

- (void)displayPhoto:(VKPhoto *)_photo
{
    self.hidden = _photo.imageURL == nil;
    photo = _photo;
    [avatarImageView displayImage:photo.photo];
    [replyToImageView displayImage:photo.replyToPhoto.photo];
    
    if (![photo.caption isKindOfClass:[NSNull class]]) captionTextView.text = photo.caption;
    [captionTextView sizeFontToFitMinSize:8 maxSize:28];
    [captionTextView setNeedsDisplay];
    
    //TODO: load replies
    replyPhotos = [NSArray arrayWithObjects:photo, photo.replyToPhoto, nil];
    [theaterView reloadData];
}

#pragma mark - TheaterViewDataSource

- (NSUInteger)numberOfItemsInTheaterView:(TheaterView*)view
{
    return replyPhotos.count;
}

- (UIView*)theaterView:(TheaterView*)view viewForItemWithIndex:(NSUInteger)index
{
    RemoteImageView *remoteImageView = [RemoteImageView new];
    remoteImageView.frame = placeholder.bounds;
    [remoteImageView displayImage:[replyPhotos objectAtIndex:index]];
    
    return remoteImageView;
}

#pragma mark - TheaterViewDelegate

- (void)theaterView:(TheaterView*)view didTapOnItemWithIndex:(NSUInteger)index
{
    
}

- (void)theaterView:(TheaterView *)view didScrollToItemWithIndex:(NSUInteger)index
{
    
}

@end
