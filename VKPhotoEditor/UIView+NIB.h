//
//  This content is released under the MIT License: http://www.opensource.org/licenses/mit-license.html
//

#import <UIKit/UIKit.h>

@interface UIView (NIB)

+ (id)loadFromNIB;
+ (id)loadFromNIBWithOwner:(id)owner;
+ (id)loadFromNIB:(NSString*)nibName;
+ (id)loadFromNIB:(NSString*)nibName owner:(id)owner;

@end
