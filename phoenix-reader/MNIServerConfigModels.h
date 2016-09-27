//
//  MNIServerConfigModels.h
//  Reader
//
//  Created by Yann Duran on 10/19/15.
//  Copyright © 2015 McClatchy Interactive. All rights reserved.
//
//  Based on : http://confluence.mcclatchyinteractive.com/display/MOBI/New+Server+Config

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>

@import UIKit;

#pragma mark - Api Info

@interface MNIConfigApiInfoModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSString *baseUrl;
@property (nonatomic, copy) NSString *publication;

@end


#pragma mark - Alerts

@interface MNIConfigAlertModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *timestamp;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *header_text;
@property (nonatomic, assign) BOOL persistent;
@property (nonatomic, copy) NSString *link;
@property (nonatomic, copy) NSString *link_text;
@property (nonatomic, copy) NSArray *app_versions;
@property (nonatomic, copy) NSArray *os_versions;

@end

typedef NS_ENUM(NSUInteger, MNIAlertModifier) {
    MNIAlertModifierAbove,
    MNIAlertModifierBelow,
    MNIAlertModifierBetween
};

@interface MNIConfigAlertVersionsModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, assign, readonly) MNIAlertModifier modifier;
@property (nonatomic, copy) NSArray *versions;

@end


#pragma mark - Weather

@interface MNIConfigAccuweatherModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSString *api_key;
@property (nonatomic, assign) BOOL dev_mode;
@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, copy) NSString *icons_base_url;
@property (nonatomic, copy) NSString *location_key;
@property (nonatomic, copy) NSString *partner_id;

@end

@interface MNIConfigWeatherModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) MNIConfigAccuweatherModel *accuweather;

@end


#pragma mark - Paywall

@interface MNIConfigPressPlusModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSString *api_key;
@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, copy) NSString *zone_uuid;

@end

@interface MNIConfigSyncronexModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSString *client_info;
@property (nonatomic, copy) NSString *company;
@property (nonatomic, copy) NSString *content_id;
@property (nonatomic, assign) BOOL dev_mode;
@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, assign) NSInteger minutes_tracked;
@property (nonatomic, copy) NSString *publication;
@property (nonatomic, copy) NSArray *iap_product_ids;
@property (nonatomic, copy) NSString *iap_shared_secret;

@end

@interface MNIConfigPayWallModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) MNIConfigPressPlusModel *press_plus;
@property (nonatomic, copy) MNIConfigSyncronexModel *syncronex;

@end


#pragma mark - Push

@interface MNIConfigUrbanAirshipModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, assign) BOOL debug_logging;
@property (nonatomic, copy) NSString *dev_app_key;
@property (nonatomic, copy) NSString *dev_app_secret;
@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, assign) BOOL in_production;
@property (nonatomic, copy) NSString *prod_app_key;
@property (nonatomic, copy) NSString *prod_app_secret;

@end

@interface MNIConfigPushNotificationsModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) MNIConfigUrbanAirshipModel *urban_airship;

@end


#pragma mark - Analytics

@interface MNIConfigOmnitureModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSString *biz_unit;
@property (nonatomic, assign) BOOL debug_logging;
@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, copy) NSString *publication;
@property (nonatomic, copy) NSString *rsid;
@property (nonatomic, copy) NSString *server;
@property (nonatomic, copy) NSString *appid;

@end

@interface MNIConfigAnalyticsModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) MNIConfigOmnitureModel *omniture;

@end


#pragma mark - About

@interface MNIConfigAboutModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSString *contact_email;
@property (nonatomic, copy) NSString *copyright;
@property (nonatomic, copy) NSString *privacy_policy;
@property (nonatomic, copy) NSString *terms_of_service;

@end


#pragma mark - Video

@interface MNIConfigYoutubeModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSString *api_key;

@end

@interface MNIConfigVideoModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) MNIConfigYoutubeModel *youtube;

@end


#pragma mark - Social

@interface MNIConfigSocialFacebookModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSString *api_key;
@property (nonatomic, assign) BOOL enabled;

@end

@interface MNIConfigSocialGooglePlusModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSString *client_id;

@end

@interface MNIConfigSocialModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) MNIConfigSocialFacebookModel *facebook;
@property (nonatomic, copy) MNIConfigSocialGooglePlusModel *google_plus;

@end


#pragma mark - Sections

typedef NS_ENUM(NSUInteger, MNISectionType) {
    MNISectionTypeSection,
    MNISectionTypeMultiSection,
    MNISectionTypeYoutube,
    MNISectionTypeWeb,
    MNISectionTypeGallery,
    MNISectionMSSPhone,
    MNISectionMSSTablet
};

@interface MNIConfigSectionModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSString *ad_channel;
@property (nonatomic, copy) NSString *ad_sect;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) MNISectionType type;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *section_id;
@property (nonatomic, copy) NSArray<MNIConfigSectionModel *> *sections;
@property (nonatomic, copy) NSString *contentType;
@property (nonatomic, weak) MNIConfigSectionModel *parentConfigSection;

- (BOOL)isTopSection;

@end


#pragma mark - More Options

typedef NS_ENUM(NSUInteger, MNIMoreOptionType) {
    MNIMoreOptionTypeWeather,
    MNIMoreOptionTypeLabel,
    MNIMoreOptionTypeInternalLink,
    MNIMoreOptionTypeExternalLink,
    MNIMoreOptionTypePrintEdition,
    MNIMoreOptionTypeSettings
};

@interface MNIConfigMoreOptionsModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign, readonly) MNIMoreOptionType type;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSArray *more_options;

@end


#pragma mark - Ads

@interface MNIConfigAdsAdhesionModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, assign) CGSize size;

@end

@interface MNIConfigAdsinterstitialModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, assign) NSInteger thresholdForSections;
@property (nonatomic, assign) NSInteger thresholdForStories;
@property (nonatomic, assign) NSInteger thresholdForGalleries;
@property (nonatomic, assign) NSInteger thresholdForVideos;

@end

@interface MNIConfigAdsAdmobPageLevelModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, assign) NSString *section;
@property (nonatomic, assign) NSString *story;

@end

@interface MNIConfigAdsAdmobModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSString *ad_unit_id;
@property (nonatomic, copy) NSArray *test_devices;
@property (nonatomic, copy) MNIConfigAdsAdmobPageLevelModel *pl;

@end

@interface  MNIConfigAdsMSSFAdDataModel: MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSString *pkg;
@property (nonatomic, copy) NSString *placement_url;

@end

typedef NS_ENUM(NSUInteger, MNIAdType) {
    MNIAdTypeBanner,
    MNIAdTypeNative
};

@interface MNIConfigAdsMSSFModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSString *device;
@property (nonatomic, assign) NSInteger position;
@property (nonatomic, assign) MNIAdType type;
@property (nonatomic, copy) MNIConfigAdsMSSFAdDataModel *ad_data;

@end

@interface MNIConfigAdsModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, assign) BOOL menu_enabled;
@property (nonatomic, copy) MNIConfigAdsAdhesionModel *adhesion;
@property (nonatomic, copy) MNIConfigAdsinterstitialModel *interstitial;
@property (nonatomic, copy) MNIConfigAdsAdmobModel *admob;
@property (nonatomic, copy) NSDictionary *mssf;

@end


#pragma mark - Market Timezone

@interface MNIConfigMarketTimezoneModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSString *abbreviation;
@property (nonatomic, assign) NSInteger offset;

@end


#pragma mark - MSSF Info

@interface MNIConfigMultiSectionsModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, assign) NSInteger top_stories_shown;
@property (nonatomic, copy) NSString *top_story_section_id;
@property (nonatomic, assign) NSInteger sections_shown;
@property (nonatomic, assign) NSInteger stories_shown;

@end

#pragma mark - Sections Info

@interface MNIConfigSectionsInfoModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, assign) NSInteger stories_shown_per_section;
@property (nonatomic, copy) MNIConfigMultiSectionsModel *multisection;
@property (nonatomic, copy) NSArray<MNIConfigSectionModel *> *sections;

- (MNIConfigSectionModel *)modelForSectionWithID:(NSString *)sectionID;

@end

#pragma mark - Root

@interface MNIServerConfigModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) MNIConfigMarketTimezoneModel *market_timezone;
@property (nonatomic, copy) NSString *app_store_id;
@property (nonatomic, copy) NSArray *alerts;
@property (nonatomic, copy) MNIConfigWeatherModel *weather;
@property (nonatomic, copy) MNIConfigPayWallModel *paywall;
@property (nonatomic, copy) MNIConfigPushNotificationsModel *push_notifications;
@property (nonatomic, copy) MNIConfigAnalyticsModel *analytics;
@property (nonatomic, copy) MNIConfigAboutModel *about;
@property (nonatomic, copy) MNIConfigVideoModel *video;
@property (nonatomic, copy) MNIConfigSocialModel *social;
@property (nonatomic, copy) MNIConfigSectionsInfoModel *sections_info;
@property (nonatomic, copy) NSArray *more_options;
@property (nonatomic, copy) MNIConfigAdsModel *ads;
@property (nonatomic, copy) MNIConfigApiInfoModel *apiInfo;

- (MNIConfigSectionModel *)sectionModelWithID:(NSString *)sectionID;
- (MNIConfigSectionModel *)sectionModelWithID:(NSString *)sectionID inArray:(NSArray<MNIConfigSectionModel *> *)sections searchRecursively:(BOOL)shouldRecurse;

@end
