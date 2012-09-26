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

@interface CroppingViewController () {
    IBOutlet UIView *zoomingPlaceholder;
    IBOutlet FlexibleButton *cancelBtn;
    IBOutlet FlexibleButton *chooseBtn;
    
    ZoomingView *zoomingView;
    UIView *captureView;
}

@end

@implementation CroppingViewController {
    UIImage *image;
}

@synthesize delegate;

- (id)initWithImage:(UIImage *)_image
{
    self = [super init];
    if (self) {
        image = _image;
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
    
    captureView = [[UIView alloc] initWithFrame:CGRectMake(0, 67, 323, 323)];
}


#pragma mark - Actions

- (IBAction)cancel:(id)sender
{
    [delegate croppingViewControllerDidCancel:self];
}

- (IBAction)choose:(id)sender
{
    CGFloat x = zoomingView.contentOffset.x/zoomingView.zoomScale;
    CGFloat y = (zoomingView.contentOffset.y + CGRectGetMinY(captureView.frame))/zoomingView.zoomScale;
    CGFloat width = CGRectGetWidth(captureView.frame)/zoomingView.zoomScale;
    CGFloat height = CGRectGetHeight(captureView.frame)/zoomingView.zoomScale;
    UIImage *cropImage = [image croppedImage:CGRectMake(x, y, width, height)];
    
    [delegate croppingViewController:self didFinishWithImage:cropImage];
}

@end
