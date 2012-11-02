//
//  UITextView+Resize.h
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 11/2/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextView (Resize)

-(BOOL)sizeFontToFitMinSize:(float)aMinFontSize maxSize:(float)aMaxFontSize;

@end
