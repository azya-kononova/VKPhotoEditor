//
//  MentionPhotoCell.m
//  VKPhotoEditor
//
//  Created by asya on 12/2/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "MentionPhotoCell.h"
#import "PhotoCell.h"
#import "PhotoHeaderCell.h"

@implementation MentionPhotoCell {
    PhotoCell *photoView;
    PhotoHeaderCell *headerView;
    
    VKPhoto *photo;
}

@synthesize headerPlaceholder;
@synthesize imagePlaceholder;
@synthesize delegate;

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    photoView = [PhotoCell loadFromNIB];
    [imagePlaceholder addSubview:photoView];
    
    headerView = [PhotoHeaderCell loadFromNIB];
    [headerPlaceholder addSubview:headerView];
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handelTap:)];
    [self addGestureRecognizer:recognizer];
}

- (void)displayPhoto:(VKPhoto *)_photo
{
    photo = _photo;
    
    [photoView displayPhoto:photo];
    [headerView displayPhoto:photo];
}

- (void)handelTap:(UITapGestureRecognizer *)recognizer
{
    CGPoint point = [recognizer locationInView:self];
    if (CGRectContainsPoint(headerPlaceholder.frame, point)) {
        [delegate mentionPhotoCell:self didTapOnAccount:photo.account];
    }
    
    [delegate mentionPhotoCell:self didTapOnPhoto:photo];
}

@end
