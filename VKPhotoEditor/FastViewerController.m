//
//  FastViewerController.m
//  VKPhotoEditor
//
//  Created by asya on 11/25/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "FastViewerController.h"
#import "RemoteImageView.h"
#import "DataFormatter.h"
#import "ZoomingView.h"

@interface FastViewerController () {
    IBOutlet UIView *backTopView;
    IBOutlet UILabel *photoLabel;
    IBOutlet UIImageView *arrowImageView;
    IBOutlet UIImageView *backBottomView;
    IBOutlet UIView *photoPlaceholder;
    IBOutlet UILabel *userNameLabel;
    IBOutlet UILabel *postDateLabel;
    IBOutlet RemoteImageView *avatarImageView;
    
    VKPhoto *photo;
    ZoomingView *zoomingView;
}

@end

@implementation FastViewerController

@synthesize delegate;

- (id)initWithPhoto:(VKPhoto *)_photo
{
    self = [super init];
    if (self) {
        photo = _photo;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    userNameLabel.text = photo.account.login;
    postDateLabel.text = [DataFormatter formatRelativeDate:photo.date];
    
    [avatarImageView displayImage:photo.account.avatar];
    
    zoomingView = [[ZoomingView alloc] initWithContentView:[[UIImageView alloc] initWithImage:photo.photo.image] frame:photoPlaceholder.bounds];
    zoomingView.shouldClip = YES;
    zoomingView.minZoomScale = 1;
    zoomingView.maxZoomScale = 4;
    zoomingView.bounces = NO;
    zoomingView.contentMode = UIViewContentModeScaleAspectFit;
    [photoPlaceholder addSubview:zoomingView];
    
    UITapGestureRecognizer *topRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goBack:)];
    UITapGestureRecognizer *bottomRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goBack:)];
    [backBottomView addGestureRecognizer:bottomRecognizer];
    [backTopView addGestureRecognizer:topRecognizer];
}

- (void)goBack:(UIGestureRecognizer *)recognizer
{
    [delegate fastViewerControllerDidFinish:self];
}

@end
