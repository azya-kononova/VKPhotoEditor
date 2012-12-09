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
#import "TheaterView.h"

@protocol ReplyPhotoCellDelegate;

@interface ReplyPhotoCell : UITableViewCell

@property (nonatomic, unsafe_unretained) id<ReplyPhotoCellDelegate> delegate;
@property (nonatomic, strong) IBOutlet RemoteImageView *avatarImageView;
@property (nonatomic, strong) IBOutlet RemoteImageView *replyToImageView;
@property (nonatomic, strong) IBOutlet UILabel *userNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *postDateLabel;
@property (nonatomic, strong) IBOutlet TheaterView *theaterView;
@property (nonatomic, strong) IBOutlet UIView *loadingView;

- (void)displayPhoto:(VKPhoto *)_photo;
- (IBAction)selectAccount;

@end

@protocol ReplyPhotoCellDelegate
- (void)replyPhotoCell:(ReplyPhotoCell *)cell didTapOnAccount:(Account *)account;
- (void)replyPhotoCell:(ReplyPhotoCell *)cell didTapOnPhoto:(VKPhoto *)photo;
@end
