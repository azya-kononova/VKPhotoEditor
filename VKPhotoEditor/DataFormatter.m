#import "DataFormatter.h"

@implementation DataFormatter

+ (NSString *)formatDate:(NSDate *)date useLongStyle:(BOOL)useLongStyle showDate:(BOOL)showDate showTime:(BOOL)showTime
{
    static NSDateFormatter *dateFormatter;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        dateFormatter = [NSDateFormatter new];
    });
    
    dateFormatter.dateStyle = (useLongStyle) ? NSDateFormatterLongStyle : NSDateFormatterShortStyle;
    dateFormatter.dateStyle = (showDate) ? dateFormatter.dateStyle : NSDateFormatterNoStyle;
    dateFormatter.timeStyle = (showTime) ? NSDateFormatterShortStyle : NSDateFormatterNoStyle;
    
    return [dateFormatter stringFromDate:date];
}


@end
