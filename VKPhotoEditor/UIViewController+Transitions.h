//
//  UIViewController+Transitions.h
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/25/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Transitions)

- (void) presentModalViewController:(UIViewController *)modalViewController withPushDirection: (NSString *) direction;
- (void) dismissModalViewControllerWithPushDirection:(NSString *) direction;

@end
