//
//  MNILocationWeatherData.h
//  phoenix-reader
//
//  Created by Scott Ferwerda on 3/28/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MIWeatherDataProviderModels.h"

NS_ASSUME_NONNULL_BEGIN

@interface MNILocationWeatherData : NSManagedObject

@property (nullable, nonatomic, copy, readonly) const MIWeatherDatasetForLocation *mniWeatherDatasetForLocation;

- (BOOL)setMniWeatherDatasetForLocationFromDictionary:(NSDictionary *)dictionary updateDerivedAttributes:(BOOL)updateAttrs;

@end

NS_ASSUME_NONNULL_END

#import "MNILocationWeatherData+CoreDataProperties.h"
