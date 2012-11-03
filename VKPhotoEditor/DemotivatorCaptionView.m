//
//  DemotivatorOverlayView.m
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/6/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "DemotivatorCaptionView.h"

@interface DemotivatorCaptionView () {
    IBOutlet UIImageView *templateImageView;
}
@end

@implementation DemotivatorCaptionView

#pragma mark - CaptionTemplateProtocol

- (UIColor *)textColor
{
    return [UIColor whiteColor];
}

- (UIImage *)templateImage
{
    return templateImageView.image;
}

@end
