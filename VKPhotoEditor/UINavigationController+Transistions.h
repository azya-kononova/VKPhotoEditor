//
//  UINavigationController+Transistion.h
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 11/3/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^UINavigationControllerActionBlock)();

@interface UINavigationController (Transistions)
- (void)pushViewController:(UIViewController*)ctrl transition:(UIViewAnimationTransition)transition;
- (void)popViewControllerTransition:(UIViewAnimationTransition)transition;
- (void)popToRootViewControllerTransition:(UIViewAnimationTransition)transition;
@end
