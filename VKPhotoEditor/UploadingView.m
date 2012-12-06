//
//  UploadingView.m
//  VKPhotoEditor
//
//  Created by Kate on 12/7/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "UploadingView.h"
#import "UIView+Helpers.h"

@implementation UploadingView {
    CGFloat uploadWidth;
}
@synthesize uploadingProgressView;
@synthesize uploadingBgView;
@synthesize uploadingImageView;
@synthesize uploadInfoLabel;

- (void)awakeFromNib
{
    uploadingBgView.image = [[UIImage imageNamed:@"Uploading_1.png"] stretchableImageWithLeftCapWidth:6 topCapHeight:6];
    uploadingProgressView.image = [[UIImage imageNamed:@"UploadingProgress_1.png"] stretchableImageWithLeftCapWidth:6 topCapHeight:6];
    uploadingImageView.layer.cornerRadius = 12.5;
    uploadWidth = uploadingBgView.frame.size.width;
}

- (void)showUploading:(UIImage*)image
{
    BOOL show = image != nil;
    
    if (show) uploadInfoLabel.text = nil;
    
    uploadingImageView.image = image;
    [uploadingProgressView resizeTo:CGSizeMake(0, uploadingProgressView.frame.size.height)];
}

- (void)displayProgress:(CGFloat)progress
{
    [uploadingProgressView resizeTo:CGSizeMake(uploadWidth * progress, uploadingProgressView.frame.size.height)];
}

- (void)cancelUpload:(BOOL)success
{
    [self showUploading:nil];
}

@end
