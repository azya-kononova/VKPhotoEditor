//
//  PhotoHeaderCell.h
//  VKPhotoEditor
//
//  Created by Kate on 11/25/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "VKPhoto.h"
#import "RemoteImageView.h"

@interface PhotoHeaderCell : UITableViewCell
@property (nonatomic, strong) IBOutlet RemoteImageView *remoteImageView;
@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UILabel *dateLabel;
- (void)displayPhoto:(VKPhoto*)photo;
@end
