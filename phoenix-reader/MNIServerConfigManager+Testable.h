//
//  MNIServerConfigManager+Testable.h
//  phoenix-reader
//
//  Created by Scott Ferwerda on 3/15/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#import "MNIServerConfigManager.h"

@interface MNIServerConfigManager (Testable)

@property MNIURLDownloader *downloader;

- (NSURL *)serverConfigUrl;
- (void)setServerConfigUrl:(NSURL *)serverConfigUrl;

- (MNIURLDownloader *)downloader;
- (void)setDownloader:(MNIURLDownloader *)downloader;

- (void)fetchServerConfigWithSuccessBlock:(void (^)(MNIServerConfigModel *aServerConfigModel, NSDate *lastUpdatedDate))success andFailureBlock:(void (^)(NSError *error))failure;
- (BOOL)updateServerConfigFromDictionary:(NSDictionary *)dictionary error:(NSError **)errorPtr NS_SWIFT_NOTHROW;
- (BOOL)serverConfigIsStale;

@end
