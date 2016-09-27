//
//  MNIServerConfigManager.h
//  phoenix-reader
//
//  Created by Scott Ferwerda on 3/14/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSManagedObject+Helpers.h"
#import "MNIURLDownloader.h"
#import "MNIServerConfig.h"
#import "MNIDataController.h"
#import "MNISection.h"

extern NSString * _Nonnull const MNIServerConfigDidUpdateNotification;
extern NSString * _Nonnull const MNIServerConfigDidFailToUpdateNotification;

@interface MNIServerConfigManager : NSObject

@property (nullable, nonatomic, copy, readonly) MNIServerConfigModel *serverConfigModel;
@property (nullable, nonatomic, copy, readonly) NSDate *lastUpdatedDate;

+ (nullable instancetype)sharedManager;
+ (nullable instancetype)initSharedManagerWithURL:(nonnull NSURL *)url andDataController:(nonnull MNIDataController *)dataController;

- (nullable instancetype)initWithURL:(nonnull NSURL *)url andDataController:(nonnull MNIDataController *)dataController;

- (void)fetchServerConfigIfNeeded;
- (void)fetchServerConfigIfNeededWithSuccessBlock:(void (^ _Nullable)(MNIServerConfigModel * _Nullable aServerConfigModel, NSDate * _Nullable lastUpdatedDate))success andFailureBlock:(void (^ _Nullable)(NSError * _Nullable error))failure;

- (void)fetchServerConfig;
- (void)fetchServerConfigWithSuccessBlock:(void (^)(MNIServerConfigModel *aServerConfigModel, NSDate *lastUpdatedDate))success andFailureBlock:(void (^)(NSError *error))failure;

@end
