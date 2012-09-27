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
    UIImage *image;
}

@end

@implementation CroppingViewController 

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
    zoomingView.captureViewInsets = UIEdgeInsetsMake(CGRectGetMinY(captureView.frame), 0, CGRectGetMaxY(captureView.frame), 0);
    
    [zoomingPlaceholder addSubview:zoomingView];
    
    cancelBtn.bgImagecaps = CGSizeMake(20, 20);
    chooseBtn.bgImagecaps = CGSizeMake(20, 20);
    
    captureView.layer.borderWidth = 2;
    captureView.layer.borderColor = [[UIColor whiteColor] CGColor];
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
