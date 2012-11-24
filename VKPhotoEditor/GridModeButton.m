//
//  GridButton.m
//  VKPhotoEditor
//
//  Created by asya on 11/24/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "GridModeButton.h"

@implementation GridModeButton 

@synthesize delegate;

- (IBAction)switchGridMode:(id)sender
{
    UIButton *button = (UIButton *)sender;
    button.selected = !button.selected;
    
    [delegate gridModeButtonDidSwitchMode:self];
}

@end
