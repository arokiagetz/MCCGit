//
//  MIFullLogFormatter.h
//  Reader
//
//  Created by Stephen Deguglielmo on 12/2/15.
//  Copyright © 2015 McClatchy Interactive. All rights reserved.
//

#import "MILogFormatter.h"

@interface MIFullLogFormatter : MILogFormatter
- (NSString *)formatLogMessage:(DDLogMessage *)logMessage;
@end
