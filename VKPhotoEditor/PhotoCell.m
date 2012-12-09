//
//  PhotoCell.m
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/28/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "PhotoCell.h"
#import "CALayer+Animations.h"
#import "VKHighlightTextView.h"
#import "UITextView+Resize.h"
#import "UIView+Helpers.h"
#import "DataFormatter.h"

@implementation PhotoCell {
    VKPhoto *photo;
}
@synthesize remoteImageView;
@synthesize addedImageView;
@synthesize captionTextView;
@synthesize delegate;
@synthesize searchString;
@synthesize avatarRemoteImageView;
@synthesize dateLabel;
@synthesize nameLabel;
@synthesize accountButton;
@synthesize progressBgImage;
@synthesize progressImage;

- (void)awakeFromNib
{
    captionTextView.font = [UIFont fontWithName:@"Lobster" size:28.0];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapInTextView:)];
    [captionTextView addGestureRecognizer:tapRecognizer];
    
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnPhoto)];
    [remoteImageView addGestureRecognizer:tapRecognizer];
    
    progressBgImage.image = [[UIImage imageNamed:@"Uploading_2.png"] stretchableImageWithLeftCapWidth:6 topCapHeight:6];
    progressImage.image = [[UIImage imageNamed:@"UploadingProgress_2.png"] stretchableImageWithLeftCapWidth:6 topCapHeight:6];
}

- (void)displayAccount:(Account *)account
{
    BOOL hasPhoto = NO;
    
    [nameLabel moveTo:CGPointMake(49, hasPhoto ? 5 : 13)];
    
    [avatarRemoteImageView displayImage:account.thumbnailAvatar];
    nameLabel.text = account.login;
    dateLabel.text = hasPhoto ? [DataFormatter formatRelativeDate:photo.date] : nil;
    accountButton.hidden = NO;
    
    [remoteImageView displayImage:account.avatar];
    captionTextView.text = account.login;
     [captionTextView setNeedsDisplay];
}

- (void)displayPhoto:(VKPhoto *)_photo
{
    [self displayPhoto:_photo canSelectAccount:YES];
}

- (void)displayPhoto:(VKPhoto *)_photo canSelectAccount:(BOOL)selectAccount
{
    photo = _photo;
    BOOL hasPhoto = photo.imageURL != nil;
    
    [nameLabel moveTo:CGPointMake(49, hasPhoto ? 5 : 13)];
    
    [avatarRemoteImageView displayImage:photo.account.thumbnailAvatar];
    nameLabel.text = photo.account.login;
    dateLabel.text = hasPhoto ? [DataFormatter formatRelativeDate:photo.date] : nil;
    accountButton.hidden = !selectAccount;
    
    [remoteImageView displayImage:photo.photo];
    if (![photo.caption isKindOfClass:[NSNull class]]) captionTextView.text = photo.caption ;
    [captionTextView sizeFontToFitMinSize:8 maxSize:28];
    captionTextView.searchString = searchString;
    [captionTextView setNeedsDisplay];
}

- (void)hideSelfAfterTimeout:(NSTimeInterval)timeout
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if (timeout > 0) {
        [self performSelector:@selector(hideSelf) withObject:nil afterDelay:timeout];
    }
}

- (void)showAdded;
{
    [self showSelf:YES];
    [self hideSelfAfterTimeout:3.5];
}

- (void)showSelf:(BOOL)show
{
    [addedImageView.layer fade].duration = 0.5;
    addedImageView.hidden = !show;
}

- (void)hideSelf
{
    [self showSelf:NO];
}

- (IBAction)openAccount
{
    [delegate photoCell:self didSelectAccount:photo.account];
}

#pragma mark - recognizers

- (void)didTapOnPhoto
{
    [delegate photoCell:self didTapOnPhoto:photo];
}

- (void)didTapInTextView:(UITapGestureRecognizer *)recognizer
{
    CGPoint location = [recognizer locationInView:captionTextView];
    NSString *hashTag = [self getWordAtPosition:location];
    if (hashTag)
        [delegate photoCell:self didTapHashTag:hashTag];
    else
        [self didTapOnPhoto];
}

-(NSString*)getWordAtPosition:(CGPoint)pos
{
    pos.y += captionTextView.contentOffset.y;
    UITextPosition *tapPos = [captionTextView closestPositionToPoint:pos];
    
    UITextRange * wr = [captionTextView.tokenizer rangeEnclosingPosition:tapPos withGranularity:UITextGranularityWord inDirection:UITextLayoutDirectionRight];
    
    // Катя что ты делаешь ахахах прекрати (
    
    NSInteger startOffset = [captionTextView offsetFromPosition:captionTextView.beginningOfDocument toPosition:wr.start];
    if (--startOffset < 0) return nil;
    
    NSInteger endOffset = [captionTextView offsetFromPosition:captionTextView.beginningOfDocument toPosition:wr.end];
    if ([captionTextView.text characterAtIndex:(startOffset)] == '#') {
        return [captionTextView.text substringWithRange:NSMakeRange(startOffset, endOffset - startOffset)];
    }
    return nil;
}

#pragma mark - RemoteImageViewDelegate

- (void)remoteImageView:(RemoteImageView*)view didLoadImage:(UIImage *)image
{
    if (photo.justUploaded) {
        [self showAdded];
        photo.justUploaded = NO;
    }
}

@end