//
//  PhotoCell.h
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/28/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RemoteImageView.h"
#import "VKPhoto.h"

@interface PhotoCell : UITableViewCell
@property (nonatomic, strong) IBOutlet RemoteImageView* remoteImageView;

- (void)displayPhoto:(VKPhoto*)photo;
@end
