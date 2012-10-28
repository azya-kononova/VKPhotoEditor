#import <Foundation/Foundation.h>

@interface DataFormatter : NSObject

+ (NSString *)formatDate:(NSDate *)date useLongStyle:(BOOL)useLongStyle showDate:(BOOL)showDate showTime:(BOOL)showTime;

@end
