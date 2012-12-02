//
//  MentionPhotoCell.h
//  VKPhotoEditor
//
//  Created by asya on 12/2/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VKPhoto.h"
#import "Account.h"

@protocol MentionPhotoCellDelegate;

@interface MentionPhotoCell : UITableViewCell

@property (nonatomic, unsafe_unretained) id<MentionPhotoCellDelegate> delegate;
@property (nonatomic, strong) IBOutlet UIView *headerPlaceholder;
@property (nonatomic, strong) IBOutlet UIView *imagePlaceholder;

- (void)displayPhoto:(VKPhoto *)photo;

@end

@protocol MentionPhotoCellDelegate
- (void)mentionPhotoCell:(MentionPhotoCell *)cell didTapOnAccount:(Account *)account;
- (void)mentionPhotoCell:(MentionPhotoCell *)cell didTapOnPhoto:(VKPhoto *)photo;
@end
