//
//  This content is released under the MIT License: http://www.opensource.org/licenses/mit-license.html
//

#import <UIKit/UIKit.h>

@class RemoteImage;

@protocol RemoteImageDelegate <NSObject>
- (void)remoteImageDidFinishLoading:(RemoteImage*)remoteImage;
- (void)remoteImage:(RemoteImage*)remoteImage loadingFailedWithError:(NSError*)error;
@end


@interface RemoteImage : NSObject {
	id<RemoteImageDelegate> delegate;
	NSURL *imageUrl;
	NSURLConnection *activeConnection;
	NSMutableData *connectionData;
	NSError *lastError;
	NSData *imageData;
	UIImage *image;
}
@property (strong, nonatomic) id<RemoteImageDelegate> delegate;
@property (strong, nonatomic, readonly) NSURL *imageUrl;
@property (strong, nonatomic, readonly) NSData *imageData;
@property (strong, nonatomic, readonly) UIImage *image;
@property (strong, nonatomic, readonly) NSError *lastError;
@property (nonatomic, assign, readonly) BOOL isLoad;
@property (nonatomic, assign, readonly) BOOL isLoading;
@property (nonatomic, assign) float progress;

+ (RemoteImage*)remoteImageWithURL:(NSURL*)url;

- (id)initWithURL:(NSURL*)url;
- (id)initWithImage:(UIImage*)image;

- (void)startLoading;
- (void)stopLoading;
- (void)clear:(BOOL)full;

@end
