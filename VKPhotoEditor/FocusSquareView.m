//
//  FocusSquareView.m
//  VKPhotoEditor
//
//  Created by asya on 10/29/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "FocusSquareView.h"

typedef void (^DrawObject)();

@implementation FocusSquareView {
    UIColor *lineColor;
}

- (void)awakeFromNib
{
    lineColor = self.backgroundColor;
    [self setBackgroundColor:[UIColor clearColor]];
}

- (void)drawInContext:(CGContextRef)ctx lineWidth:(CGFloat)width object:(DrawObject)drawObject
{
    CGContextSetLineWidth(ctx, width);
    
    CGContextBeginPath(ctx);
    
    drawObject();
    
    CGContextClosePath(ctx);
    CGContextStrokePath(ctx);
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(ctx, lineColor.CGColor);
    CGContextSetLineWidth(ctx, 2.0);
    
    [self drawInContext:ctx lineWidth:2.0 object:^(){
        CGContextMoveToPoint   (ctx, CGRectGetMinX(rect), CGRectGetMinY(rect));
        CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMinY(rect));
        CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMaxY(rect));
        CGContextAddLineToPoint(ctx, CGRectGetMinX(rect), CGRectGetMaxY(rect));
    }];
    
    [self drawInContext:ctx lineWidth:1.0 object:^(){
        CGContextMoveToPoint   (ctx, CGRectGetMinX(rect), CGRectGetMidY(rect));
        CGContextAddLineToPoint(ctx, CGRectGetWidth(rect)/10, CGRectGetMidY(rect));
    }];
    
    [self drawInContext:ctx lineWidth:1.0 object:^(){
        CGContextMoveToPoint   (ctx, CGRectGetMidX(rect), CGRectGetMinY(rect));
        CGContextAddLineToPoint(ctx, CGRectGetMidX(rect),CGRectGetHeight(rect)/10);
    }];
    
    [self drawInContext:ctx lineWidth:1.0 object:^(){
        CGContextMoveToPoint   (ctx, CGRectGetMaxX(rect) - CGRectGetWidth(rect)/10, CGRectGetMidY(rect));
        CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMidY(rect));
    }];

    [self drawInContext:ctx lineWidth:1.0 object:^(){
        CGContextMoveToPoint   (ctx, CGRectGetMidX(rect), CGRectGetMaxY(rect) - CGRectGetHeight(rect)/10);
        CGContextAddLineToPoint(ctx, CGRectGetMidX(rect), CGRectGetMaxY(rect));
    }];
}

@end
