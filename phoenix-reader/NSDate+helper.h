//
//  NSDate+helper.h
//  phoenix-reader
//
//  Created by Yann Duran on 3/21/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (helper)

+ (nonnull NSDate*)NSDateFromUnixTimestamp:(nonnull NSString *)epochTime;
+ (nonnull NSString *)MNITimeAgoSinceDate:(nonnull NSDate *)fromDate;
+ (nonnull NSString *)MNITimeAgoSinceDate:(nonnull NSDate *)date referenceDate : (nonnull NSDate *)referenceDate;
@end
