//
//  AvatarView.h
//  VKPhotoEditor
//
//  Created by Kate on 11/26/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "RemoteImageView.h"
#import "VKHighlightTextView.h"
#import "VKPhoto.h"

@interface PhotoView : UIView
@property (nonatomic, strong) IBOutlet RemoteImageView *remoteImageView;
@property (nonatomic, strong) IBOutlet VKHighlightTextView *captionTextView;
@property (nonatomic, strong) IBOutlet UIImageView *arrowImageView;

- (void)displayPhoto:(VKPhoto *)photo;
@end
