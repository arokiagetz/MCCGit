//
//  MILogFormatter.m
//  Reader
//
//  Created by Scott Ferwerda on 9/23/15.
//  Copyright (c) 2015 McClatchy Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MILogFormatter.h"

@implementation MILogFormatter

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage
{
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

    NSString *logLevel = [[self class] letterCodeForLogLevel:(MILogFlag)(logMessage->_flag)];
    NSString *prodName = [[self class] appNameForLogging];
    
    // format: AppName [level] [filename:linenum] message
    return [NSString stringWithFormat:@"%@ %@ [%@] [%@:%zd] %@", timestamp, prodName, logLevel, logMessage.fileName, logMessage.line, logMessage.message];
}

+ (NSString *)letterCodeForLogLevel:(MILogFlag)logFlag
{
    NSString *logLevel;
    switch (logFlag) {
        case MILogFlagError:    logLevel = @"E"; break;
        case MILogFlagWarning:  logLevel = @"W"; break;
        case MILogFlagInfo:     logLevel = @"I"; break;
        case MILogFlagDetailed: logLevel = @"D"; break;
        case MILogFlagDebug:    logLevel = @"G"; break;
        case MILogFlagTrace:    logLevel = @"T"; break;
        case MILogFlagRemote:   logLevel = @"R"; break;
        default:                logLevel = @"*"; break;
    }
    return logLevel;
}

+ (NSString *)appNameForLogging
{
    NSBundle *bundle = [NSBundle mainBundle];
    NSDictionary *info = [bundle infoDictionary];
    NSString *prodName = [info objectForKey:@"CFBundleName"];
    return prodName;
}
@end
