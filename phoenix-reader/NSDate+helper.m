//
//  NSDate+helper.m
//  phoenix-reader
//
//  Created by Yann Duran on 3/21/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#import "NSDate+helper.h"

@implementation NSDate (helper)

+ (NSDate*)NSDateFromUnixTimestamp:(NSString *)epochTime
{
    NSTimeInterval seconds = [epochTime doubleValue];
    NSDate *epochNSDate = [[NSDate alloc] initWithTimeIntervalSince1970:seconds];
    return epochNSDate;
}

+ (NSString *)MNITimeAgoSinceDate:(nonnull NSDate *)date referenceDate : (nonnull NSDate *)referenceDate
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSUInteger dayOfYear = [calendar ordinalityOfUnit:NSCalendarUnitDay
                                               inUnit:NSCalendarUnitYear
                                              forDate:date];
    NSUInteger year = [calendar component:NSCalendarUnitYear fromDate:date];
    
    NSUInteger referenceDayOfYear = [calendar ordinalityOfUnit:NSCalendarUnitDay
                                                      inUnit:NSCalendarUnitYear
                                                     forDate:referenceDate];
    
    NSUInteger referenceYear = [calendar component:NSCalendarUnitYear fromDate:referenceDate];
    //same day check
    BOOL isSameDay = (dayOfYear == referenceDayOfYear) && (year == referenceYear);
    if (isSameDay) {
        unsigned int unitFlags = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitDay | NSCalendarUnitMonth;
        NSDateComponents *dateComponents = [calendar components:unitFlags fromDate:date  toDate:referenceDate  options:0];
        if (dateComponents.hour > 0) {
            NSString* hour = (dateComponents.hour == 1) ? @"hour" : @"hours";
            return [NSString stringWithFormat:@"%ld %@ %@", (long)dateComponents.hour, NSLocalizedString(hour, nil), NSLocalizedString(@"ago", nil)];
        }
        else if (dateComponents.minute > 0) {
            NSString* minute = (dateComponents.minute == 1) ? @"minute" : @"minutes";
            return [NSString stringWithFormat:@"%ld %@ %@", (long)dateComponents.minute, NSLocalizedString(minute, nil), NSLocalizedString(@"ago", nil)];
        }
    }
    //is it 'Yesterday ?
    int daysToAdd = -1;
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:daysToAdd];
    NSDate *yesterday = [calendar dateByAddingComponents:components toDate:referenceDate options:0];
    NSUInteger yesterdayDayOfYear = [calendar ordinalityOfUnit:NSCalendarUnitDay
                                               inUnit:NSCalendarUnitYear
                                              forDate:yesterday];
    NSUInteger yesterYear = [calendar component:NSCalendarUnitYear fromDate:yesterday];
    BOOL isYesterday = (dayOfYear == yesterdayDayOfYear) && (year == yesterYear);
    if (isYesterday){
        return NSLocalizedString(@"Yesterday", nil);
    }
    //if it is in the same week
    NSDate *startOfTheWeek;
    NSTimeInterval interval;
    [calendar rangeOfUnit:NSCalendarUnitWeekOfMonth
           startDate:&startOfTheWeek
            interval:&interval
             forDate:referenceDate];

    if ([self date:date isBetweenDate:startOfTheWeek andDate:referenceDate]) {
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat: @"EEEE"];
        return [dateFormatter stringFromDate:date];
    }

    //none of the above
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"MM/dd/YYYY"];
    return [dateFormatter stringFromDate:date];
}

+ (BOOL)date:(NSDate*)date isBetweenDate:(NSDate*)beginDate andDate:(NSDate*)endDate
{
    if ([date compare:beginDate] == NSOrderedAscending)
        return NO;
    
    if ([date compare:endDate] == NSOrderedDescending)
        return NO;
    
    return YES;
}

+ (NSString *)MNITimeAgoSinceDate:(nonnull NSDate *)date
{
    return [self MNITimeAgoSinceDate:date
                       referenceDate:[NSDate date]];
}

@end
