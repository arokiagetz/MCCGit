//
//  MNISectionPreferencesHandler.h
//  phoenix-reader
//
//  Created by Sarat Chandran on 3/15/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MNIServerConfigModels.h"

@interface MNISectionPreferencesHandler : NSObject

// Retrieves the ordered list of section ID's from Core Data as a mutable array.
- (NSMutableArray<NSString *> *)retrieveOrderedSectionIDsWithError:(NSError * __autoreleasing *)errorPtr;
// Stores the ordered list of section ID's from an array into Core Data.
- (NSError *)storeOrderedSectionIDs:(NSArray<NSString *> *)orderedSectionIDs;
// Updates the stored ordered list by adding and removing section ID's available in server config model
- (void)updateWithServerConfigModel:(nonnull MNIServerConfigModel *)serverConfigModel;
// given a list of section IDs, returns the items in that list sorted in preference order
- (NSOrderedSet<NSString *> *)orderedSectionIDsFromSectionIDs:(NSArray<NSString *> *)sectionIDs;

// These methods allow manipulation of individual objects. Prefer using the bulk retrieve / store methods above over these.
- (nullable NSError *)deleteSectionID:(nonnull NSString *)sectionID;
- (nullable NSError *)addSectionID:(nonnull NSString *)sectionID beforeSectionID:(nullable NSString *)otherSectionID;
- (nullable NSError *)moveSectionID:(nonnull NSString *)sectionID beforeSectionID:(nullable NSString *)otherSectionID;
- (nullable NSError *)clearSectionPreferences;

@end
