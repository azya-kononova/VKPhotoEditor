//
//  This content is released under the MIT License: http://www.opensource.org/licenses/mit-license.html
//

#import "FileUpload.h"
#import <UIKit/UIKit.h>

@implementation FileUpload
@synthesize data;
@synthesize fileName;
@synthesize contentType;

- (id)initWithData:(NSData*)_data fileName:(NSString*)_fileName contentType:(NSString*)_contentType
{
	if (self = [super init]) {
        data = _data;
        fileName = _fileName;
        contentType = _contentType;
	}
	return self;
}

+ (FileUpload*)fileUploadWithJPEGImage:(UIImage*)image withFileName:(NSString*)filename quality:(float)quality
{
    return [self fileUploadWithData:UIImageJPEGRepresentation(image, quality) withFileName:filename contentType:@"image/jpeg"];
}

+ (FileUpload*)fileUploadWithPNGImage:(UIImage*)image withFileName:(NSString*)filename
{
    return [self fileUploadWithData:UIImagePNGRepresentation(image) withFileName:filename contentType:@"image/png"];
}

+ (FileUpload*)fileUploadWithData:(NSData*)data withFileName:(NSString*)filename contentType:(NSString*)contentType
{
    return [[FileUpload alloc] initWithData:data fileName:filename contentType:contentType];
}

@end