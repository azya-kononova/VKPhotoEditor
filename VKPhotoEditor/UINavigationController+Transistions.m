//
//  UINavigationController+Transistion.m
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 11/3/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "UINavigationController+Transistions.h"

#define ANIMATION_DURATION 0.8

@implementation UINavigationController (Transistions)

- (void)useAnimationForAction:(UINavigationControllerActionBlock)block withTranstion:(UIViewAnimationTransition)transition
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:ANIMATION_DURATION];
    [UIView setAnimationTransition:transition forView:self.view cache:NO];
    block();
    [UIView commitAnimations];
}


- (void)pushViewController:(UIViewController*)ctrl transition:(UIViewAnimationTransition)transition
{
    [self useAnimationForAction:^{
        [self pushViewController:ctrl animated:YES];
    } withTranstion:transition];
}

- (void)popViewControllerTransition:(UIViewAnimationTransition)transition
{
    [self useAnimationForAction:^{
        [self popViewControllerAnimated:YES];
    } withTranstion:transition];
}

- (void)popToRootViewControllerTransition:(UIViewAnimationTransition)transition
{
    [self useAnimationForAction:^{
        [self popToRootViewControllerAnimated:YES];
    } withTranstion:transition];
}


@end
