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

@implementation PhotoCell {
    VKPhoto *photo;
}
@synthesize remoteImageView;
@synthesize addedImageView;
@synthesize captionTextView;
@synthesize delegate;

- (void)awakeFromNib
{
    captionTextView.font = [UIFont fontWithName:@"Lobster" size:28.0];
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapInTextView:)];
    [captionTextView addGestureRecognizer:tapRecognizer];
}

- (void)displayPhoto:(VKPhoto *)_photo
{
    photo = _photo;
    [remoteImageView displayImage:photo.photo];
    if (![photo.caption isKindOfClass:[NSNull class]]) captionTextView.text = photo.caption ;
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

- (void)didTapInTextView:(UITapGestureRecognizer *)recognizer
{
    CGPoint location = [recognizer locationInView:captionTextView];
    NSString *hashTag = [self getWordAtPosition:location];
    if (hashTag) [delegate photoCell:self didTapHashTag:hashTag];
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