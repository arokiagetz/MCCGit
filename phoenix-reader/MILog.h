//
//  MILog.h
//  Reader
//
//  Created by Scott Ferwerda on 9/23/15.
//  Copyright (c) 2015 McClatchy Interactive. All rights reserved.
//

#ifndef Reader_MILog_h
#define Reader_MILog_h

#import <CocoaLumberjack/CocoaLumberjack.h>

typedef NS_OPTIONS(NSUInteger, MILogFlag) {
    MILogFlagError      = (1 << 0), // 0...000001
    MILogFlagWarning    = (1 << 1), // 0...000010
    MILogFlagInfo       = (1 << 2), // 0...000100
    MILogFlagDetailed   = (1 << 3), // 0...001000
    MILogFlagDebug      = (1 << 4), // 0...010000
    MILogFlagTrace      = (1 << 5), // 0...100000
    MILogFlagRemote     = (1 << 6)  // 0..1000000
};

typedef NS_ENUM(NSUInteger, MILogLevel) {
    MILogLevelOff       = 0,
    MILogLevelError     = (MILogFlagError),                         // 0...000001
    MILogLevelWarning   = (MILogLevelError    | MILogFlagWarning),  // 0...000011
    MILogLevelInfo      = (MILogLevelWarning  | MILogFlagInfo),     // 0...000111
    MILogLevelDetailed  = (MILogLevelInfo     | MILogFlagDetailed), // 0...001111
    MILogLevelDebug     = (MILogLevelDetailed | MILogFlagDebug),    // 0...011111
    MILogLevelTrace     = (MILogLevelDebug    | MILogFlagTrace),    // 0...111111
    MILogLevelRemote    = (MILogLevelInfo | MILogLevelError | MILogLevelWarning | MILogFlagRemote),                           // 0..1000000
    MILogLevelAll       = NSUIntegerMax                             // 1111....11111 (all enumerated flags plus any other flags)
};

#ifdef DEBUG
    static const MILogLevel miLogLevel = MILogLevelAll;
#else
// 2015.09.28 sferwerda - normal release level logging should be info, but Stephen is tracking a bug so we're using "detailed" level for release builds.
//    static const MILogLevel miLogLevel = MILogLevelInfo;
    static const MILogLevel miLogLevel = MILogLevelDetailed;
#endif

#undef LOG_LEVEL_DEF
#define LOG_LEVEL_DEF miLogLevel

#define MILogError(frmt, ...)    LOG_MAYBE(NO,                (DDLogLevel)LOG_LEVEL_DEF, (DDLogFlag)MILogFlagError,    0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define MILogWarn(frmt, ...)     LOG_MAYBE(LOG_ASYNC_ENABLED, (DDLogLevel)LOG_LEVEL_DEF, (DDLogFlag)MILogFlagWarning,  0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define MILogInfo(frmt, ...)     LOG_MAYBE(LOG_ASYNC_ENABLED, (DDLogLevel)LOG_LEVEL_DEF, (DDLogFlag)MILogFlagInfo,     0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define MILogDetailed(frmt, ...) LOG_MAYBE(LOG_ASYNC_ENABLED, (DDLogLevel)LOG_LEVEL_DEF, (DDLogFlag)MILogFlagDetailed, 0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define MILogDebug(frmt, ...)    LOG_MAYBE(LOG_ASYNC_ENABLED, (DDLogLevel)LOG_LEVEL_DEF, (DDLogFlag)MILogFlagDebug,    0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define MILogTrace(frmt, ...)    LOG_MAYBE(LOG_ASYNC_ENABLED, (DDLogLevel)LOG_LEVEL_DEF, (DDLogFlag)MILogFlagTrace,    0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define MILogRemote(frmt, ...)   LOG_MAYBE(LOG_ASYNC_ENABLED, (DDLogLevel)LOG_LEVEL_DEF, (DDLogFlag)MILogFlagRemote,   0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)

#endif
