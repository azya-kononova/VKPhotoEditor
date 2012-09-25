//
//  CaptionView.m
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 9/23/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "CaptionView.h"
#import "CustomSegmentView.h"


@interface CaptionView () <UITextFieldDelegate>
@end

@implementation CaptionView
@synthesize fontSegmentView;
@synthesize textField;

- (void)awakeFromNib
{
    fontSegmentView.segmentSize = CGSizeMake(50, 30);
    
    fontSegmentView.leftBgImage = [[UIImage imageNamed:@"FontTabLeft"] stretchableImageWithLeftCapWidth:20 topCapHeight:0];
    fontSegmentView.leftBgImageSelected = [[UIImage imageNamed:@"FontTabLeft_active"] stretchableImageWithLeftCapWidth:20 topCapHeight:5];
    fontSegmentView.rightBgImage = [[UIImage imageNamed:@"FontTabRight"] stretchableImageWithLeftCapWidth:20 topCapHeight:5];
    fontSegmentView.rightBgImageSelected = [[UIImage imageNamed:@"FontTabRight_active"] stretchableImageWithLeftCapWidth:20 topCapHeight:5];
    fontSegmentView.bgImage = [[UIImage imageNamed:@"FontTab"] stretchableImageWithLeftCapWidth:10 topCapHeight:5];
    fontSegmentView.bgImageSelected = [[UIImage imageNamed:@"FontTab_Active"] stretchableImageWithLeftCapWidth:10 topCapHeight:5];

    [fontSegmentView addItems:[NSArray arrayWithObjects:@"Aa", @"Aa", @"Aa", @"Aa",  @"Aa",  @"Aa", nil]];
    [fontSegmentView setFont:[UIFont fontWithName:@"Freehand521 BT" size:17.0] forSegmentAtIndex:0];
    [fontSegmentView setFont:[UIFont fontWithName:@"Ballpark" size:17.0] forSegmentAtIndex:1];
    [fontSegmentView setFont:[UIFont fontWithName:@"Lobster 1.4" size:17.0] forSegmentAtIndex:2];
    [fontSegmentView setFont:[UIFont fontWithName:@"CollegiateHeavyOutline" size:17.0] forSegmentAtIndex:3];
    [fontSegmentView setFont:[UIFont fontWithName:@"Complete in Him" size:20.0] forSegmentAtIndex:4];
    [fontSegmentView setFont:[UIFont fontWithName:@"Helvetica" size:17.0] forSegmentAtIndex:5];
    
    fontSegmentView.selectedSegmentIndex = 0;
}

#pragma mark - actions

- (IBAction)textFieldReturn:(id)sender
{
    [sender resignFirstResponder];
}

#pragma mark - UITextField delegate


@end
