//
//  VKViewController.m
//  VKPhotoEditor
//
//  Created by Kate on 12/7/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "VKViewController.h"
#import "UploadingView.h"

@interface VKViewController ()
@end

@implementation VKViewController {
    UploadingView *uploadingView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    uploadingView = [UploadingView loadFromNIB];
}

- (void)showUploading:(UIImage*)image
{
    photosTableView.uploadingView = uploadingView;
    [uploadingView showUploading:image];
}

- (void)displayProgress:(CGFloat)progress
{
    [uploadingView displayProgress:progress];
}

- (void)cancelUpload:(BOOL)success
{
    [uploadingView cancelUpload:success];
    photosTableView.uploadingView = nil;
}

@end
