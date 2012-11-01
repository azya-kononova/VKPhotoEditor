#import "VKHighlightView.h"

#define EMPTY @""

NSString *const kVKHighlightViewTypeHashTag = @"hash_tag";

@interface VKHighlightView() {
    id internalDelegate;
}
- (NSAttributedString*)highlightText:(NSAttributedString*)stringIn;
- (NSRange)visibleRangeOfTextView:(UITextView*)textView;
@end

@interface RegexHighlightViewDelegate : NSObject<UITextViewDelegate>
@end

@implementation RegexHighlightViewDelegate
//Update the syntax highlighting if the text gets changed or the scrollview gets updated
- (void)textViewDidChange:(UITextView *)textView {
    [textView setNeedsDisplay];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[scrollView setNeedsDisplay];
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    //Only update the text if the text changed
//	NSString* newText = [text stringByReplacingOccurrencesOfString:@"\t" withString:@"    "];
//	if(![newText isEqualToString:text]) {
//		textView.text = [textView.text stringByReplacingCharactersInRange:range withString:newText];
//		return NO;
//	}
//	return YES;
}
@end

static CGFloat MARGIN = 8;

@implementation VKHighlightView {
    NSDictionary *highlightTheme;
    NSDictionary *definitions;
}

- (void)_init
{
    self.textColor = [UIColor clearColor];
    self.delegate = (internalDelegate=[[RegexHighlightViewDelegate alloc] init]);
    highlightTheme = [NSDictionary dictionaryWithObjectsAndKeys:
                      [UIColor colorWithRed:149.0/255 green:200.0/255 blue:255.0/255 alpha:1],kVKHighlightViewTypeHashTag, nil];
    definitions = [NSDictionary dictionaryWithObjectsAndKeys:@"\\s*#\\w+", kVKHighlightViewTypeHashTag, nil];
}

-(id)init {
    self = [super init];
    if(self) {
    }
    return self;
}

-(id)initWithCoder:(NSCoder*)decoder {
    self = [super initWithCoder:decoder];
    if (self) {
        [self _init];
    }
    return self;
}
-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _init];
    }
    return self;
    
}

-(void)drawRect:(CGRect)rect {
    if(self.text.length<=0) {
        self.text = EMPTY;
        return;
    }

    //Prepare View for drawing
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(context,CGAffineTransformIdentity);
    CGContextTranslateCTM(context,0,([self bounds]).size.height);
    CGContextScaleCTM(context,1.0,-1.0);

    //Get the view frame size
    CGSize size = self.frame.size;
    
    //Determine default text color
    UIColor* textColor = self.textColor;
    
    CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)self.font.fontName,self.font.pointSize,NULL);
    
    CTTextAlignment alignment = kCTTextAlignmentCenter;
    CTParagraphStyleSetting _settings[] = {    {kCTParagraphStyleSpecifierAlignment, sizeof(alignment), &alignment} };
    CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(_settings, sizeof(_settings) / sizeof(_settings[0]));
    
    NSDictionary* attributes = [NSDictionary dictionaryWithObjectsAndKeys:(__bridge id)font,(NSString*)kCTFontAttributeName,(__bridge id)textColor.CGColor,(NSString*)kCTForegroundColorAttributeName,(__bridge id)paragraphStyle,(NSString*)kCTParagraphStyleAttributeName,nil];
                
    //Create path to work with a frame with applied margins
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path,NULL,CGRectMake(MARGIN+0.0,(-self.contentOffset.y+0),(size.width-2*MARGIN),(size.height+self.contentOffset.y-MARGIN)));
        
    //Create attributed string, with applied syntax highlighting
    CFAttributedStringRef attributedString = (__bridge CFAttributedStringRef)[self highlightText:[[NSAttributedString alloc] initWithString:self.text attributes:attributes]];
    
    //Draw the frame
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedString);
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0,CFAttributedStringGetLength(attributedString)),path,NULL);
    CTFrameDraw(frame,context);
        CFRelease(paragraphStyle);
}

-(NSRange)visibleRangeOfTextView:(UITextView *)textView {
    CGRect bounds = textView.bounds;
    //Get start and end bouns for text position
    UITextPosition *start = [textView characterRangeAtPoint:bounds.origin].start,*end = [textView characterRangeAtPoint:CGPointMake(CGRectGetMaxX(bounds),CGRectGetMaxY(bounds))].end;
    //Make a range out of it and return
    return NSMakeRange([textView offsetFromPosition:textView.beginningOfDocument toPosition:start],[textView offsetFromPosition:start toPosition:end]);
}

-(NSAttributedString*)highlightText:(NSAttributedString*)attributedString {
    //Create a mutable attribute string to set the highlighting
    NSString* string = attributedString.string; NSRange range = NSMakeRange(0,[string length]);
    NSMutableAttributedString* coloredString = [[NSMutableAttributedString alloc] initWithAttributedString:attributedString];
    
    
    [coloredString addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)[UIColor whiteColor].CGColor range:range];
    
    //For each definition entry apply the highlighting to matched ranges
    for(NSString* key in definitions) {
        NSString* expression = [definitions objectForKey:key];
        if(!expression||[expression length]<=0) continue;
        NSArray* matches = [[NSRegularExpression regularExpressionWithPattern:expression options:NSRegularExpressionDotMatchesLineSeparators error:nil] matchesInString:string options:0 range:range];
        for(NSTextCheckingResult* match in matches) {
            UIColor* textColor = nil;
            //Get the text color, if it is a custom key and no color was defined, choose black
            if(!(textColor=[highlightTheme objectForKey:key]))
                textColor = [UIColor blackColor];
            [coloredString addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)textColor.CGColor range:[match rangeAtIndex:0]];                            
        }
    }
    
    return coloredString.copy;
}

@end