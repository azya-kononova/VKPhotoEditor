//
//  This content is released under the MIT License: http://www.opensource.org/licenses/mit-license.html
//

#import <UIKit/UIKit.h>
#import "WebParams.h"
#import "NSString+Web.h"
#import "Multipart.h"
#if defined (SBJSON)
#import "SBJson.h"
#endif

#define IS_FILEUPLOAD(value) [value isKindOfClass:[FileUpload class]]

static NSString *encodeQueryField(NSString *value) {
	return [[value description] urlEncode:@"\"%;/?:@&=+$,[]#!'()*"];
}

typedef void (^Visitor)(NSString *name, id value);

static void visit(Visitor visitor, NSString *name, id value) {
    if ([value conformsToProtocol:@protocol(NSFastEnumeration)]) {
        for (id v in value) {
            visit(visitor, name, v);
        }
    } else {
        visitor(name, value);
    }
}

@implementation WebParams {
	NSMutableDictionary *params;
    NSString *_boundary;
}
@synthesize multipart;

- (id)initWithDictionary:(NSDictionary*)dictionary
{
    if (self = [super init]) {
        params = [NSMutableDictionary new];
        for (id key in dictionary) {
            [self addParam:[dictionary objectForKey:key] forKey:key];
        }
    }
	return self;
}

- (id)init
{
    if (self = [super init]) {
        params = [NSMutableDictionary new];
    }
    return self;
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"<%@: %@>", NSStringFromClass(self.class), params];
}

- (void)forEachParam:(Visitor)visitor
{
    for (NSString *name in params) {
        visit(visitor, name, [params objectForKey:name]);
    }
}

- (void)setParam:(id)param forKey:(id)key
{
	if (!param) return;
    [params removeObjectForKey:key];
    [self addParam:param forKey:key];
}

- (id)prepareValue:(id)value withName:(NSString*)name
{
    if ([value isKindOfClass:[UIImage class]]) {
        return [FileUpload fileUploadWithPNGImage:value withFileName:name];
    }
    if ([value isKindOfClass:[NSData class]]) {
        return [FileUpload fileUploadWithData:value withFileName:name contentType:@"application/octet-stream"];
    }
    return value;
}

- (void)addParam:(id)param forKey:(id)key
{
	if (!param) return;
    NSMutableArray *values = [NSMutableArray new];
    visit(^(NSString *name, id value) {
        value = [self prepareValue:value withName:name];
        multipart |= IS_FILEUPLOAD(value);
        [values addObject:value];
    }, key, param);
    if (![params objectForKey:key]) {
        [params setObject:values.count > 1 ? values : [values lastObject] forKey:key];
        return;
    }
	NSMutableArray *container = [params objectForKey:key];
    if (![container isKindOfClass:[NSArray class]]) {
        container = [NSMutableArray arrayWithObject:container];
    }
    [container addObjectsFromArray:values];
}

- (NSString*)queryString
{
	NSMutableString *queryString = [NSMutableString string];
    [self forEachParam:^(NSString *name, id value) {
        if (IS_FILEUPLOAD(value)) return;
        [queryString appendString:@"&"];
        [queryString appendString:encodeQueryField(name)];
        [queryString appendString:@"="];
        [queryString appendString:encodeQueryField(value)];
    }];
	if (queryString.length) {
		[queryString replaceCharactersInRange:NSMakeRange(0, 1) withString:@"?"];
	}
	return queryString;
}

- (NSString*)boundary
{
    if (!_boundary) {
        CFUUIDRef uuid = CFUUIDCreate(nil);
        _boundary = CFBridgingRelease(CFUUIDCreateString(NULL, uuid));
        CFRelease(uuid);
    }
    return _boundary;
}

- (NSString*)jsonContentType { return @"application/json"; }
- (NSString*)formContentType { return @"application/x-www-form-urlencoded"; }
- (NSString*)multipartContentType { return [NSString stringWithFormat:@"multipart/form-data; boundary=%@", self.boundary]; }
- (NSString*)postContentType { return multipart ? self.multipartContentType : self.formContentType; }

- (NSData*)postData
{
    return multipart ? self.multipartData : self.formData;
}

- (NSData*)multipartData
{
    Multipart *multi = [[Multipart alloc] initWithBoundary:self.boundary];
    [self forEachParam:^(NSString *name, id value) {
        [multi appendName:name value:value];
    }];
	return [multi getData];
}

- (NSData*)formData
{
	NSMutableString *queryString = (NSMutableString*)self.queryString;
	[queryString deleteCharactersInRange:NSMakeRange(0, 1)];
	return [queryString dataUsingEncoding:NSUTF8StringEncoding];
}

#if defined (SBJSON)
- (NSData*)jsonData
{
    return [[params JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
}
#endif

- (NSURL*)appendToURL:(NSURL*)url
{
	if (params.count == 0) return url;
	BOOL haveParams = [[url absoluteString] rangeOfString:@"?"].length > 0;
	NSMutableString *queryString = (NSMutableString*)self.queryString;
	[queryString replaceCharactersInRange:NSMakeRange(0, 1) withString:haveParams ? @"&" : @"?"];
	return [NSURL URLWithString:queryString relativeToURL:url];
}

@end
