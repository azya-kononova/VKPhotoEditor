//
//  PhotoHeaderView.h
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/28/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "VKPhoto.h"
#import "RemoteImageView.h"
#import "HighlightedButton.h"

@protocol PhotoHeaderViewDelegate;

@interface PhotoHeaderView : UIView <HighlightedButtonDelegate>
@property (nonatomic, assign) id<PhotoHeaderViewDelegate> delegate;
@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UILabel *dateLabel;
@property (nonatomic, strong) IBOutlet RemoteImageView *remoteImageView;
@property (nonatomic, strong) IBOutlet UIImageView *arrowView;

- (void)displayPhoto:(VKPhoto*)photo;
- (IBAction)selectAccount;
@end

@protocol PhotoHeaderViewDelegate
- (void)photoHeaderView:(PhotoHeaderView*)view didSelectAccount:(Account*)account;
@end
