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

@synthesize captionButtonTitle, delegate;

- (void)awakeFromNib
{
    captionButton.bgImagecaps = CGSizeMake(23, 20);
    if (captionButtonTitle) {
        [captionButton setTitle:captionButtonTitle forState:UIControlStateNormal];
    }
    
    textView.font = [UIFont fontWithName:@"Lobster" size:MAX_FONT_SIZE];
    
    [textView addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew) context:NULL];
    textView.isEditable = YES;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    UITextView *tv = object;
    CGFloat topCorrect = (tv.bounds.size.height - tv.contentSize.height);
    topCorrect = topCorrect < 0.0 ? 0.0 : topCorrect;
    tv.contentOffset = CGPointMake(0, -topCorrect);
}

- (IBAction)addCaption:(id)sender
{
    captionButton.hidden = YES;
    textView.editable = YES;
    [textView becomeFirstResponder];
}

- (NSString *)caption
{
    return textView.text;
}

- (void)setCaptionColor:(UIColor *)captionColor
{
    textView.textColor = captionColor;
}

- (UIColor *)captionColor
{
    return textView.textColor;
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
