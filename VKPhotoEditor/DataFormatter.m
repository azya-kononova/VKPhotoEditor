#import "DataFormatter.h"

@implementation DataFormatter

+ (NSString *)formatRelativeDate:(NSDate *)date
{
    static NSDateFormatter *dateFormatter;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        dateFormatter = [NSDateFormatter new];
    });
    
    NSInteger desiredComponents = NSDayCalendarUnit;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:desiredComponents fromDate:date toDate:[NSDate date] options:0];
    
    NSString *day = @"";
    if ([components day] == 0)
        day = @"'Today at' ";
    else if ([components day] == 1)
        day = @"'Yesterday at' ";
    
    dateFormatter.dateFormat = day.length ? [day stringByAppendingString:@"HH:mm"] : @"dd-MM-yyyy 'at' HH:mm";
    
    return [dateFormatter stringFromDate:date];
}


@end
