//
//  MIWeatherDataProviderModels.h
//  Reader
//
//  Created by Scott Ferwerda on 10/2/15.
//  Copyright (c) 2015 McClatchy Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>
@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface MIAccuWeatherValue : MTLModel <MTLJSONSerializing>

@property (nonatomic, assign) CGFloat value;
@property (nonatomic, strong) NSString *unit;
@property (nonatomic, assign) NSInteger unitType;

@end

@interface MIAccuWeatherWindDirection : MTLModel <MTLJSONSerializing>

@property (nonatomic, assign) CGFloat degrees;
@property (nonatomic, strong) NSString *localizedText;
@property (nonatomic, strong) NSString *englishText;

@end

@interface MIAccuWeatherWind : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) MIAccuWeatherWindDirection *direction;
@property (nonatomic, strong) MIAccuWeatherValue *speed;

@end

@interface MIAccuWeatherPhoto : MTLModel <MTLJSONSerializing>

//@property (nonatomic, strong, readonly) NSDate *dateTaken;
@property (nonatomic, strong) NSString *source;
@property (nonatomic, strong) NSString *keywords;
@property (nonatomic, strong) NSString *portraitUrl;
@property (nonatomic, strong) NSString *landscapeUrl;

@end

@interface MIAccuWeatherCurrentConditions : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) NSString *observationDateISO8601;
@property (nonatomic, assign) NSTimeInterval observationDateEpochTime;
@property (nonatomic, strong) NSString *weatherText;
@property (nonatomic, assign) NSInteger iconId;
@property (nonatomic, assign) BOOL isDaytime;
@property (nonatomic, strong) MIAccuWeatherValue *temperature;
@property (nonatomic, strong) MIAccuWeatherValue *realFeelTemperature;
@property (nonatomic, strong) MIAccuWeatherValue *windChillTemperature;
@property (nonatomic, assign) CGFloat relativeHumidity;
@property (nonatomic, strong) MIAccuWeatherValue *dewPoint;
@property (nonatomic, strong) MIAccuWeatherWind *wind;
@property (nonatomic, strong) MIAccuWeatherValue *windGust;
@property (nonatomic, assign) CGFloat uvIndex;
@property (nonatomic, strong) NSString *uvIndexText;
@property (nonatomic, strong) MIAccuWeatherValue *visibility;
@property (nonatomic, strong) NSString *obstructionsToVisibility;
@property (nonatomic, assign) CGFloat cloudCover;
@property (nonatomic, strong) MIAccuWeatherValue *ceiling;
@property (nonatomic, strong) MIAccuWeatherValue *pressure;
@property (nonatomic, strong) NSString *pressureTendencyText;
@property (nonatomic, strong) MIAccuWeatherValue *past24HrHighTemperature;
@property (nonatomic, strong) MIAccuWeatherValue *past24HrLowTemperature;
@property (nonatomic, strong, readonly) NSArray *photos; // MIAccuWeatherPhoto objects

@property (nonatomic, strong) NSDate *objectUpdatedDate;

@property (nonatomic, strong, readonly) NSDate *observationDate;
@property (nonatomic, strong, readonly) NSTimeZone *observationTimeZone;

@end

@interface MIAccuWeatherHourlyForecast : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong, readonly) NSDate *forecastDate;
@property (nonatomic, strong, readonly) NSTimeZone *forecastTimeZone;
@property (nonatomic, strong) NSString *forecastDateISO8601;
@property (nonatomic, assign) NSTimeInterval forecastDateEpochTime;
@property (nonatomic, assign) NSInteger weatherIconId;
@property (nonatomic, strong) NSString *iconPhrase;
@property (nonatomic, assign) BOOL isDaylight;
@property (nonatomic, strong) MIAccuWeatherValue *temperature;
@property (nonatomic, assign) CGFloat precipitationProbability;

@end

@interface MIAccuWeatherDailyForecast : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong, readonly) NSDate *forecastDate;
@property (nonatomic, strong, readonly) NSTimeZone *forecastTimeZone;
@property (nonatomic, strong) NSString *forecastDateISO8601;
@property (nonatomic, assign) NSTimeInterval forecastDateEpochTime;
@property (nonatomic, strong) MIAccuWeatherValue *highTemperature;
@property (nonatomic, strong) MIAccuWeatherValue *lowTemperature;
@property (nonatomic, assign) NSInteger daytimeWeatherIconId;
@property (nonatomic, strong) NSString *daytimeIconPhrase;
@property (nonatomic, assign) NSInteger nighttimeWeatherIconId;
@property (nonatomic, strong) NSString *nighttimeIconPhrase;

@end

@interface MIAccuWeatherForecastHeadline : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong, readonly) NSDate *effectiveDate;
@property (nonatomic, strong, readonly) NSTimeZone *effectiveTimeZone;
@property (nonatomic, strong) NSString *effectiveDateISO8601;
@property (nonatomic, assign) NSTimeInterval effectiveDateEpochDate;
@property (nonatomic, assign) NSInteger severity;
@property (nonatomic, strong) NSString *text;

@end

@interface MIAccuWeatherMapEntry : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong, readonly) NSDate *mapDate;
@property (nonatomic, strong, readonly) NSTimeZone *mapTimeZone;
@property (nonatomic, strong) NSString *mapDateISO8601;
@property (nonatomic, strong) NSString *mapUrl;

@end

@interface MIAccuWeatherMap : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) NSString *mapSize;
@property (nonatomic, strong, readonly) NSArray *images; // holds MIAccuweatherMapEntry objects

@end

@interface MIAccuWeatherMaps : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong, readonly) MIAccuWeatherMap *radarMaps;
@property (nonatomic, strong, readonly) MIAccuWeatherMap *satelliteMaps;

@end

NS_ASSUME_NONNULL_END

@interface MIWeatherDatasetForLocation : NSObject <NSCopying>

@property (nonatomic, strong, nullable) NSString *locationKey;
@property (nonatomic, strong, nullable) NSString *locationTitle;
@property (nonatomic, strong, nullable) NSString *locationTimeZoneCode;
@property (nonatomic, strong, nullable) MIAccuWeatherCurrentConditions *currentConditions;
@property (nonatomic, strong, nullable) MIAccuWeatherForecastHeadline *forecastHeadline;
@property (nonatomic, strong, nullable) NSArray *hourlyForecasts; // MIAccuWeatherHourlyForecast objects
@property (nonatomic, strong, nullable) NSArray *dailyForecasts; // MIAccuWeatherDailyForecast objects
@property (nonatomic, strong, nullable) MIAccuWeatherMaps *maps;

- (nullable instancetype)initWithAccuweatherDictionary:(NSDictionary * _Nonnull)accuweatherDict;
- (BOOL)isValid;
- (BOOL)isPopulated;

@end
