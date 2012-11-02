#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

FOUNDATION_EXPORT NSString *const kVKHighlightViewTypeHashTag;

@interface VKHighlightTextView : UITextView
@property (nonatomic, assign) BOOL isEditable;
@end
