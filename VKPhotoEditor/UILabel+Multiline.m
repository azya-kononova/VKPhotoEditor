//
//  UILabel+Multiline.m
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/6/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "UILabel+Multiline.h"

@implementation UILabel (Multiline)

+ (void)resizeFontForLabel:(UILabel*)aLabel maxSize:(int)maxSize minSize:(int)minSize {

    UIFont *font = aLabel.font;
    
    for(int i = maxSize; i > 10; i--) {
        font = [font fontWithSize:i];
        CGSize constraintSize = CGSizeMake(aLabel.frame.size.width, MAXFLOAT);
        
        CGSize labelSize = [aLabel.text sizeWithFont:font constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
        if(labelSize.height <= aLabel.frame.size.height)
            break;
    }
    aLabel.font = font;
}

@end
