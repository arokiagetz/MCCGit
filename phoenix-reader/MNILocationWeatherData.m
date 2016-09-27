//
//  MNILocationWeatherData.m
//  phoenix-reader
//
//  Created by Scott Ferwerda on 3/28/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#import "MNILocationWeatherData.h"
#import "MILog.h"

@implementation MNILocationWeatherData

#pragma mark - getters/setters

- (nullable const MIWeatherDatasetForLocation *)mniWeatherDatasetForLocation
{
    MIWeatherDatasetForLocation *result = nil;
    
    // Core Data Transformable is an NSDictionary
    
    // construct a new object from the dictionary
    NSDictionary *dictionary = self.weatherDataDict;
    MIWeatherDatasetForLocation *dataModel = [[MIWeatherDatasetForLocation alloc] initWithAccuweatherDictionary:dictionary];
    if (dataModel != nil) {
        result = dataModel;
    }
    else {
        MILogError(@"Error initializing weather dataset object from dictionary");
    }
        
    return result;
}

#pragma mark - public methods

- (BOOL)setMniWeatherDatasetForLocationFromDictionary:(NSDictionary *)dictionary updateDerivedAttributes:(BOOL)updateAttrs
{
    // determine if dictionary can produce a valid object
    BOOL dictIsModelable = NO;
    MIWeatherDatasetForLocation *dataModel = [[MIWeatherDatasetForLocation alloc] initWithAccuweatherDictionary:dictionary];
    if (dataModel != nil) {
        dictIsModelable = YES;
        self.weatherDataDict = [NSDictionary dictionaryWithDictionary:dictionary];
        if (updateAttrs) {
            self.providerID = @"accuweather";
            self.locationID = dataModel.locationKey;
            self.locationName = dataModel.locationTitle;
        }
    }
    else {
        self.weatherDataDict = nil;
        MILogError(@"Error generating weather dataset object from dictionary");
    }
    
    return dictIsModelable;
}

@end
