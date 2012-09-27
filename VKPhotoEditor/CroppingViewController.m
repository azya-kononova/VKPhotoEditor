//
//  CroppingViewController.m
//  VKPhotoEditor
//
//  Created by asya on 9/25/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "CroppingViewController.h"
#import "UIImage+Resize.h"
#import "ZoomingView.h"
#import "FlexibleButton.h"
#import "PhotoEditController.h"

@interface CroppingViewController () {
    IBOutlet UIView *captureView;
    IBOutlet UIView *zoomingPlaceholder;
    IBOutlet FlexibleButton *cancelBtn;
    IBOutlet FlexibleButton *chooseBtn;
    
    ZoomingView *zoomingView;
}

@end

@implementation CroppingViewController {
    UIImage *image;
    BOOL isPhoto;
}

- (id)initWithImage:(UIImage *)_image isPhoto:(BOOL)_isPhoto
{
    self = [super init];
    if (self) {
        image = _image;
        isPhoto = _isPhoto;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    zoomingView = [[ZoomingView alloc] initWithContentView:imageView frame:self.view.bounds];
    
    [zoomingPlaceholder addSubview:zoomingView];
    
    cancelBtn.bgImagecaps = CGSizeMake(20, 20);
    chooseBtn.bgImagecaps = CGSizeMake(20, 20);
    
    captureView.layer.borderWidth = 2;
    captureView.layer.borderColor = [[UIColor whiteColor] CGColor];
}


#pragma mark - Actions

- (IBAction)cancel:(id)sender
{
    [self.navigationController popViewControllerAnimated:NO];
}

- (IBAction)choose:(id)sender
{
    CGFloat x = zoomingView.contentOffset.x/zoomingView.zoomScale;
    CGFloat y = (zoomingView.contentOffset.y + CGRectGetMinY(captureView.frame))/zoomingView.zoomScale;
    CGFloat width = CGRectGetWidth(captureView.frame)/zoomingView.zoomScale;
    CGFloat height = CGRectGetHeight(captureView.frame)/zoomingView.zoomScale;
    UIImage *cropImage = [image croppedImage:CGRectMake(x, y, width, height)];
    
    PhotoEditController *photoEditController = [[PhotoEditController alloc] initWithImage:cropImage isPhoto:isPhoto];
    [self.navigationController pushViewController:photoEditController animated:NO];
}

@end
