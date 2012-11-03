//
//  UIViewController+StatusBar.m
//  VKPhotoEditor
//
//  Created by asya on 11/3/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "UIViewController+StatusBar.h"
#import "PhotosListController.h"

@implementation UIViewController (StatusBar)

- (void)hideStatusBarIfNeed
{
    BOOL needStatusBar =  [self isKindOfClass:PhotosListController.class];
    [[UIApplication sharedApplication] setStatusBarHidden:!needStatusBar withAnimation: UIStatusBarAnimationFade];
}

@end
