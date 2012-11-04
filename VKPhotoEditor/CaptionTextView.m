//
//  StretchableTextField.m
//  VKPhotoEditor
//
//  Created by asya on 10/31/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "CaptionTextView.h"
#import "FlexibleButton.h"
#import "FlexibleTextField.h"
#import "VKHighlightTextView.h"

#define SIZE_STEP 2
#define MAX_FONT_SIZE 28
#define MIN_FONT_SIZE 14

@interface CaptionTextView ()<UITextViewDelegate>
- (IBAction)addCaption:(id)sender;
@end

@implementation CaptionTextView {
    IBOutlet FlexibleButton *captionButton;
    IBOutlet VKHighlightTextView *textView;
}

@synthesize delegate, captionButtonTitle;

- (void)awakeFromNib
{
    captionButton.bgImagecaps = CGSizeMake(23, 20);
    
    textView.font = [UIFont fontWithName:@"Lobster" size:MAX_FONT_SIZE];
    textView.isEditable = YES;
}


- (IBAction)addCaption:(id)sender
{
    captionButton.hidden = YES;
    textView.editable = YES;
    [textView becomeFirstResponder];
}

#pragma mark - properties

- (NSString *)caption
{
    return textView.text;
}

- (void)setCaptionButtonTitle:(NSString *)title
{
    captionButtonTitle = title;
    
    if (captionButtonTitle) {
        [captionButton setTitle:captionButtonTitle forState:UIControlStateNormal];
    }
}

#pragma mark - UITextFieldDelegate

- (void)textViewDidBeginEditing:(UITextView *)tv
{
    [delegate captionTextViewDidStartEditing:self];
}

- (BOOL)textView:(UITextView *)tv shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [tv resignFirstResponder];
        captionButton.hidden = tv.text.length;
        [delegate captionTextViewDidFinishEditing:self];
        return NO;
    }
    
    return YES;
}

@end
