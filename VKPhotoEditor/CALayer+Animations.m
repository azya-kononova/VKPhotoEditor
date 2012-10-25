//
//  CALayer+Animations.m
//  Mascotte
//
//  Created by Sergey Martynov on 26.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CALayer+Animations.h"

#define DURATION 0.7

@implementation CALayer (Animations)

- (CATransition*)addTransitionWithType:(NSString*)type subtype:(NSString*)subtype
{
    CATransition *transition = [CATransition new];
    if (type) transition.type = type;
    if (subtype) transition.subtype = subtype;
    transition.duration = DURATION;
    [self addAnimation:transition forKey:@"Transition"];
    return transition;
}

- (CATransition*)push:(NSString*)subtype
{
    return [self addTransitionWithType:kCATransitionPush subtype:subtype];
}

- (CATransition*)push:(NSString*)subtype duration:(CFTimeInterval)duration
{
    CATransition *push = [self push:subtype];
    push.duration = duration;
    return push;
}

- (CATransition*)fade
{
    return [self addTransitionWithType:kCATransitionFade subtype:nil];
}

- (CATransition*)fadeWithDuration:(CFTimeInterval)duration;
{
    CATransition *fade = [self fade];
    fade.duration = duration;
    return fade;
}

@end
