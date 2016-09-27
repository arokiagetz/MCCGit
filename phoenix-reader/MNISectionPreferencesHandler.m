//
//  MNISectionPreferencesHandler.m
//  phoenix-reader
//
//  Created by Sarat Chandran on 3/15/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#import "MNISectionPreferencesHandler.h"
#import <BlocksKit/BlocksKit.h>
#import "MNIDataController.h"
#import "SectionPreferences.h"
#import "MILog.h"


@implementation MNISectionPreferencesHandler

- (NSMutableArray<NSString *> *)retrieveOrderedSectionIDsWithError:(NSError * __autoreleasing *)errorPtr
{
    __block NSMutableArray<NSString *> *result = nil;
    
    NSManagedObjectContext *managedObjectContext = [[MNIDataController sharedDataController] workerObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:[SectionPreferences entityName] inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sortOrder"
                                                                   ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (errorPtr != NULL) {
        *errorPtr = error;
    }
    if (error == nil) {
        result = [NSMutableArray array];
        [fetchedObjects enumerateObjectsUsingBlock:^(SectionPreferences *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [result addObject:[NSString stringWithString:obj.sectionID]];
        }];
    }
    
    return result;
}

- (NSError *)storeOrderedSectionIDs:(NSArray<NSString *> *)orderedSectionIDs
{
    __block NSError *error = nil;

    NSManagedObjectContext *managedObjectContext = [[MNIDataController sharedDataController] workerObjectContext];
    
    // delete all stored section preferences
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:[SectionPreferences entityName] inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setIncludesPropertyValues:NO];
    error = nil;
    NSArray *objectsToDelete = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error == nil) {
        for (NSManagedObject *anObject in objectsToDelete) {
            [managedObjectContext deleteObject:anObject];
        }
        error = nil;
        [managedObjectContext save:&error];
        if (error == nil) {
            // deletion succeeded - add all the new objects
            for (NSUInteger i = 0; i < orderedSectionIDs.count; i++) {
                SectionPreferences *newSectionPreference = [NSEntityDescription insertNewObjectForEntityForName:[SectionPreferences entityName] inManagedObjectContext:managedObjectContext];
                newSectionPreference.sectionID = orderedSectionIDs[i];
                newSectionPreference.sortOrder = @(i);
            }
            
            [[MNIDataController sharedDataController] persistWorkerMOCChanges:managedObjectContext synchronous:YES withCompletion:^(NSError *saveError) {
                error = saveError;
            }];
        }
    }
    
    return error;
}

- (void)updateWithServerConfigModel:(nonnull MNIServerConfigModel *)serverConfigModel
{
    NSString *topStorySectionID = serverConfigModel.sections_info.multisection.top_story_section_id;
    
    // clean up the preferred order from the server config
    NSArray<MNIConfigSectionModel *> *sectionsInConfig = serverConfigModel.sections_info.sections;
    NSArray<NSString *> *sectionIDsInConfig = [sectionsInConfig bk_map:^id(MNIConfigSectionModel *obj) {
        return obj.section_id;
    }];
    
    NSError *error = nil;
    NSArray<NSString *> *oldOrderedSectionIDs = [self retrieveOrderedSectionIDsWithError:&error];
    if (error != nil) {
        // can't read old list
        oldOrderedSectionIDs = nil;
    }
    
    NSArray<NSString *> *orderedSectionIDs;
    if (oldOrderedSectionIDs.count > 0) {
        orderedSectionIDs = oldOrderedSectionIDs;
    }
    else {
        // no valid section order preferences so use the order in the server config
        orderedSectionIDs = sectionIDsInConfig;
    }
    
    // remove section IDs from ordered list if not available in config
    NSArray<NSString *> *newOrderedSectionIDs = [orderedSectionIDs bk_select:^BOOL(NSString *obj) {
        BOOL keep;
        if ([obj isEqualToString:@"multisection"]) {
            keep = NO;
        }
        else {
            keep = [sectionIDsInConfig containsObject:obj];
        }
        return keep;
    }];
    
    // append section IDs from config that aren't in the list
    NSArray<NSString *> *newSectionIDsToAppend = [sectionIDsInConfig bk_select:^BOOL(NSString *obj) {
        BOOL keep;
        if ([obj isEqualToString:@"multisection"]) {
            keep = NO;
        }
        else {
            keep = ([newOrderedSectionIDs containsObject:obj] == NO);
        }
        return keep;
    }];
    
    newOrderedSectionIDs = [newOrderedSectionIDs arrayByAddingObjectsFromArray:newSectionIDsToAppend];
    
    [self storeOrderedSectionIDs:newOrderedSectionIDs];
    
}

- (NSOrderedSet<NSString *> *)orderedSectionIDsFromSectionIDs:(NSArray<NSString *> *)sectionIDs
{
    NSError *error = nil;
    NSMutableArray<NSString *> *preferredSectionIDOrder = [self retrieveOrderedSectionIDsWithError:&error];
    if (error != nil) {
        preferredSectionIDOrder = nil;
    }
    
    // sort into 2 buckets - has-preference and hasn't
    NSMutableOrderedSet<NSString *> *newOrderedSectionIDs = [[NSMutableOrderedSet alloc] init];
    NSMutableOrderedSet<NSString *> *extraSectionIDs = [[NSMutableOrderedSet alloc] init];
    for (NSString *aSectionID in preferredSectionIDOrder) {
        if ([sectionIDs containsObject:aSectionID]) {
            [newOrderedSectionIDs addObject:aSectionID];
        }
        else {
            [extraSectionIDs addObject:aSectionID];
        }
    }
    
    if (extraSectionIDs.count > 0) {
        [newOrderedSectionIDs addObjectsFromArray:[extraSectionIDs array]];
        MILogWarn(@"Unexpectedly have %ld extra section IDs not in preferred order list.", (long)extraSectionIDs.count);
    }
    
    return newOrderedSectionIDs;
}

#pragma mark -

- (NSError *)deleteSectionID:(NSString *)sectionID
{
    NSManagedObjectContext *managedObjectContext = [[MNIDataController sharedDataController] workerObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:[SectionPreferences entityName] inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"sectionID = %@", sectionID];
    fetchRequest.predicate = filterPredicate;
    NSBatchDeleteRequest *deleteRequest = [[NSBatchDeleteRequest alloc] initWithFetchRequest:fetchRequest];
    __block NSError *error = nil;
    [managedObjectContext executeRequest:deleteRequest error:&error];
    if (error == nil) {
        [[MNIDataController sharedDataController] persistWorkerMOCChanges:managedObjectContext synchronous:YES withCompletion:^(NSError *saveError) {
            error = saveError;
        }];
    }
    
    return error;
}

- (NSError *)addSectionID:(NSString *)sectionID beforeSectionID:(NSString *)otherSectionID
{
    NSError *error = nil;
    
    if (sectionID != nil) {
        NSMutableArray<NSString *> *orderedSectionIDs = [self retrieveOrderedSectionIDsWithError:&error];
        if (error == nil) {
            // remove existing
            [orderedSectionIDs removeObject:sectionID];
            // find insertion
            NSUInteger i = NSNotFound;
            if (otherSectionID != nil) {
                i = [orderedSectionIDs indexOfObject:otherSectionID];
            }
            // insert/add
            if (i == NSNotFound) {
                [orderedSectionIDs addObject:sectionID];
            }
            else {
                [orderedSectionIDs insertObject:sectionID atIndex:i];
            }
            // persist
            error = [self storeOrderedSectionIDs:orderedSectionIDs];
        }
    }
    
    return error;
}

// this is the same as add, except it requires the section to exist already
- (NSError *)moveSectionID:(NSString *)sectionID beforeSectionID:(NSString *)otherSectionID
{
    NSError *error = nil;
    
    if (sectionID != nil) {
        NSMutableArray<NSString *> *orderedSectionIDs = [self retrieveOrderedSectionIDsWithError:&error];
        if (error == nil) {
            // remove existing
            NSUInteger oldIdx = [orderedSectionIDs indexOfObject:sectionID];
            if (oldIdx != NSNotFound) {
                [orderedSectionIDs removeObject:sectionID];
                // find insertion
                NSUInteger i = NSNotFound;
                if (otherSectionID != nil) {
                    i = [orderedSectionIDs indexOfObject:otherSectionID];
                }
                // insert/add
                if (i == NSNotFound) {
                    [orderedSectionIDs addObject:sectionID];
                }
                else {
                    [orderedSectionIDs insertObject:sectionID atIndex:i];
                }
                // persist
                error = [self storeOrderedSectionIDs:orderedSectionIDs];
            }
            else {
                // doesn't exist, error out
                error = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier] code:200 userInfo:@{@"Error reason": @"No results found"}];
            }
        }
    }
    
    return error;

}

- (NSError *)clearSectionPreferences
{
    __block NSError *error = nil;
    
    NSManagedObjectContext *managedObjectContext = [[MNIDataController sharedDataController] workerObjectContext];
    
    // delete all stored section preferences
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:[SectionPreferences entityName] inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    NSBatchDeleteRequest *deleteRequest = [[NSBatchDeleteRequest alloc] initWithFetchRequest:fetchRequest];
    [managedObjectContext executeRequest:deleteRequest error:&error];
    if (error == nil) {
        // deletion succeeded - persist deletions
        [[MNIDataController sharedDataController] persistWorkerMOCChanges:managedObjectContext synchronous:YES withCompletion:^(NSError *saveError) {
            error = saveError;
        }];
    }
    
    return error;
}

@end
