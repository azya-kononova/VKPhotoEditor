//
//  ReplyPhotoCell.h
//  VKPhotoEditor
//
//  Created by asya on 12/1/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RemoteImageView.h"
#import "VKPhoto.h"
#import "VKHighlightTextView.h"

@interface ReplyPhotoCell : UITableViewCell

@property (nonatomic, strong) IBOutlet RemoteImageView *avatarImageView;
@property (nonatomic, strong) IBOutlet RemoteImageView *replyToImageView;
@property (nonatomic, strong) IBOutlet UILabel *userNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *postDateLabel;
@property (nonatomic, strong) IBOutlet UIView *placeholder;
@property (nonatomic, strong) IBOutlet VKHighlightTextView *captionTextView;

- (void)displayPhoto:(VKPhoto *)_photo;

@end
