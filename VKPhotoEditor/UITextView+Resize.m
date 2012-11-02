//
//  UITextView+Resize.m
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 11/2/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "UITextView+Resize.h"
#define kMaxFieldHeight 1000

@implementation UITextView (Resize)


-(BOOL)sizeFontToFitMinSize:(float)aMinFontSize maxSize:(float)aMaxFontSize {
    
    float fudgeFactor = 16.0;
    float fontSize = aMaxFontSize;
    
    self.font = [self.font fontWithSize:fontSize];
    
    CGSize tallerSize = CGSizeMake(self.frame.size.width-fudgeFactor,kMaxFieldHeight);
    CGSize stringSize = [self.text sizeWithFont:self.font constrainedToSize:tallerSize lineBreakMode:UILineBreakModeWordWrap];
    
    while (stringSize.height >= self.frame.size.height) {
        
        if (fontSize <= aMinFontSize) // it just won't fit, ever
            return NO;
        
        fontSize -= 1.0;
        self.font = [self.font fontWithSize:fontSize];
        tallerSize = CGSizeMake(self.frame.size.width-fudgeFactor,kMaxFieldHeight);
        stringSize = [self.text sizeWithFont:self.font constrainedToSize:tallerSize lineBreakMode:UILineBreakModeWordWrap];
    }
    
    return YES; 
}

@end
