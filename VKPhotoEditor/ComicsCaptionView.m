//
//  CloudOverlayView.m
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/6/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "ComicsCaptionView.h"
#import "UILabel+Multiline.h"

@interface ComicsCaptionView () {
    IBOutlet UIImageView *templateImageView;
}
@end

@implementation ComicsCaptionView

#pragma mark - CaptionTemplateProtocol

- (UIImage *)templateImage
{
    return templateImageView.image;
}

@end

