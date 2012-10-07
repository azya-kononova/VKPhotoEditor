//
//  CALayer+Animations.h
//  Mascotte
//
//  Created by Sergey Martynov on 26.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CALayer (Animations)

- (CATransition*)addTransitionWithType:(NSString*)type subtype:(NSString*)subtype;

- (CATransition*)push:(NSString*)subtype;
- (CATransition*)push:(NSString*)subtype duration:(CFTimeInterval)duration;

- (CATransition*)fade;
- (CATransition*)fadeWithDuration:(CFTimeInterval)duration;

@end
