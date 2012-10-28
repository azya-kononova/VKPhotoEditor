//
//  PhotoHeaderView.h
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/28/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "VKPhoto.h"
#import "RemoteImageView.h"

@interface PhotoHeaderView : UIView
@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UILabel *dateLabel;
@property (nonatomic, strong) IBOutlet RemoteImageView *remoteImageView;

- (void)displayPhoto:(VKPhoto*)photo;
@end
