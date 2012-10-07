//
//  CaptionView.m
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 9/23/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "CaptionView.h"
#import "CustomSegmentView.h"


@interface CaptionView () <UITextFieldDelegate, CustomSegmentViewDelegate>
@end

@implementation CaptionView {
    NSArray *fonts;
}
@synthesize fontSegmentView;
@synthesize textField;
@synthesize delegate;

- (void)awakeFromNib
{
    fontSegmentView.segmentSize = CGSizeMake(50, 30);
    
    fontSegmentView.leftBgImage = [[UIImage imageNamed:@"FontTabLeft"] stretchableImageWithLeftCapWidth:20 topCapHeight:0];
    fontSegmentView.leftBgImageSelected = [[UIImage imageNamed:@"FontTabLeft_Active"] stretchableImageWithLeftCapWidth:20 topCapHeight:5];
    fontSegmentView.rightBgImage = [[UIImage imageNamed:@"FontTabRight"] stretchableImageWithLeftCapWidth:20 topCapHeight:5];
    fontSegmentView.rightBgImageSelected = [[UIImage imageNamed:@"FontTabRight_Active"] stretchableImageWithLeftCapWidth:20 topCapHeight:5];
    fontSegmentView.bgImage = [[UIImage imageNamed:@"FontTab"] stretchableImageWithLeftCapWidth:10 topCapHeight:5];
    fontSegmentView.bgImageSelected = [[UIImage imageNamed:@"FontTab_Active"] stretchableImageWithLeftCapWidth:10 topCapHeight:5];

    [fontSegmentView addItems:[NSArray arrayWithObjects:@"Aa", @"Aa", @"Aa", @"Aa",  @"Aa",  @"Aa", nil]];
    
    fonts = [NSArray arrayWithObjects:[UIFont fontWithName:@"Freehand521 BT" size:17.0],
             [UIFont fontWithName:@"Ballpark" size:17.0],
             [UIFont fontWithName:@"Lobster 1.4" size:17.0],
             [UIFont fontWithName:@"CollegiateHeavyOutline" size:17.0],
             [UIFont fontWithName:@"Complete in Him" size:20.0],
             [UIFont fontWithName:@"Helvetica" size:17.0], nil];
    
    for (UIFont *font in fonts) {
        [fontSegmentView setFont:font forSegmentAtIndex:[fonts indexOfObject:font]];
    }
    
    fontSegmentView.delegate = self;
    fontSegmentView.selectedSegmentIndex = 0;
    
    [textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}

- (NSString*)caption
{
    return textField.text;
}

- (void)setCaption:(NSString *)_caption
{
    textField.text = _caption;
}

- (UIFont*)selectedFont
{
    return [fonts objectAtIndex:fontSegmentView.selectedSegmentIndex];
}

- (void)textFieldDidChange:(id)textField
{
    [delegate captionViewdidChange:self];
}

#pragma mark - actions

- (IBAction)textFieldReturn:(id)sender
{
    [sender resignFirstResponder];
}

#pragma mark - CustomSegmentViewDelegate

- (void)segmentView:(CustomSegmentView *)segmentView selectSegmentAtIndex:(NSInteger)index
{
    [delegate captionView:self didSetFont:[fonts objectAtIndex:index]];
}

- (BOOL)resignFirstResponder
{
    return [textField resignFirstResponder];
}

@end
