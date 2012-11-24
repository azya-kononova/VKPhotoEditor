#import "UIView+NIB.h"

@class XIBLoaderView;

@protocol XIBLoaderViewDelegate

- (void)xibLoaderView:(XIBLoaderView*)xibLoaderView replacedWithView:(UIView*)replacementView userParams:(NSArray*)userParams;

@end


@interface XIBLoaderView : UILabel {

}
@property (assign) IBOutlet id fileOwner;
@property (assign) IBOutlet id<XIBLoaderViewDelegate> delegate;

@end
