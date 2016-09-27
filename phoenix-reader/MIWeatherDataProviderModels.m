//
//  MIWeatherDataProviderModels.m
//  Reader
//
//  Created by Scott Ferwerda on 10/2/15.
//  Copyright (c) 2015 McClatchy Interactive. All rights reserved.
//

#import "MIWeatherDataProviderModels.h"
#import <ISO8601DateFormatter/ISO8601DateFormatter.h>

@implementation MIAccuWeatherValue

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"value": @"Value",
             @"unit": @"Unit",
             @"unitType": @"UnitType"
             };
}

@end

@implementation MIAccuWeatherWindDirection

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"degrees": @"Degrees",
             @"localizedText": @"Localized",
             @"englishText": @"English"
             };
}

@end

@implementation MIAccuWeatherWind

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"direction": @"Direction",
             @"speed": @"Speed"
             };
}

@end

@implementation MIAccuWeatherPhoto

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"source": @"Source",
             @"keywords": @"Description",
             @"portraitUrl": @"PortraitLink",
             @"landscapeUrl": @"LandscapeLink",
             };
}

@end

@implementation MIAccuWeatherCurrentConditions

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"observationDateISO8601": @"LocalObservationDateTime",
             @"observationDateEpochTime": @"EpochTime",
             @"weatherText": @"WeatherText",
             @"iconId": @"WeatherIcon",
             @"isDaytime": @"IsDayTime",
             @"temperature": @"Temperature",
             @"realFeelTemperature": @"RealFeelTemperature",
             @"windChillTemperature": @"WindChillTemperature",
             @"relativeHumidity": @"RelativeHumidity",
             @"dewPoint": @"DewPoint",
             @"wind": @"Wind",
             @"windGust": @"WindGust.Speed",
             @"uvIndex": @"UVIndex",
             @"uvIndexText": @"UVIndexText",
             @"visibility": @"Visibility",
             @"obstructionsToVisibility": @"ObstructionsToVisibility",
             @"cloudCover": @"CloudCover",
             @"ceiling": @"Ceiling",
             @"pressure": @"Pressure",
             @"pressureTendencyText": @"PressureTendency.LocalizedText",
             @"past24HrHighTemperature": @"TemperatureSummary.Past24HourRange.Maximum",
             @"past24HrLowTemperature": @"TemperatureSummary.Past24HourRange.Minimum",
             @"photos": @"Photos",
             };
}

- (NSDate *)observationDate
{
    NSDate *result = nil;
    NSString *isoDateString = [self observationDateISO8601];
    ISO8601DateFormatter *dateFormatter = [[ISO8601DateFormatter alloc] init];
    result = [dateFormatter dateFromString:isoDateString];
    return result;
}

- (NSTimeZone *)observationTimeZone
{
    NSTimeZone *result = nil;
    NSString *isoDateString = [self observationDateISO8601];
    ISO8601DateFormatter *dateFormatter = [[ISO8601DateFormatter alloc] init];
    [dateFormatter dateComponentsFromString:isoDateString timeZone:&result];
    return result;
}

+ (NSValueTransformer *)photosJSONTransformer
{
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        // forward transform takes NSArray of NSDictionary's in, outputs NSArray of MIAccuWeatherPhoto's
        NSMutableArray *result = [[NSMutableArray alloc] init];
        for (NSDictionary *aDict in (NSArray *)value)
        {
            MIAccuWeatherPhoto *entry = [MTLJSONAdapter modelOfClass:[MIAccuWeatherPhoto class] fromJSONDictionary:aDict error:error];
            if (*error == nil)
            {
                [result addObject:entry];
            }
            else
            {
                *success = NO;
                result = nil;
                break;
            }
        }
        return result;
    }];
}

@end

@implementation MIAccuWeatherHourlyForecast

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"forecastDateISO8601": @"DateTime",
             @"forecastDateEpochTime": @"EpochDateTime",
             @"weatherIconId": @"WeatherIcon",
             @"iconPhrase": @"IconPhrase",
             @"isDaylight": @"IsDaylight",
             @"temperature": @"Temperature",
             @"precipitationProbability": @"PrecipitationProbability",
             };
}

- (NSDate *)forecastDate
{
    NSDate *result = nil;
    NSString *isoDateString = [self forecastDateISO8601];
    ISO8601DateFormatter *dateFormatter = [[ISO8601DateFormatter alloc] init];
    result = [dateFormatter dateFromString:isoDateString];
    return result;
}

- (NSTimeZone *)forecastTimeZone
{
    NSTimeZone *result = nil;
    NSString *isoDateString = [self forecastDateISO8601];
    ISO8601DateFormatter *dateFormatter = [[ISO8601DateFormatter alloc] init];
    [dateFormatter dateComponentsFromString:isoDateString timeZone:&result];
    return result;
}

@end

@implementation MIAccuWeatherDailyForecast

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"forecastDateISO8601": @"Date",
             @"forecastDateEpochTime": @"EpochDate",
             @"highTemperature": @"Temperature.Maximum",
             @"lowTemperature": @"Temperature.Minimum",
             @"daytimeWeatherIconId": @"Day.Icon",
             @"daytimeIconPhrase": @"Day.IconPhrase",
             @"nighttimeWeatherIconId": @"Night.Icon",
             @"nighttimeIconPhrase": @"Night.IconPhrase",
             };
}

- (NSDate *)forecastDate
{
    NSDate *result = nil;
    NSString *isoDateString = [self forecastDateISO8601];
    ISO8601DateFormatter *dateFormatter = [[ISO8601DateFormatter alloc] init];
    result = [dateFormatter dateFromString:isoDateString];
    return result;
}

- (NSTimeZone *)forecastTimeZone
{
    NSTimeZone *result = nil;
    NSString *isoDateString = [self forecastDateISO8601];
    ISO8601DateFormatter *dateFormatter = [[ISO8601DateFormatter alloc] init];
    [dateFormatter dateComponentsFromString:isoDateString timeZone:&result];
    return result;
}

@end

@implementation MIAccuWeatherForecastHeadline

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"effectiveDateISO8601": @"EffectiveDate",
             @"effectiveDateEpochDate": @"EffectiveEpochDate",
             @"severity": @"Severity",
             @"text": @"Text",
             };
}

- (NSDate *)effectiveDate
{
    NSDate *result = nil;
    NSString *isoDateString = [self effectiveDateISO8601];
    ISO8601DateFormatter *dateFormatter = [[ISO8601DateFormatter alloc] init];
    result = [dateFormatter dateFromString:isoDateString];
    return result;
}

- (NSTimeZone *)effectiveTimeZone
{
    NSTimeZone *result = nil;
    NSString *isoDateString = [self effectiveDateISO8601];
    ISO8601DateFormatter *dateFormatter = [[ISO8601DateFormatter alloc] init];
    [dateFormatter dateComponentsFromString:isoDateString timeZone:&result];
    return result;
}

@end

@implementation MIAccuWeatherMapEntry

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"mapDateISO8601": @"Date",
             @"mapUrl": @"Url",
             };
}

- (NSDate *)mapDate
{
    NSDate *result = nil;
    NSString *isoDateString = [self mapDateISO8601];
    ISO8601DateFormatter *dateFormatter = [[ISO8601DateFormatter alloc] init];
    result = [dateFormatter dateFromString:isoDateString];
    return result;
}

- (NSTimeZone *)mapTimeZone
{
    NSTimeZone *result = nil;
    NSString *isoDateString = [self mapDateISO8601];
    ISO8601DateFormatter *dateFormatter = [[ISO8601DateFormatter alloc] init];
    [dateFormatter dateComponentsFromString:isoDateString timeZone:&result];
    return result;
}

@end

@implementation MIAccuWeatherMap

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"mapSize": @"Size",
             @"images": @"Images",
             };
}

+ (NSValueTransformer *)imagesJSONTransformer
{
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        // forward transform takes NSArray of NSDictionary's in, outputs NSArray of MIAccuWeatherMapEntry's
        NSMutableArray *result = [[NSMutableArray alloc] init];
        for (NSDictionary *aDict in (NSArray *)value)
        {
            MIAccuWeatherMapEntry *entry = [MTLJSONAdapter modelOfClass:[MIAccuWeatherMapEntry class] fromJSONDictionary:aDict error:error];
            if (*error == nil)
            {
                [result addObject:entry];
            }
            else
            {
                *success = NO;
                result = nil;
                break;
            }
        }
        return result;
    }];
}

@end

@implementation MIAccuWeatherMaps

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"radarMaps": @"Radar",
             @"satelliteMaps": @"Satellite",
             };
}

+ (NSValueTransformer *)radarMapsJSONTransformer
{
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        // forward transform takes NSDictionary in, outputs MIAccuWeatherMap object
        MIAccuWeatherMap *result = [MTLJSONAdapter modelOfClass:[MIAccuWeatherMap class] fromJSONDictionary:value error:error];
        if (*error != nil)
        {
            *success = NO;
            result = nil;
        }
        return result;
    }];
}

+ (NSValueTransformer *)satelliteMapsJSONTransformer
{
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        // forward transform takes NSDictionary in, outputs MIAccuWeatherMap object
        MIAccuWeatherMap *result = [MTLJSONAdapter modelOfClass:[MIAccuWeatherMap class] fromJSONDictionary:value error:error];
        if (*error != nil)
        {
            *success = NO;
            result = nil;
        }
        return result;
    }];
}

@end

@implementation MIWeatherDatasetForLocation

// given a dictionary deserialized from AccuWeather's "Local Weather" API endpoint, initialize a MIWeatherDatasetForLocation object
- (nullable instancetype)initWithAccuweatherDictionary:(NSDictionary *)accuweatherDict
{
    self = [super init];
    if (self) {
        NSDictionary *awLocationDict = accuweatherDict[@"Location"];
        self.locationKey = awLocationDict[@"Key"];
        self.locationTitle = awLocationDict[@"LocalizedName"];
        self.locationTimeZoneCode = awLocationDict[@"TimeZone"][@"Code"];
        
        NSError *error = nil;
        NSDictionary *awConditionsDict = accuweatherDict[@"CurrentConditions"];
        @try {
            self.currentConditions = [MTLJSONAdapter modelOfClass:[MIAccuWeatherCurrentConditions class] fromJSONDictionary:awConditionsDict error:&error];
        }
        @catch (NSException *exception) {
            self.currentConditions = nil;
        }
        if (error != nil) {
            self.currentConditions = nil;
        }
        
        error = nil;
        NSDictionary *awForecastSummaryDict = accuweatherDict[@"ForecastSummary"];
        NSDictionary *awForecastHeadlineDict = awForecastSummaryDict[@"Headline"];
        @try {
            self.forecastHeadline = [MTLJSONAdapter modelOfClass:[MIAccuWeatherForecastHeadline class] fromJSONDictionary:awForecastHeadlineDict error:&error];
        }
        @catch (NSException *exception) {
            self.forecastHeadline = nil;
        }
        if (error != nil) {
            self.forecastHeadline = nil;
        }
        
        NSArray *awDailyForecastDicts = awForecastSummaryDict[@"DailyForecasts"];
        NSMutableArray *newDailyForecasts = [[NSMutableArray alloc] initWithCapacity:awDailyForecastDicts.count];
        for (NSDictionary *aDailyForecastDict in awDailyForecastDicts) {
            error = nil;
            @try {
                MIAccuWeatherDailyForecast *aNewDailyForecast = [MTLJSONAdapter modelOfClass:[MIAccuWeatherDailyForecast class] fromJSONDictionary:aDailyForecastDict error:&error];
                if (error == nil) {
                    [newDailyForecasts addObject:aNewDailyForecast];
                }
            }
            @catch (NSException *exception) {
                // don't add
            }
        }
        self.dailyForecasts = newDailyForecasts;
        
        NSArray *awHourlyForecastDicts = awForecastSummaryDict[@"HourlyForecasts"];
        NSMutableArray *newHourlyForecasts = [[NSMutableArray alloc] initWithCapacity:awHourlyForecastDicts.count];
        for (NSDictionary *anHourlyForecastDict in awHourlyForecastDicts) {
            error = nil;
            @try {
                MIAccuWeatherDailyForecast *aNewHourlyForecast = [MTLJSONAdapter modelOfClass:[MIAccuWeatherHourlyForecast class] fromJSONDictionary:anHourlyForecastDict error:&error];
                if (error == nil) {
                    [newHourlyForecasts addObject:aNewHourlyForecast];
                }
            }
            @catch (NSException *exception) {
                // don't add
            }
        }
        self.hourlyForecasts = newHourlyForecasts;
        
        error = nil;
        NSDictionary *awMapsDict = accuweatherDict[@"Maps"];
        @try {
            self.maps = [MTLJSONAdapter modelOfClass:[MIAccuWeatherMaps class] fromJSONDictionary:awMapsDict error:&error];
        }
        @catch (NSException *exception) {
            self.maps = nil;
        }
        if (error != nil) {
            self.maps = nil;
        }
    }
    return self;
}

- (BOOL)isValid
{
    return (self.currentConditions != nil && self.dailyForecasts != nil && self.hourlyForecasts != nil && self.maps != nil);
}

- (BOOL)isPopulated
{
    return (self.currentConditions != nil || self.dailyForecasts != nil || self.hourlyForecasts != nil || self.maps != nil);
}

- (id)copyWithZone:(NSZone *)zone
{
    MIWeatherDatasetForLocation *result = [[[self class] alloc] init];
    
    result.locationKey = [self.locationKey copy];
    result.locationTitle = [self.locationTitle copy];
    result.locationTimeZoneCode = [self.locationTimeZoneCode copy];
    result.currentConditions = [self.currentConditions copy];
    result.forecastHeadline = [self.forecastHeadline copy];
    result.hourlyForecasts = [self.hourlyForecasts copy];
    result.dailyForecasts = [self.dailyForecasts copy];
    result.maps = [self.maps copy];
    
    return result;
}

@end

