//
//  RightTriangleView.m
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 11/3/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "RightTriangleView.h"

@implementation RightTriangleView{
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
    CGContextMoveToPoint   (ctx, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMidY(rect));
    CGContextAddLineToPoint(ctx, CGRectGetMinX(rect), CGRectGetMaxY(rect));
    CGContextClosePath(ctx);
    
    CGContextSetRGBFillColor(ctx, red, green, blue, alpha);
    CGContextFillPath(ctx);
}
@end
