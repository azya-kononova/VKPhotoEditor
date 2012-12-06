//
//  UploadingView.h
//  VKPhotoEditor
//
//  Created by Kate on 12/7/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UploadingView : UIView

@property (nonatomic, strong) IBOutlet UIImageView *uploadingProgressView;
@property (nonatomic, strong) IBOutlet UIImageView *uploadingBgView;
@property (nonatomic, strong) IBOutlet UIImageView *uploadingImageView;

@property (nonatomic, strong) IBOutlet UILabel *uploadInfoLabel;

- (void)showUploading:(UIImage*)image;
- (void)displayProgress:(CGFloat)progress;
- (void)cancelUpload:(BOOL)success;
@end
