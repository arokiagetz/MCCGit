//
//  MIFullLogFormatter.m
//  Reader
//
//  Created by Stephen Deguglielmo on 12/2/15.
//  Copyright © 2015 McClatchy Interactive. All rights reserved.
//

@import UIKit;
#import "MIFullLogFormatter.h"
#import "MILogFormatter.h"

@implementation MIFullLogFormatter

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage
{
//    NSString *baseFormattedMessage = [super formatLogMessage:logMessage];
    
    // generate the timestamp:
    // borrowed this date technique from the base DDTTYLogger code, which claims it's faster than NSDateFormatter
    const NSUInteger calendarUnitFlags = (NSCalendarUnitYear     |
                                          NSCalendarUnitMonth    |
                                          NSCalendarUnitDay      |
                                          NSCalendarUnitHour     |
                                          NSCalendarUnitMinute   |
                                          NSCalendarUnitSecond);
    NSDateComponents *components = [[NSCalendar autoupdatingCurrentCalendar] components:calendarUnitFlags fromDate:logMessage->_timestamp];
    NSTimeInterval epoch = [logMessage->_timestamp timeIntervalSinceReferenceDate];
    int milliseconds = (int)((epoch - floor(epoch)) * 1000);
    NSString *timestamp  = [NSString stringWithFormat:@"%04ld-%02ld-%02ld %02ld:%02ld:%02ld:%03d", // yyyy-MM-dd HH:mm:ss:SSS
                            (long)components.year,
                            (long)components.month,
                            (long)components.day,
                            (long)components.hour,
                            (long)components.minute,
                            (long)components.second, milliseconds];
    
    NSString *vendorIdString = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString *logLevel = [MILogFormatter letterCodeForLogLevel:(MILogFlag)(logMessage->_flag)];
    NSString *prodName = [MILogFormatter appNameForLogging];
    NSString *codeLocation = [NSString stringWithFormat:@"[%@:%zd]", logMessage.fileName, logMessage.line];
    NSString *filteredMessage = [logMessage.message stringByReplacingOccurrencesOfString:@"\"" withString:@"`"];
    
    NSString *formattedMessage = [NSString stringWithFormat:@"datetime=\"%@\" appname=\"%@\" device_uuid=\"%@\" severity=\"%@\" code_location=\"%@\" message=\"%@\"", timestamp, prodName, vendorIdString, logLevel, codeLocation, filteredMessage];
    
    return formattedMessage;
}
@end
