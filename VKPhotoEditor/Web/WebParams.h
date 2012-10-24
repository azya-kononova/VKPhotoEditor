//
//  This content is released under the MIT License: http://www.opensource.org/licenses/mit-license.html
//

#import "FileUpload.h"

@interface WebParams : NSObject
@property (nonatomic, readonly) NSString *queryString;
@property (nonatomic, readonly) BOOL multipart;
#if defined (SBJSON)
@property (nonatomic, readonly) NSData *jsonData;
#endif
@property (nonatomic, readonly) NSData *formData;
@property (nonatomic, readonly) NSData *multipartData;

@property (nonatomic, readonly) NSData *postData;

@property (nonatomic, readonly) NSString *jsonContentType;
@property (nonatomic, readonly) NSString *formContentType;
@property (nonatomic, readonly) NSString *multipartContentType;
@property (nonatomic, readonly) NSString *postContentType;

- (id)initWithDictionary:(NSDictionary*)dictionary;

- (void)setParam:(id)_param forKey:(id)key;
- (void)addParam:(id)_param forKey:(id)key;

- (NSURL*)appendToURL:(NSURL*)url;

@end
