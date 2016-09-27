//
//  MNIDataController.m
//  phoenix-reader
//
//  Created by Yann Duran on 3/8/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#import "MNIDataController.h"
#import "MILog.h"


@interface MNIDataController ()
{
    NSString *_databaseName;
    NSManagedObjectContext *_mainManagedObjectContext;
}

@property (readonly, strong, nonatomic) NSManagedObjectContext *persistentManagedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation MNIDataController

+ (id)sharedDataController {
    static MNIDataController *sharedDataController = nil;
    @synchronized(self) {
        if (sharedDataController == nil)
            sharedDataController = [[self alloc] init];
    }
    return sharedDataController;
}

- (instancetype)init
{
    return [self initWithDatabaseName:@"phoenix_reader.sqlite"];
}

- (instancetype)initWithDatabaseName:(NSString *)databaseName
{
    self = [super init];
    if (self) {
        NSAssert(databaseName.length > 0, @"cannot initialize data controller with an invalid name");
        _databaseName = databaseName;
    }
    return self;
}

#pragma mark - Core Data stack

@synthesize persistentManagedObjectContext = _persistentManagedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.mcclatchy.phoenix_reader" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSURL *)applicationCacheDirectory {
    // The directory the application uses to store cached data.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"phoenix_reader" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }

    NSDictionary *options = @{
                              NSMigratePersistentStoresAutomaticallyOption : @YES,
                              NSInferMappingModelAutomaticallyOption : @YES
                              };
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:_databaseName];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        // FIXME
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        MILogError(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)persistentManagedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_persistentManagedObjectContext != nil) {
        return _persistentManagedObjectContext;
    }

    NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
    if (!coordinator) {
        return nil;
    }
    _persistentManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [_persistentManagedObjectContext setPersistentStoreCoordinator:coordinator];
    return _persistentManagedObjectContext;
}

- (NSManagedObjectContext *)mainManagedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_mainManagedObjectContext != nil) {
        return _mainManagedObjectContext;
    }
    
    _mainManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    _mainManagedObjectContext.parentContext = self.persistentManagedObjectContext;
    return _mainManagedObjectContext;
}

- (NSManagedObjectContext *)workerObjectContext {
    // Returns the a new MOC with the main MOC as a parent
    NSManagedObjectContext *workerMOC = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    workerMOC.parentContext = [self mainManagedObjectContext];
    return workerMOC;
}

#pragma mark - Core Data Saving support

- (void)saveWorkerMOCChanges:(NSManagedObjectContext *)workerMOC withCompletion:(void (^) (NSError *)) completion
{
    [self saveWorkerMOCChanges:workerMOC synchronous:NO withCompletion:completion];
}

- (void) saveWorkerMOCChanges:(NSManagedObjectContext *)workerMOC synchronous:(BOOL)synchronous withCompletion:(void (^) (NSError *)) completion
{
    __block NSError* error = nil;
    
    // save the worker MOC
    if (synchronous) {
        if ([workerMOC hasChanges]) {
            [workerMOC performBlockAndWait:^{
                [workerMOC save:&error];
                NSManagedObjectContext *mainMOC = workerMOC.parentContext;
                if ([mainMOC hasChanges]) {
                    [mainMOC performBlockAndWait:^{
                        [mainMOC save:&error];
                        if (completion != nil) {
                            completion(error);
                        }
                    }];
                }
            }];
        }
    }
    else {
        if ([workerMOC hasChanges]) {
            [workerMOC performBlock:^{
                [workerMOC save:&error];
                NSManagedObjectContext *mainMOC = workerMOC.parentContext;
                if ([mainMOC hasChanges]) {
                    [mainMOC performBlock:^{
                        [mainMOC save:&error];
                        if (completion != nil) {
                            completion(error);
                        }
                    }];
                }
            }];
        }
    }
}

- (void) persistWorkerMOCChanges:(NSManagedObjectContext *)workerMOC withCompletion:(void (^) (NSError *)) completion
{
    [self persistWorkerMOCChanges:workerMOC synchronous:NO withCompletion:completion];
}

- (void) persistWorkerMOCChanges:(NSManagedObjectContext *)workerMOC synchronous:(BOOL)synchronous withCompletion:(void (^) (NSError *)) completion
{
    [self saveWorkerMOCChanges:workerMOC synchronous:synchronous withCompletion:^(NSError *error) {
        if (error == nil) {
            [self persistMOCChanges:^(NSError *error) {
                if (completion != NULL) completion(error);
            }];
        }
        else {
            if (completion != NULL) completion(error);
        }
    }];
}

- (void) persistMOCChanges: (void (^) (NSError *)) completion
{
    NSError* error = nil;
    [self.persistentManagedObjectContext save:&error];
    completion(error);
}

@end
