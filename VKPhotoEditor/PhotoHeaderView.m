//
//  PhotoHeaderView.m
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/28/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "PhotoHeaderView.h"
#import "DataFormatter.h"
#import "UIView+Helpers.h"

@implementation PhotoHeaderView {
    Account *account;
}
@synthesize nameLabel;
@synthesize dateLabel;
@synthesize remoteImageView;
@synthesize delegate;
@synthesize arrowView;

- (void)displayPhoto:(VKPhoto *)photo
{
    BOOL hasPhoto = photo.imageURL != nil;
    arrowView.hidden = hasPhoto;
    [nameLabel moveTo:CGPointMake(49, hasPhoto ? 5 : 13)];
    
    account = photo.account;
    [remoteImageView displayImage:photo.account.avatar];
    nameLabel.text = photo.account.login;
    dateLabel.text = hasPhoto ? [DataFormatter formatRelativeDate:photo.date] : nil;
}

- (IBAction)selectAccount
{
    [delegate photoHeaderView:self didSelectAccount:account];
}

#pragma mark - HighlightedButtonDelegate

- (void)highlightedButton:(HighlightedButton *)button didBecameHighlighted:(BOOL)highlighted
{
    nameLabel.textColor = highlighted ? [UIColor whiteColor] : [UIColor blackColor];
    dateLabel.textColor = highlighted ? [UIColor whiteColor] : [UIColor lightGrayColor];
}


@end
