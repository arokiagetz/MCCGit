//
//  MILogFormatter.h
//  Reader
//
//  Created by Scott Ferwerda on 9/23/15.
//  Copyright (c) 2015 McClatchy Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <CocoaLumberjack/CocoaLumberjack.h>
#import "MILog.h"

@interface MILogFormatter : NSObject <DDLogFormatter>

+ (NSString *)letterCodeForLogLevel:(MILogFlag)logFlag;
+ (NSString *)appNameForLogging;

@end
