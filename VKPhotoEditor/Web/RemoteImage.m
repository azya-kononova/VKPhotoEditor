//
//  This content is released under the MIT License: http://www.opensource.org/licenses/mit-license.html
//

#import "RemoteImage.h"

@interface  RemoteImage ()
@property (nonatomic, assign) BOOL isLoad;
@end

@implementation RemoteImage
@synthesize delegate;
@synthesize imageUrl;
@synthesize imageData;
@synthesize lastError;
@synthesize isLoad;


+ (RemoteImage*)remoteImageWithURL:(NSURL*)url
{
    return [[self alloc] initWithURL:url];
}

- (id)initWithURL:(NSURL*)url
{
	if (self = [super init]) {
        imageUrl = url;
    }
	return self;
}

- (id)initWithImage:(UIImage*)_image
{
	if (self = [super init]) {
        image = _image;
    }
	return self;
}


- (NSData*)imageData
{
    if (!imageData && image) {
        imageData = UIImagePNGRepresentation(image);
    }
    return imageData;
}

- (UIImage*)image
{
	if (!image && imageData) {
		image = [[UIImage alloc] initWithData:imageData];
	}
	return image;
}

- (void)startLoading
{
	if (image || imageData || activeConnection) return;
	NSURLRequest *request = [NSURLRequest requestWithURL:imageUrl];
	activeConnection = [NSURLConnection connectionWithRequest:request delegate:self];
	[activeConnection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[activeConnection start];
}

- (void)stopLoading
{
	[activeConnection cancel];
	activeConnection = nil;
	connectionData = nil;
}

- (void)clear:(BOOL)full
{
	image = nil;
	if (full) {
		imageData = nil;
	}
}

#pragma mark URL Connection Delegate

- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data
{
	if (!connectionData) {
		connectionData = [[NSMutableData alloc] initWithData:data];
	} else {
		[connectionData appendData:data];
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	imageData = connectionData;
	[self stopLoading];
    self.isLoad = YES;
    
	[delegate remoteImageDidFinishLoading:self];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	[self stopLoading];
	[delegate remoteImage:self loadingFailedWithError:error];
}

@end
