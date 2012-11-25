//
//  PhotoHeaderCell.m
//  VKPhotoEditor
//
//  Created by Kate on 11/25/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "PhotoHeaderCell.h"
#import "DataFormatter.h"
#import "UIView+Helpers.h"

@implementation PhotoHeaderCell
@synthesize remoteImageView;
@synthesize nameLabel;
@synthesize dateLabel;

- (void)displayPhoto:(VKPhoto *)photo
{
    BOOL hasPhoto = photo.imageURL != nil;
    self.accessoryType = hasPhoto ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
    [nameLabel moveTo:CGPointMake(49, hasPhoto ? 5 : 13)];
    
    [remoteImageView displayImage:photo.account.avatar];
    nameLabel.text = photo.account.login;
    dateLabel.text = hasPhoto ? [DataFormatter formatRelativeDate:photo.date] : nil;
}
@end
