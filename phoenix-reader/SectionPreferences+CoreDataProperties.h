//
//  SectionPreferences+CoreDataProperties.h
//  phoenix-reader
//
//  Created by Scott Ferwerda on 4/18/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "SectionPreferences.h"

NS_ASSUME_NONNULL_BEGIN

@interface SectionPreferences (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *sectionID;
@property (nullable, nonatomic, retain) NSNumber *sortOrder;

@end

NS_ASSUME_NONNULL_END
