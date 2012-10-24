//
//  This content is released under the MIT License: http://www.opensource.org/licenses/mit-license.html
//

#import "NSString+Web.h"

@implementation NSString (Web)

- (NSString*)urlEncode
{
	return [self urlEncode:nil leave:nil];
}

- (NSString*)urlEncode:(NSString*)forceEscape
{
    return [self urlEncode:forceEscape leave:nil];
}

- (NSString*)urlEncode:(NSString*)forceEscape leave:(NSString*)leaveUnescaped
{
	return CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)self, (__bridge CFStringRef)leaveUnescaped, (__bridge CFStringRef)forceEscape, kCFStringEncodingUTF8));
}

- (NSString*)urlDecode
{
    return [self urlDecode:@""];
}

- (NSString*)urlDecode:(NSString*)leaveEscaped
{
    return CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapes(NULL, (__bridge CFStringRef)self, (__bridge CFStringRef)leaveEscaped));
}

@end
