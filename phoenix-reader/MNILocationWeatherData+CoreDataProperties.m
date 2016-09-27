//
//  MNILocationWeatherData+CoreDataProperties.m
//  phoenix-reader
//
//  Created by Scott Ferwerda on 3/28/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MNILocationWeatherData+CoreDataProperties.h"

@implementation MNILocationWeatherData (CoreDataProperties)

@dynamic version;
@dynamic lastUpdated;
@dynamic weatherDataDict;
@dynamic providerID;
@dynamic locationID;
@dynamic locationName;
@dynamic active;
@dynamic selected;

@end
