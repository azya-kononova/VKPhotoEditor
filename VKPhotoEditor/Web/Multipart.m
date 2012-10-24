//
//  Multipart.m
//  Radario
//
//  Created by Sergey Martynov on 09.02.12.
//  Copyright (c) 2012 vladimir.chernokulsky@gmail.com. All rights reserved.
//

#import "Multipart.h"

#define BOUNDARY() [mdata appendData:boundaryData]
#define STR(cstr) [mdata appendBytes:cstr length:sizeof(cstr)-1]
#define DASH() STR("--")
#define NEWLINE() STR("\r\n")
#define FIELD(field) [mdata appendData:[field dataUsingEncoding:NSUTF8StringEncoding]]

@implementation Multipart {
    NSData *boundaryData;
    NSMutableData *mdata;
}
@synthesize boundary;

- (id)initWithBoundary:(NSString*)_boundary
{
    if (self = [super init]) {
        boundary = _boundary;
        boundaryData = [boundary dataUsingEncoding:NSUTF8StringEncoding];
    }
    return self;
}

- (void)appendContentName:(NSString*)name filename:(NSString*)filename contentType:(NSString*)contentType data:(NSData*)data
{
    if (!mdata) {
        mdata = [NSMutableData new];
        DASH(); BOUNDARY();
        NEWLINE();
    } else {
        NEWLINE();
        DASH(); BOUNDARY();
        NEWLINE();
    }
    STR("Content-Disposition: form-data; name=\""); FIELD(name); STR("\"");
    if (filename) {
        STR("; filename=\""); FIELD(filename); STR("\"");
        NEWLINE();
        STR("Content-Type: "); FIELD(contentType);
        NEWLINE();
        STR("Content-Transfer-Encoding: binary");
    }
    NEWLINE();
    NEWLINE();
    [mdata appendData:data];
}

- (void)appendName:(NSString*)name value:(id)value
{
    if ([value isKindOfClass:[FileUpload class]]) {
        [self appendName:name fileUpload:value];
    } else {
        [self appendContentName:name filename:nil contentType:nil data:[[value description] dataUsingEncoding:NSUTF8StringEncoding]];
    }
}

- (void)appendName:(NSString*)name fileUpload:(FileUpload*)upload
{
    NSString *filename = upload.fileName ? upload.fileName : name;
    [self appendContentName:name filename:filename contentType:upload.contentType data:upload.data];
}

- (NSData*)getData
{
    NEWLINE();
    DASH(); BOUNDARY(); DASH();
    NEWLINE();
    return mdata;
}

@end
