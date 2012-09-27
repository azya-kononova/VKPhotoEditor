//
//  CroppingViewController.h
//  VKPhotoEditor
//
//  Created by asya on 9/25/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CroppingViewControllerDelegate;

@interface CroppingViewController : UIViewController

@property (nonatomic, unsafe_unretained) id<CroppingViewControllerDelegate> delegate;

- (id)initWithImage:(UIImage *)image;

@end

@protocol CroppingViewControllerDelegate
- (void)croppingViewControllerDidCancel:(CroppingViewController *)controller;
- (void)croppingViewController:(CroppingViewController *)controller didFinishWithImage:(UIImage *)image;
@end
