//
//  MIDDLogentriesLogger.m
//  Reader
//
//  Created by Stephen Deguglielmo on 10/21/15.
//  Copyright © 2015 McClatchy Interactive. All rights reserved.
//

#import "MIDDLogentriesLogger.h"
#import "lelib.h"

@implementation MIDDLogentriesLogger
- (void)logMessage:(DDLogMessage *)logMessage {
    NSString *logMsg = logMessage.message;
    if (self->_logFormatter)
    {
        logMsg = [self->_logFormatter formatLogMessage:logMessage];
    }
    
    if (logMsg) {
        [[LELog sharedInstance] log:logMsg];
    }
}
@end
