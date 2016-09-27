//
//  MNILocationWeatherData+CoreDataProperties.h
//  phoenix-reader
//
//  Created by Scott Ferwerda on 3/28/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MNILocationWeatherData.h"

NS_ASSUME_NONNULL_BEGIN

@interface MNILocationWeatherData (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *version;
@property (nullable, nonatomic, retain) NSDate *lastUpdated;
@property (nullable, nonatomic, retain) id weatherDataDict;
@property (nullable, nonatomic, retain) NSString *providerID;
@property (nullable, nonatomic, retain) NSString *locationID;
@property (nullable, nonatomic, retain) NSString *locationName;
@property (nullable, nonatomic, retain) NSNumber *active;
@property (nullable, nonatomic, retain) NSNumber *selected;

@end

NS_ASSUME_NONNULL_END
