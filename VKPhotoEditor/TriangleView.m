//
//  TriangleView.m
//  Mascotte
//
//  Created by Ekaterina Petrova on 8/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TriangleView.h"

@implementation TriangleView {
    CGFloat red, green, blue, alpha;
}

- (void)awakeFromNib
{
    [self.backgroundColor getRed:&red green:&green blue:&blue alpha:&alpha];
    [self setBackgroundColor:[UIColor clearColor]];
}

-(void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextBeginPath(ctx);
    CGContextMoveToPoint   (ctx, CGRectGetMinX(rect), CGRectGetMaxY(rect));  // top left
    CGContextAddLineToPoint(ctx, CGRectGetMidX(rect), CGRectGetMinY(rect));  // mid right
    CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMaxY(rect));  // bottom left
    CGContextClosePath(ctx);
    
    CGContextSetRGBFillColor(ctx, red, green, blue, alpha);
    CGContextFillPath(ctx);
}
@end
