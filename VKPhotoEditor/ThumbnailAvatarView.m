//
//  ThumbnailAvatarView.m
//  VKPhotoEditor
//
//  Created by Kate on 12/9/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "ThumbnailAvatarView.h"

@implementation ThumbnailAvatarView {
    Account *account;
}
@synthesize remoteImageView;
@synthesize delegate;
@synthesize nameLabel;

- (void)awakeFromNib
{
    [nameLabel setFont:[UIFont fontWithName:@"Lobster 1.4" size:17.0]];
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap)];
    [self addGestureRecognizer:recognizer];
}

- (void)displayAccount:(Account *)_account
{
    account = _account;
    [remoteImageView displayImage:account.avatar];
    nameLabel.text = account.login;
}

- (void)didTap
{
    [delegate thumbnailAvatarView:self didSelectAccount:account];
}
@end
