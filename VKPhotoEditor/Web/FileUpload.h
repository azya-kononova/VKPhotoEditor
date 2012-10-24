//
//  This content is released under the MIT License: http://www.opensource.org/licenses/mit-license.html
//

#import <Foundation/Foundation.h>

@class UIImage;

@interface FileUpload : NSObject
@property (nonatomic, strong, readonly) NSData *data;
@property (nonatomic, strong, readonly) NSString *fileName;
@property (nonatomic, strong, readonly) NSString *contentType;

+ (FileUpload*)fileUploadWithJPEGImage:(UIImage*)image withFileName:(NSString*)filename quality:(float)quality;
+ (FileUpload*)fileUploadWithPNGImage:(UIImage*)image withFileName:(NSString*)filename;
+ (FileUpload*)fileUploadWithData:(NSData*)data withFileName:(NSString*)filename contentType:(NSString*)contentType;

@end
