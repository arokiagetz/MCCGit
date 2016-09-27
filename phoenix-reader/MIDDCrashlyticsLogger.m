//
//  MIDDCrashlyticsLogger.m
//  Reader
//
//  Created by Scott Ferwerda on 9/24/15.
//  Copyright (c) 2015 McClatchy Interactive. All rights reserved.
//

#import "MIDDCrashlyticsLogger.h"
#import <Crashlytics/Crashlytics.h>

@implementation MIDDCrashlyticsLogger

- (void)logMessage:(DDLogMessage *)logMessage {
    NSString *logMsg = logMessage.message;
    if (self->_logFormatter)
    {
        logMsg = [self->_logFormatter formatLogMessage:logMessage];
    }
    
    if (logMsg) {
        CLSNSLog(@"%@",logMsg);
    }
}

@end
