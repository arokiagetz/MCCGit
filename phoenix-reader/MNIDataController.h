//
//  MNIDataController.h
//  phoenix-reader
//
//  Created by Yann Duran on 3/8/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface MNIDataController : NSObject

+ (id)sharedDataController;

- (instancetype)initWithDatabaseName:(NSString *)databaseName NS_DESIGNATED_INITIALIZER;

- (NSManagedObjectContext *)mainManagedObjectContext;
- (NSManagedObjectContext *)workerObjectContext;

- (void) saveWorkerMOCChanges:(NSManagedObjectContext *)workerMOC withCompletion:(void (^) (NSError *))completion;
- (void) saveWorkerMOCChanges:(NSManagedObjectContext *)workerMOC synchronous:(BOOL)synchronous withCompletion:(void (^) (NSError *))completion;
- (void) persistWorkerMOCChanges:(NSManagedObjectContext *)workerMOC withCompletion:(void (^) (NSError *))completion;
- (void) persistWorkerMOCChanges:(NSManagedObjectContext *)workerMOC synchronous:(BOOL)synchronous withCompletion:(void (^) (NSError *))completion;
- (void) persistMOCChanges:(void (^) (NSError *))completion;

@end
