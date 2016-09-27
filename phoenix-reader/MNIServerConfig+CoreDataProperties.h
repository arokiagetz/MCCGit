//
//  MNIServerConfig+CoreDataProperties.h
//  phoenix-reader
//
//  Created by Scott Ferwerda on 3/14/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MNIServerConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface MNIServerConfig (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *lastUpdated;
@property (nullable, nonatomic, retain) NSNumber *version;
@property (nullable, nonatomic, retain) id serverConfigModelDict;

@end

NS_ASSUME_NONNULL_END
