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

@interface CaptionTextView ()<UITextFieldDelegate>
- (IBAction)addCaption:(id)sender;
@end

@implementation CaptionTextView {
    IBOutlet FlexibleButton *captionButton;
    IBOutlet UITextField *textField;
}

@synthesize captionButtonTitle, delegate;

- (void)awakeFromNib
{
    captionButton.bgImagecaps = CGSizeMake(23, 20);
    if (captionButtonTitle) {
        [captionButton setTitle:captionButtonTitle forState:UIControlStateNormal];
    }
    
    textField.font = [UIFont fontWithName:@"Lobster" size:28.0];
}

- (IBAction)addCaption:(id)sender
{
    captionButton.hidden = YES;
    textField.enabled = YES;
    [textField becomeFirstResponder];
}

- (NSString *)caption
{
    return textField.text;
}

- (void)setCaptionColor:(UIColor *)captionColor
{
    textField.textColor = captionColor;
}

- (UIColor *)captionColor
{
    return textField.textColor;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)_textField
{
    [_textField resignFirstResponder];
    captionButton.hidden = _textField.text.length;
    [delegate captionTextViewDidFinishEditing:self];
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)_textField
{
    [delegate captionTextViewDidStartEditing:self];
}

@end
