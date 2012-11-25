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
#import "UIColor+VKPhotoEditor.h"

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
    
    photoLabel.font = [UIFont fontWithName:@"Lobster" size:22.0];
    
    backBottomView.backgroundColor = [UIColor defaultBgColor];
    backTopView.backgroundColor = [UIColor defaultBgColor];
    
    userNameLabel.text = photo.account.login;
    postDateLabel.text = [DataFormatter formatRelativeDate:photo.date];
    
    [avatarImageView displayImage:photo.account.avatar];
    
    zoomingView = [[ZoomingView alloc] initWithContentView:[[UIImageView alloc] initWithImage:photo.photo.image] frame:photoPlaceholder.bounds];
    zoomingView.shouldClip = YES;
    zoomingView.maxZoomScale = 3;
    zoomingView.bounces = NO;
    zoomingView.contentMode = UIViewContentModeScaleAspectFit;
    [photoPlaceholder addSubview:zoomingView];
    
    UITapGestureRecognizer *topRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(topViewGoBack:)];
    UITapGestureRecognizer *bottomRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bottomViewGoBack:)];
    [backBottomView addGestureRecognizer:bottomRecognizer];
    [backTopView addGestureRecognizer:topRecognizer];
}

- (void)topViewGoBack:(UIGestureRecognizer *)recognizer
{
    arrowImageView.highlighted = YES;
    backTopView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"DarkInner_Pressed.png"]];
    photoLabel.textColor = [UIColor whiteColor];
    photoLabel.shadowColor = [UIColor blueColor];
    [self performSelector:@selector(goBack) withObject:nil afterDelay:0.4];
}

- (void)bottomViewGoBack:(UIGestureRecognizer *)recognizer
{
    backBottomView.highlighted = YES;
    backBottomView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"DarkInner_Pressed.png"]];
    [self performSelector:@selector(goBack) withObject:nil afterDelay:0.4];
}

- (void)goBack
{
    [delegate fastViewerControllerDidFinish:self];
}

@end
