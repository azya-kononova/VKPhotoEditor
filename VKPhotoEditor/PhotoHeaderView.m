//
//  PhotoHeaderView.m
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/28/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "PhotoHeaderView.h"
#import "DataFormatter.h"

@implementation PhotoHeaderView {
}
@synthesize nameLabel;
@synthesize dateLabel;
@synthesize remoteImageView;

- (void)displayPhoto:(VKPhoto *)photo
{
    nameLabel.text = photo.account.login;
    [remoteImageView displayImage:photo.account.avatar];
    
    dateLabel.text = [DataFormatter formatRelativeDate:photo.date];
}

@end
