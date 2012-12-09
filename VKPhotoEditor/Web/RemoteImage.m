//
//  This content is released under the MIT License: http://www.opensource.org/licenses/mit-license.html
//

#import "RemoteImage.h"

@interface  RemoteImage ()
@property (nonatomic, assign) BOOL isLoad;
@end

@implementation RemoteImage {
    NSInteger expectedSize;
}
@synthesize delegate;
@synthesize imageUrl;
@synthesize imageData;
@synthesize lastError;
@synthesize isLoad;
@synthesize progress;
@synthesize isLoading;
@synthesize image;

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

- (void)startLoading
{
	if (image || imageData || activeConnection || !imageUrl) return;
    
    isLoading = YES;
    
	NSURLRequest *request = [NSURLRequest requestWithURL:imageUrl];
    activeConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
	[activeConnection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
	[activeConnection start];
}

- (void)stopLoading
{
	[activeConnection cancel];
	activeConnection = nil;
	connectionData = nil;
    isLoading = NO;
}

- (void)clear:(BOOL)full
{
	image = nil;
	if (full) {
		imageData = nil;
	}
}

#pragma mark URL Connection Delegate

- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse*)_response
{
    expectedSize = _response.expectedContentLength;
}

- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data
{
	if (!connectionData) {
		connectionData = [[NSMutableData alloc] initWithData:data];
	} else {
		[connectionData appendData:data];
	}
    
    self.progress = expectedSize > 0 ? (float)connectionData.length / (float)expectedSize : 0;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	imageData = connectionData;
	[self stopLoading];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *img = [[UIImage alloc] initWithData:imageData];
        dispatch_async(dispatch_get_main_queue(), ^{
            image = img;
            self.isLoad = YES;
            [delegate remoteImageDidFinishLoading:self];
        });
    });
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	[self stopLoading];
	[delegate remoteImage:self loadingFailedWithError:error];
}

@end
