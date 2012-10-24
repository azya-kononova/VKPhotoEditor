//
//  This content is released under the MIT License: http://www.opensource.org/licenses/mit-license.html
//

#import <Foundation/Foundation.h>

@interface NSString (Web)

- (NSString*)urlEncode;
- (NSString*)urlEncode:(NSString*)forceEscape;
- (NSString*)urlEncode:(NSString*)forceEscape leave:(NSString*)leaveUnescaped;

- (NSString*)urlDecode;
- (NSString*)urlDecode:(NSString*)leaveEscaped;

@end
